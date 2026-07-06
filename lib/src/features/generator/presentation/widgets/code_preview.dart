import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/generated_file.dart';

class CodePreview extends StatelessWidget {
  const CodePreview({
    super.key,
    required this.file,
  });

  final GeneratedFile? file;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return const Center(
        child: Text(
          'Select or generate a file to preview code',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  file!.path,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file!.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File code copied')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                file!.content,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
