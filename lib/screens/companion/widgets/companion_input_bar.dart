import 'package:flutter/material.dart';

class CompanionInputBar extends StatefulWidget {
  const CompanionInputBar({
    super.key,
    required this.onSend,
    required this.onMic,
    this.enabled = true,
  });
  final ValueChanged<String> onSend;
  final VoidCallback onMic;
  final bool enabled;
  @override
  State<CompanionInputBar> createState() => _CompanionInputBarState();
}

class _CompanionInputBarState extends State<CompanionInputBar> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                  onPressed: widget.enabled ? widget.onMic : null,
                  icon: const Icon(Icons.mic_none)),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: 'Ask Sakhi privately',
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.enabled
                    ? () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          widget.onSend(text);
                          controller.clear();
                        }
                      }
                    : null,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      );
}
