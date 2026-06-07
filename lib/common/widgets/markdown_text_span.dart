import 'package:flutter/material.dart';

TextSpan buildMarkdownTextSpan(String data, TextStyle style) {
  final List<InlineSpan> children = [];
  final lines = data.replaceAll('\r\n', '\n').split('\n');

  for (int index = 0; index < lines.length; index++) {
    final line = lines[index];
    final trimmed = line.trim();
    final bulletMatch = RegExp(r'^[-*]\s+(.+)$').firstMatch(trimmed);
    final numberedMatch = RegExp(r'^(\d+\.)\s+(.+)$').firstMatch(trimmed);

    if (trimmed.isEmpty) {
      if (index != lines.length - 1) {
        children.add(TextSpan(text: '\n', style: style));
      }
      continue;
    }

    if (bulletMatch != null || numberedMatch != null) {
      final marker = numberedMatch?.group(1) ?? '•';
      final text = bulletMatch?.group(1) ?? numberedMatch!.group(2)!;
      children.add(TextSpan(text: '$marker ', style: style));
      children.addAll(_buildInlineMarkdown(text, style));
    } else {
      children.addAll(_buildInlineMarkdown(line, style));
    }

    if (index != lines.length - 1) {
      children.add(TextSpan(text: '\n', style: style));
    }
  }

  return TextSpan(style: style, children: children);
}

List<InlineSpan> _buildInlineMarkdown(String text, TextStyle style) {
  final List<InlineSpan> spans = [];
  final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
  int lastIndex = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(text: text.substring(lastIndex, match.start), style: style),
      );
    }

    final token = match.group(0)!;
    if (token.startsWith('**')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: style.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: style.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex), style: style));
  }

  return spans;
}
