import 'package:flutter/material.dart';

class DialogueView extends StatelessWidget {
  final String npcName;
  final String content;
  final List<String> choices;
  final Function(int) onChoice;

  const DialogueView({
    super.key,
    required this.npcName,
    required this.content,
    required this.choices,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
        children: [
          Text(
            npcName,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ...choices.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onChoice(e.key),
                  child: Text(e.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
