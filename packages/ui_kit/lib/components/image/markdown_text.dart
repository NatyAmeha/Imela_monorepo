import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownText extends StatefulWidget {
  const MarkdownText({
    required this.data,
    this.shrinkWrap = true,
    this.padding = EdgeInsets.zero,
    this.maxHeight,
    super.key,
  });

  final String data;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final double? maxHeight;

  @override
  State<MarkdownText> createState() => _MarkdownTextState();
}

class _MarkdownTextState extends State<MarkdownText> {
  bool _isExpanded = false;
  final GlobalKey _contentKey = GlobalKey();
  bool _hasOverflow = false;
  double? _contentHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  void _checkOverflow() {
    if (widget.maxHeight == null) return;

    final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final height = renderBox.size.height;
      setState(() {
        _contentHeight = height;
        _hasOverflow = height > (widget.maxHeight ?? 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded 
              ? _contentHeight 
              : _contentHeight != null 
                  ? min(_contentHeight!, widget.maxHeight ?? _contentHeight!)
                  : widget.maxHeight,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: MarkdownBody(
              key: _contentKey,
              data: widget.data,
              shrinkWrap: widget.shrinkWrap,
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineLarge,
                h2: Theme.of(context).textTheme.headlineMedium,
                h3: Theme.of(context).textTheme.headlineSmall,
                h4: Theme.of(context).textTheme.titleLarge,
                h5: Theme.of(context).textTheme.titleMedium,
                h6: Theme.of(context).textTheme.titleSmall,
                p: Theme.of(context).textTheme.bodyMedium,
                code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.grey.withOpacity(0.2),
                    ),
                blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
              ),
              onTapLink: (text, href, title) async {
                // if (href != null) {
                //   final uri = Uri.parse(href);
                //   if (await canLaunchUrl(uri)) {
                //     await launchUrl(uri);
                //   }
                // }
              },
            ),
          ),
        ),
        if (widget.maxHeight != null && _hasOverflow)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show Less' : 'Show More',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
