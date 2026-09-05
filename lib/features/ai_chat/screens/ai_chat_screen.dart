import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_result_sections.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_visuals.dart';
import 'package:sixam_mart/features/chat/screens/chat_screen.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';

Future<void> showAiChatBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    clipBehavior: Clip.antiAlias,
    constraints: const BoxConstraints(maxWidth: 720),
    sheetAnimationStyle: AnimationStyle(
      duration: aiChatDuration(context, 300),
      reverseDuration: aiChatDuration(context),
    ),
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (sheetContext) => AnimatedPadding(
      duration: aiChatDuration(context),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: const FractionallySizedBox(
        heightFactor: 0.94,
        child: AiChatSheet(),
      ),
    ),
  );
}

class AiChatSheet extends StatefulWidget {
  const AiChatSheet({super.key});

  @override
  State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> with WidgetsBindingObserver {
  static const Duration _archiveAfter = Duration(hours: 1);
  static const Set<String> _knownErrors = {
    'ai_chat_disabled',
    'ai_chat_daily_limit_reached',
    'ai_chat_temporarily_unavailable',
  };

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_AiChatConversation> _conversations = [];
  Timer? _archiveTimer;
  Timer? _scrollTimer;
  bool _sending = false;
  bool _showLatest = false;
  bool _historyExpanded = false;
  bool _operatorMode = false;
  String? _currentConversationId;
  String? _handoffTranscript;

  String? get _storageKey {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().userInfoModel
        : null;
    final String identity = (profile?.id ?? profile?.email ?? '')
        .toString()
        .trim();
    return identity.isEmpty ? null : 'mili_ai_chat_history_$identity';
  }

  String get _displayName {
    final String name = Get.isRegistered<ProfileController>()
        ? (Get.find<ProfileController>().userInfoModel?.fName ?? '').trim()
        : '';
    return name.isEmpty ? 'customer'.tr : name;
  }

  _AiChatConversation? get _currentConversation =>
      _conversations.firstWhereOrNull(
        (conversation) => conversation.id == _currentConversationId,
      );

  List<_AiChatMessage> get _messages =>
      _currentConversation?.messages ?? const <_AiChatMessage>[];

  bool get _currentConversationIsArchived =>
      _currentConversation?.isArchived ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_trackScrollPosition);
    _loadHistory();
  }

  @override
  void didChangeMetrics() {
    if (!_showLatest) _scrollToEnd(delay: const Duration(milliseconds: 120));
  }

  void _trackScrollPosition() {
    if (!_scrollController.hasClients) return;
    final awayFromLatest = _scrollController.position.extentAfter > 80;
    if (awayFromLatest != _showLatest && mounted) {
      setState(() => _showLatest = awayFromLatest);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _archiveTimer?.cancel();
    _scrollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final SharedPreferences preferences = Get.find<SharedPreferences>();
    final String? storageKey = _storageKey;
    if (storageKey == null) {
      return;
    }
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _conversations.addAll(
        decoded
            .whereType<Map<String, dynamic>>()
            .map(_AiChatConversation.fromJson)
            .where((conversation) => conversation.messages.isNotEmpty),
      );
      _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final bool changed = _archiveExpiredConversations(DateTime.now());
      _currentConversationId = _conversations
          .firstWhereOrNull((conversation) => !conversation.isArchived)
          ?.id;
      if (changed) {
        _saveHistory();
      }
      _scheduleArchiveTimer();
      _scrollToEnd(immediate: true);
    } catch (_) {
      preferences.remove(storageKey);
    }
  }

  bool _archiveExpiredConversations(DateTime now) {
    bool changed = false;
    for (final conversation in _conversations) {
      if (!conversation.isArchived &&
          !conversation.updatedAt.add(_archiveAfter).isAfter(now)) {
        conversation.archivedAt = conversation.updatedAt.add(_archiveAfter);
        changed = true;
      }
    }
    return changed;
  }

  void _scheduleArchiveTimer() {
    _archiveTimer?.cancel();
    final DateTime now = DateTime.now();
    final List<_AiChatConversation> active =
        _conversations
            .where((conversation) => !conversation.isArchived)
            .toList()
          ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    if (active.isEmpty) {
      return;
    }

    final Duration remaining = active.first.updatedAt
        .add(_archiveAfter)
        .difference(now);
    if (remaining <= Duration.zero) {
      _archiveAtDeadline();
      return;
    }
    _archiveTimer = Timer(remaining, _archiveAtDeadline);
  }

  void _archiveAtDeadline() {
    if (!mounted) {
      return;
    }
    final bool changed = _archiveExpiredConversations(DateTime.now());
    if (changed) {
      setState(() {});
      _saveHistory();
    }
    _scheduleArchiveTimer();
  }

  _AiChatConversation _ensureConversation() {
    final _AiChatConversation? current = _currentConversation;
    if (current != null && !current.isArchived) return current;
    final DateTime now = DateTime.now();
    final conversation = _AiChatConversation(
      id: now.microsecondsSinceEpoch.toString(),
      title: 'new_chat'.tr,
      updatedAt: now,
      archivedAt: null,
      messages: [],
    );
    _conversations.insert(0, conversation);
    _currentConversationId = conversation.id;
    _scheduleArchiveTimer();
    return conversation;
  }

  void _saveHistory() {
    final String? storageKey = _storageKey;
    if (storageKey == null) {
      return;
    }
    _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (_conversations.length > 20) {
      _conversations.removeRange(20, _conversations.length);
    }
    Get.find<SharedPreferences>().setString(
      storageKey,
      jsonEncode(_conversations.map((item) => item.toJson()).toList()),
    );
  }

  void _newConversation() {
    setState(() {
      _currentConversationId = null;
      _historyExpanded = false;
      _showLatest = false;
      _textController.clear();
    });
    _scheduleArchiveTimer();
  }

  void _selectConversation(String id) {
    final bool changed = _archiveExpiredConversations(DateTime.now());
    setState(() {
      _currentConversationId = id;
      _historyExpanded = false;
    });
    if (changed) {
      _saveHistory();
    }
    _scheduleArchiveTimer();
    _scrollToEnd(immediate: true);
  }

  void _deleteConversation(String id) {
    setState(() {
      _conversations.removeWhere((conversation) => conversation.id == id);
      if (_currentConversationId == id) {
        _currentConversationId = _conversations
            .firstWhereOrNull((conversation) => !conversation.isArchived)
            ?.id;
      }
    });
    _saveHistory();
    _scheduleArchiveTimer();
  }

  Future<void> _sendMessage() async {
    final String content = _textController.text.trim();
    if (content.isEmpty || _sending || _currentConversationIsArchived) return;

    final _AiChatConversation conversation = _ensureConversation();
    final List<Map<String, String>> history = conversation.messages
        .where(
          (message) => message.role == 'user' || message.role == 'assistant',
        )
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .map((message) => {'role': message.role, 'content': message.content})
        .toList();

    setState(() {
      conversation.messages.add(_AiChatMessage(role: 'user', content: content));
      if (conversation.messages.length == 1) {
        conversation.title = content.length > 42
            ? '${content.substring(0, 42)}...'
            : content;
      }
      conversation.updatedAt = DateTime.now();
      _textController.clear();
      _sending = true;
    });
    _saveHistory();
    _scheduleArchiveTimer();
    _scrollToEnd();

    final Response response = await Get.find<ApiClient>().postData(
      AppConstants.aiChatSendMessageUri,
      {'message': content, 'history': history},
      handleError: false,
    );
    if (!mounted) return;

    String reply;
    String role;
    Map<String, dynamic> metadata = const <String, dynamic>{};
    if (response.statusCode == 200 && response.body is Map) {
      reply = response.body['message']?.toString().trim() ?? '';
      role = 'assistant';
      if (response.body['metadata'] is Map) {
        metadata = Map<String, dynamic>.from(response.body['metadata'] as Map);
      }
      if (reply.isEmpty) {
        reply = 'ai_chat_temporarily_unavailable'.tr;
        role = 'error';
      }
    } else {
      final String? responseKey = response.body is Map
          ? response.body['message']?.toString()
          : null;
      reply =
          (_knownErrors.contains(responseKey)
                  ? responseKey!
                  : 'ai_chat_temporarily_unavailable')
              .tr;
      role = 'error';
    }

    setState(() {
      conversation.messages.add(
        _AiChatMessage(role: role, content: reply, metadata: metadata),
      );
      if (conversation.messages.length > 50) {
        conversation.messages.removeRange(0, conversation.messages.length - 50);
      }
      conversation.updatedAt = DateTime.now();
      _sending = false;
    });
    _saveHistory();
    _scheduleArchiveTimer();
    if (!_showLatest) _scrollToEnd();
  }

  void _askAbout(String subject) {
    if (subject.trim().isEmpty || _sending || _currentConversationIsArchived) {
      return;
    }
    _textController.text = '${'search'.tr}: ${subject.trim()}';
    _sendMessage();
  }

  Future<void> _openProduct(Map<String, dynamic> product) async {
    final int? itemId = int.tryParse(product['id']?.toString() ?? '');
    if (itemId == null) return;
    final String name = product['name']?.toString() ?? '';
    final String slug = product['slug']?.toString() ?? '';
    final bool isRestaurant =
        ModuleHelper.getModuleConfig(
          ModuleHelper.getModule()?.moduleType,
        ).showRestaurantText ??
        false;

    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    Get.toNamed(
      RouteHelper.getItemDetailsRoute(itemId, isRestaurant, name, slug: slug),
    );
  }

  Future<void> _openStore(Map<String, dynamic> store) async {
    final int? storeId = int.tryParse(store['id']?.toString() ?? '');
    if (storeId == null) return;

    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    Get.toNamed(
      RouteHelper.getStoreRoute(
        id: storeId,
        page: 'store',
        slug: store['slug']?.toString() ?? '',
      ),
    );
  }

  void _scrollToEnd({bool immediate = false, Duration delay = Duration.zero}) {
    void scroll() {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final double end = _scrollController.position.maxScrollExtent;
      if (immediate || MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(end);
      } else {
        _scrollController.animateTo(
          end,
          duration: aiChatDuration(context, 240),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollTimer?.cancel();
      if (delay == Duration.zero) {
        scroll();
      } else {
        _scrollTimer = Timer(delay, scroll);
      }
    });
  }

  void _switchToOperator() {
    final List<_AiChatMessage> contextMessages = _messages.reversed
        .take(10)
        .toList()
        .reversed
        .toList();
    final String transcript = contextMessages.isEmpty
        ? 'ai_chat_operator_requested'.tr
        : contextMessages
              .map(
                (message) =>
                    '${message.role == 'user' ? _displayName : 'AI_Chat_Assistant'.tr}: ${message.content}',
              )
              .join('\n');
    _handoffTranscript =
        '${'ai_chat_handoff_context'.tr}\n${transcript.length > 3500 ? transcript.substring(transcript.length - 3500) : transcript}';
    setState(() {
      _operatorMode = true;
      _historyExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 520 ||
            MediaQuery.textScalerOf(context).scale(14) > 21;
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ChatHeader(
                compact: compact,
                operatorMode: _operatorMode,
                historyExpanded: _historyExpanded,
                onHistory: () =>
                    setState(() => _historyExpanded = !_historyExpanded),
                onNew: _sending ? null : _newConversation,
                onOperator: _switchToOperator,
                onAssistant: () => setState(() => _operatorMode = false),
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: aiChatDuration(context, 240),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _operatorMode
                      ? ChatScreen(
                          key: const ValueKey('operator-chat'),
                          notificationBody: NotificationBodyModel(
                            type: 'admin',
                            notificationType: NotificationType.message,
                            adminId: 0,
                            receiverType: 'admin',
                          ),
                          user: null,
                          embedded: true,
                          initialMessage: _handoffTranscript,
                        )
                      : _historyExpanded
                      ? _HistoryPanel(
                          key: const ValueKey('ai-history'),
                          conversations: _conversations,
                          currentId: _currentConversationId,
                          onNew: _newConversation,
                          onSelect: _selectConversation,
                          onDelete: _deleteConversation,
                        )
                      : Column(
                          key: const ValueKey('ai-chat'),
                          children: [
                            Expanded(
                              child: _messages.isEmpty
                                  ? _AiEmptyState(
                                      displayName: _displayName,
                                      onPrompt: _askAbout,
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault,
                                      ),
                                      itemCount:
                                          _messages.length + (_sending ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == _messages.length) {
                                          return const AiChatTypingIndicator();
                                        }
                                        return _MessageBubble(
                                          key: ValueKey(
                                            '${_currentConversationId ?? 'new'}-$index-${_messages[index].role}',
                                          ),
                                          message: _messages[index],
                                          onAskAbout: _askAbout,
                                          onOpenProduct: _openProduct,
                                          onOpenStore: _openStore,
                                        );
                                      },
                                    ),
                            ),
                            if (_showLatest && _messages.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _scrollToEnd(),
                                icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 18,
                                ),
                                label: Text('ai_chat_ui_latest'.tr),
                              ),
                            if (_currentConversationIsArchived)
                              _ArchivedConversationNotice(
                                onNew: _newConversation,
                              )
                            else
                              _AiComposer(
                                compact: compact,
                                controller: _textController,
                                sending: _sending,
                                onSend: _sendMessage,
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final bool compact;
  final bool operatorMode;
  final bool historyExpanded;
  final VoidCallback onHistory;
  final VoidCallback? onNew;
  final VoidCallback onOperator;
  final VoidCallback onAssistant;
  final VoidCallback onClose;
  const _ChatHeader({
    required this.compact,
    required this.operatorMode,
    required this.historyExpanded,
    required this.onHistory,
    required this.onNew,
    required this.onOperator,
    required this.onAssistant,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (compact) {
      return Container(
        color: theme.cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (operatorMode)
                  Icon(
                    Icons.support_agent_rounded,
                    color: theme.primaryColor,
                    size: 32,
                  )
                else
                  const AiChatMark(size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    operatorMode
                        ? 'support_operator'.tr
                        : 'AI_Chat_Assistant'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'close'.tr,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!operatorMode) ...[
                  IconButton(
                    tooltip: 'new_chat'.tr,
                    onPressed: onNew,
                    icon: const Icon(Icons.add_comment_outlined),
                  ),
                  IconButton(
                    tooltip: 'chat_history'.tr,
                    onPressed: onHistory,
                    icon: const Icon(Icons.history_rounded),
                  ),
                  IconButton(
                    tooltip: 'contact_operator'.tr,
                    onPressed: onOperator,
                    icon: const Icon(Icons.support_agent_rounded),
                  ),
                ] else
                  IconButton(
                    tooltip: 'AI_Chat_Assistant'.tr,
                    onPressed: onAssistant,
                    icon: const Icon(Icons.auto_awesome_rounded),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: aiChatBorder(context))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: aiChatBorder(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            children: [
              if (operatorMode)
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: .1),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: theme.primaryColor,
                  ),
                )
              else
                const AiChatMark(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operatorMode
                          ? 'support_operator'.tr
                          : 'AI_Chat_Assistant'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      operatorMode
                          ? 'human_support'.tr
                          : 'ai_chat_ui_subtitle'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: aiChatMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'close'.tr,
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (!operatorMode) ...[
                  TextButton.icon(
                    onPressed: onNew,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('new_chat'.tr),
                  ),
                  TextButton.icon(
                    onPressed: onHistory,
                    style: TextButton.styleFrom(
                      backgroundColor: historyExpanded
                          ? theme.primaryColor.withValues(alpha: .08)
                          : null,
                    ),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: Text('ai_chat_ui_history'.tr),
                  ),
                  TextButton.icon(
                    onPressed: onOperator,
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: Text('ai_chat_ui_support'.tr),
                  ),
                ] else
                  TextButton.icon(
                    onPressed: onAssistant,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text('AI_Chat_Assistant'.tr),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  final List<_AiChatConversation> conversations;
  final String? currentId;
  final VoidCallback onNew;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  const _HistoryPanel({
    super.key,
    required this.conversations,
    required this.currentId,
    required this.onNew,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'chat_history'.tr,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          TextButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add, size: 18),
            label: Text('new_chat'.tr),
          ),
        ],
      ),
      if (conversations.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('no_chat_history'.tr),
        )
      else
        ...conversations.map(
          (conversation) => ListTile(
            selected: conversation.id == currentId,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: Icon(
              conversation.isArchived
                  ? Icons.archive_outlined
                  : Icons.chat_bubble_outline,
              size: 20,
            ),
            title: Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: conversation.isArchived ? Text('chat_archived'.tr) : null,
            onTap: () => onSelect(conversation.id),
            trailing: IconButton(
              tooltip: 'delete'.tr,
              onPressed: () => onDelete(conversation.id),
              icon: const Icon(Icons.delete_outline, size: 20),
            ),
          ),
        ),
    ],
  );
}

class _AiComposer extends StatelessWidget {
  final bool compact;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _AiComposer({
    required this.compact,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: aiChatBorder(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: aiChatBorder(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: compact ? 2 : 4,
                    textInputAction: TextInputAction.send,
                    onEditingComplete: () {},
                    inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'ai_chat_ui_placeholder'.tr,
                      hintMaxLines: 2,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!sending) onSend();
                    },
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) => IconButton.filled(
                    tooltip: 'send'.tr,
                    onPressed: sending || value.text.trim().isEmpty
                        ? null
                        : onSend,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(
              'ai_chat_ui_footer'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: aiChatMuted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchivedConversationNotice extends StatelessWidget {
  final VoidCallback onNew;
  const _ArchivedConversationNotice({required this.onNew});
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'chat_archived_read_only'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: 'new_chat'.tr,
            onPressed: onNew,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
    ),
  );
}

class _AiEmptyState extends StatelessWidget {
  final String displayName;
  final ValueChanged<String> onPrompt;
  const _AiEmptyState({required this.displayName, required this.onPrompt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prompts = [
      (
        Icons.trending_up_rounded,
        'most_popular_items'.tr,
        'ai_chat_ui_popular_hint'.tr,
      ),
      (
        Icons.local_offer_outlined,
        'discounted_items'.tr,
        'ai_chat_ui_deals_hint'.tr,
      ),
      (
        Icons.storefront_outlined,
        'popular_stores'.tr,
        'ai_chat_ui_stores_hint'.tr,
      ),
      (
        Icons.grid_view_rounded,
        'categories'.tr,
        'ai_chat_ui_categories_hint'.tr,
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiChatMark(size: 60),
              const SizedBox(height: 20),
              Text(
                'ai_chat_greeting'.trParams({'name': displayName}),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ai_chat_ui_intro'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: aiChatMuted(context),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >= 420 &&
                          MediaQuery.textScalerOf(context).scale(14) < 20
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: prompts
                        .map(
                          (prompt) => SizedBox(
                            width:
                                (constraints.maxWidth - (columns - 1) * 10) /
                                columns,
                            child: Material(
                              color: theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: aiChatBorder(context)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => onPrompt(prompt.$2),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(
                                            alpha: .08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          prompt.$1,
                                          color: theme.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prompt.$2,
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              prompt.$3,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: theme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _AiChatMessage message;
  final ValueChanged<String> onAskAbout;
  final ValueChanged<Map<String, dynamic>> onOpenProduct;
  final ValueChanged<Map<String, dynamic>> onOpenStore;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.onAskAbout,
    required this.onOpenProduct,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';
    final bool isError = message.role == 'error';
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: aiChatDuration(context),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
      child: Align(
        alignment: isUser
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeExtraSmall,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: isError
                      ? Theme.of(context).colorScheme.errorContainer
                      : isUser
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: const Radius.circular(18),
                    topEnd: const Radius.circular(18),
                    bottomStart: Radius.circular(isUser ? 18 : 4),
                    bottomEnd: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: aiChatBorder(context)),
                ),
                child: SelectableText(
                  _plainTextLinks(message.content),
                  style: TextStyle(
                    height: 1.6,
                    color: isError
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : isUser
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              if (!isUser && !isError && message.metadata.isNotEmpty)
                AiChatResultSections(
                  metadata: message.metadata,
                  onAskAbout: onAskAbout,
                  onOpenProduct: onOpenProduct,
                  onOpenStore: onOpenStore,
                ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            ],
          ),
        ),
      ),
    );
  }

  String _plainTextLinks(String content) {
    return content.replaceAllMapped(
      RegExp(r'\[[^\]]+\]\((https?://[^\s)]+)\)'),
      (match) => match.group(1)!,
    );
  }
}

class _AiChatMessage {
  final String role;
  final String content;
  final Map<String, dynamic> metadata;

  const _AiChatMessage({
    required this.role,
    required this.content,
    this.metadata = const <String, dynamic>{},
  });

  factory _AiChatMessage.fromJson(Map<String, dynamic> json) {
    return _AiChatMessage(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}

class _AiChatConversation {
  final String id;
  String title;
  DateTime updatedAt;
  DateTime? archivedAt;
  final List<_AiChatMessage> messages;

  _AiChatConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.archivedAt,
    required this.messages,
  });

  bool get isArchived => archivedAt != null;

  factory _AiChatConversation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawMessages =
        json['messages'] as List<dynamic>? ?? const <dynamic>[];
    return _AiChatConversation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      archivedAt: DateTime.tryParse(json['archived_at']?.toString() ?? ''),
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(_AiChatMessage.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'updated_at': updatedAt.toIso8601String(),
    'archived_at': archivedAt?.toIso8601String(),
    'messages': messages.map((message) => message.toJson()).toList(),
  };
}
