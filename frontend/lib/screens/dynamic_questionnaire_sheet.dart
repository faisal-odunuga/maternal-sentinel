import 'package:flutter/material.dart';


class DynamicQuestionnaireSheet extends StatelessWidget {
  const DynamicQuestionnaireSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for dynamic questionnaire UI
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Health Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('This is where the adaptive questionnaire will appear.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
