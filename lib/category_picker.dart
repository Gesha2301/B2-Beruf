import 'package:flutter/material.dart';
import 'data.dart';

void showCategoryPickerBottomSheet(
  BuildContext context, {
  required bool isDarkMode,
  required String selectedCategory,
  required Function(String) onSelect,
}) {
  final categories = ['Все карточки', ...getUniqueCategories()];
  final counts = getCategoryCounts();

  showModalBottomSheet(
    context: context,
    backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ВЫБОР МОДУЛЯ / ТЕМЫ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final cnt = cat == 'Все карточки' ? initialB2Dataset.length : (counts[cat] ?? 0);
                final isSel = cat == selectedCategory;
                return ListTile(
                  tileColor: isSel
                      ? (isDarkMode ? Colors.redAccent.withAlpha(40) : Colors.red.shade50)
                      : null,
                  title: Text(
                    cat,
                    style: TextStyle(
                      color: isSel
                          ? (isDarkMode ? Colors.redAccent : const Color(0xFFDC2626))
                          : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '$cnt карт',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelect(cat);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
