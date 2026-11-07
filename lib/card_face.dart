import 'package:flutter/material.dart';
import 'data.dart';

class CardFaceWidget extends StatelessWidget {
  final Flashcard card;
  final bool showFront;

  const CardFaceWidget({super.key, required this.card, required this.showFront});

  Color _getArticleColor(String article) {
    final a = article.toLowerCase().trim();
    if (a == 'der') return const Color(0xFF2563EB); // blue
    if (a == 'die') return const Color(0xFFE11D48); // pink/red
    if (a == 'das') return const Color(0xFF059669); // emerald
    return const Color(0xFF475569);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Category Pill (Screenshot 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 27,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Нажмите, чтобы перевернуть карточку',
                      style: TextStyle(
                        color: Colors.grey,
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
                      style: const TextStyle(
                        color: Colors.amberAccent,
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
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Text(
                          card.explanation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ],
                ),

          // Bottom Swipe Guidance (Screenshot 2)
          const Text(
            'Свайп влево: Повторить · Свайп вправо: Знаю',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
