import 'package:flutter/material.dart';

class ContractStepPlaceholder extends StatelessWidget {
  final int step;
  final String title;

  const ContractStepPlaceholder({
    super.key,
    required this.step,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Step $step',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
