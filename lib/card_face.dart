import 'package:flutter/material.dart';
import 'data.dart';

class CardFaceWidget extends StatelessWidget {
  final Flashcard card;
  final bool showFront;
  final bool isDarkMode;

  const CardFaceWidget({
    super.key,
    required this.card,
    required this.showFront,
    required this.isDarkMode,
  });

  Color _getArticleColor(String article) {
    final a = article.toLowerCase().trim();
    if (a == 'der') return const Color(0xFF2563EB); // blue
    if (a == 'die') return const Color(0xFFE11D48); // pink/red
    if (a == 'das') return const Color(0xFF059669); // emerald
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0B132B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black.withOpacity(0.06),
            blurRadius: isDarkMode ? 20 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Category Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.category.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.grey : const Color(0xFF475569),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Center German Word or Russian Translation
          showFront
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (card.article.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getArticleColor(card.article),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card.article,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      card.german,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 27,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Нажмите, чтобы перевернуть карточку',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.russian,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.amberAccent : const Color(0xFFB45309),
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        height: 1.2,
                      ),
                    ),
                    if (card.explanation.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          card.explanation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : const Color(0xFF334155),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

          // Bottom Swipe Guidance
          Text(
            'Свайп влево: Повторить · Свайп вправо: Знаю',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
