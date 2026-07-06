import 'package:flutter/material.dart';

import '../../domain/generated_file.dart';

class GeneratedFilesPanel extends StatelessWidget {
  const GeneratedFilesPanel({
    super.key,
    required this.files,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<GeneratedFile> files;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(
        child: Text(
          'Generated files will appear here',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = index == selectedIndex;

        return InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              file.path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
