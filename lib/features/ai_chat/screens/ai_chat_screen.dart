import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const Set<String> _knownErrors = {
    'ai_chat_disabled',
    'ai_chat_daily_limit_reached',
    'ai_chat_temporarily_unavailable',
  };

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_AiChatMessage> _messages = [];
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String content = _textController.text.trim();
    if (content.isEmpty || _sending) return;

    final List<Map<String, String>> history = _messages
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
      _messages.add(_AiChatMessage(role: 'user', content: content));
      _textController.clear();
      _sending = true;
    });
    _scrollToEnd();

    final Response response = await Get.find<ApiClient>().postData(
      AppConstants.aiChatSendMessageUri,
      {'message': content, 'history': history},
      handleError: false,
    );

    if (!mounted) return;

    String reply;
    String role;
    if (response.statusCode == 200 && response.body is Map) {
      reply = response.body['message']?.toString().trim() ?? '';
      role = 'assistant';
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
      _messages.add(_AiChatMessage(role: role, content: reply));
      _sending = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI_Chat_Assistant'.tr), elevation: 0.5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeLarge,
                        ),
                        child: Text(
                          'AI_Chat_Assistant_read_only_hint'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      itemCount: _messages.length + (_sending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall,
                            ),
                            child: Text(
                              '${'AI_Chat_Assistant'.tr}...',
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          );
                        }
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeSmall +
                    MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_sending,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                      decoration: InputDecoration(hintText: 'type_here'.tr),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'send'.tr,
                    onPressed: _sending ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _AiChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';
    final bool isError = message.role == 'error';

    return Align(
      alignment: isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
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
        child: Text(
          message.content,
          style: TextStyle(
            color: isError
                ? Theme.of(context).colorScheme.onErrorContainer
                : isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _AiChatMessage {
  final String role;
  final String content;

  const _AiChatMessage({required this.role, required this.content});
}
