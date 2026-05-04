import 'package:flutter/material.dart';

class CompanionInputBar extends StatefulWidget {
  const CompanionInputBar({
    super.key,
    required this.onSend,
    required this.onMic,
  });
  final ValueChanged<String> onSend;
  final VoidCallback onMic;
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
                  onPressed: widget.onMic, icon: const Icon(Icons.mic_none)),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: 'Ask Sakhi privately',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSend(text);
                    controller.clear();
                  }
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      );
}
