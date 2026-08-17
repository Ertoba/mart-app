import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/ai_chat/widgets/ai_chat_result_sections.dart';
import 'package:sixam_mart/features/chat/screens/chat_screen.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
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
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 220),
    ),
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (sheetContext) => AnimatedPadding(
      duration: const Duration(milliseconds: 220),
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
  bool _sending = false;
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
    _loadHistory();
  }

  @override
  void didChangeMetrics() {
    _scrollToEnd(delay: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _archiveTimer?.cancel();
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
    _scrollToEnd();
  }

  void _askAbout(String subject) {
    if (subject.trim().isEmpty || _sending || _currentConversationIsArchived) {
      return;
    }
    _textController.text = '${'search'.tr}: ${subject.trim()}';
    _sendMessage();
  }

  void _scrollToEnd({bool immediate = false, Duration delay = Duration.zero}) {
    void scroll() {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final double end = _scrollController.position.maxScrollExtent;
      if (immediate) {
        _scrollController.jumpTo(end);
      } else {
        _scrollController.animateTo(
          end,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (delay == Duration.zero) {
        scroll();
      } else {
        Future<void>.delayed(delay, scroll);
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
    final Color primary = Theme.of(context).primaryColor;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(Dimensions.radiusExtraLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ChatHeader(
            operatorMode: _operatorMode,
            historyExpanded: _historyExpanded,
            onHistory: () =>
                setState(() => _historyExpanded = !_historyExpanded),
            onOperator: _switchToOperator,
            onAssistant: () => setState(() => _operatorMode = false),
            onClose: () => Navigator.of(context).pop(),
          ),
          if (!_operatorMode)
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: !_historyExpanded
                  ? const SizedBox(width: double.infinity)
                  : _HistoryPanel(
                      conversations: _conversations,
                      currentId: _currentConversationId,
                      onNew: _newConversation,
                      onSelect: _selectConversation,
                      onDelete: _deleteConversation,
                    ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
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
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  itemCount:
                                      _messages.length + (_sending ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _messages.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeSmall,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: primary,
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            Text('ai_chat_typing'.tr),
                                          ],
                                        ),
                                      );
                                    }
                                    return _MessageBubble(
                                      message: _messages[index],
                                      onAskAbout: _askAbout,
                                    );
                                  },
                                ),
                        ),
                        if (_currentConversationIsArchived)
                          const _ArchivedConversationNotice()
                        else
                          _AiComposer(
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
  }
}

class _ChatHeader extends StatelessWidget {
  final bool operatorMode;
  final bool historyExpanded;
  final VoidCallback onHistory;
  final VoidCallback onOperator;
  final VoidCallback onAssistant;
  final VoidCallback onClose;

  const _ChatHeader({
    required this.operatorMode,
    required this.historyExpanded,
    required this.onHistory,
    required this.onOperator,
    required this.onAssistant,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (operatorMode)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: primary),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: primary),
            ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operatorMode ? 'support_operator'.tr : 'AI_Chat_Assistant'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  operatorMode ? 'human_support'.tr : 'ai_chat_online'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: primary),
                ),
              ],
            ),
          ),
          if (!operatorMode) ...[
            IconButton(
              tooltip: 'chat_history'.tr,
              onPressed: onHistory,
              icon: Icon(
                historyExpanded ? Icons.history_toggle_off : Icons.history,
              ),
            ),
            IconButton(
              tooltip: 'contact_operator'.tr,
              onPressed: onOperator,
              icon: const Icon(Icons.support_agent),
            ),
          ] else
            IconButton(
              tooltip: 'AI_Chat_Assistant'.tr,
              onPressed: onAssistant,
              icon: const Icon(Icons.auto_awesome),
            ),
          IconButton(
            tooltip: 'close'.tr,
            onPressed: onClose,
            icon: const Icon(Icons.close),
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
    required this.conversations,
    required this.currentId,
    required this.onNew,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 210),
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'chat_history'.tr,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Text('no_chat_history'.tr),
            )
          else
            Flexible(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ListTile(
                    dense: true,
                    selected: conversation.id == currentId,
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
                    onTap: () => onSelect(conversation.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (conversation.isArchived)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4),
                            child: Text(
                              'chat_archived'.tr,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        IconButton(
                          tooltip: 'delete'.tr,
                          onPressed: () => onDelete(conversation.id),
                          icon: const Icon(Icons.delete_outline, size: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AiComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _AiComposer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Tooltip(
            message: 'attachments_after_operator'.tr,
            child: const IconButton(
              onPressed: null,
              icon: Icon(Icons.attach_file),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              decoration: InputDecoration(
                hintText: 'type_here'.tr,
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          IconButton.filled(
            tooltip: 'send'.tr,
            onPressed: sending ? null : onSend,
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }
}

class _ArchivedConversationNotice extends StatelessWidget {
  const _ArchivedConversationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Theme.of(context).hintColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              'chat_archived_read_only'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiEmptyState extends StatelessWidget {
  final String displayName;
  final ValueChanged<String> onPrompt;

  const _AiEmptyState({required this.displayName, required this.onPrompt});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    final List<_QuickPromptData> prompts = [
      _QuickPromptData(
        Icons.local_fire_department_outlined,
        'most_popular_items'.tr,
      ),
      _QuickPromptData(Icons.local_offer_outlined, 'discounted_items'.tr),
      _QuickPromptData(Icons.storefront_outlined, 'popular_stores'.tr),
      _QuickPromptData(Icons.grid_view_outlined, 'categories'.tr),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: primary, size: 30),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'ai_chat_greeting'.trParams({'name': displayName}),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'AI_Chat_Assistant_read_only_hint'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Dimensions.paddingSizeSmall,
                runSpacing: Dimensions.paddingSizeSmall,
                children: prompts
                    .map(
                      (prompt) => ActionChip(
                        avatar: Icon(prompt.icon, size: 18, color: primary),
                        label: Text(prompt.label),
                        onPressed: () => onPrompt(prompt.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickPromptData {
  final IconData icon;
  final String label;

  const _QuickPromptData(this.icon, this.label);
}

class _MessageBubble extends StatelessWidget {
  final _AiChatMessage message;
  final ValueChanged<String> onAskAbout;

  const _MessageBubble({required this.message, required this.onAskAbout});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';
    final bool isError = message.role == 'error';
    return Align(
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
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: isUser
                    ? null
                    : Border.all(color: Theme.of(context).dividerColor),
              ),
              child: SelectableText(
                _plainTextLinks(message.content),
                style: TextStyle(
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
              ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],
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
