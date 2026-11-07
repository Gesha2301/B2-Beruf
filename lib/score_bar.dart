import 'package:flutter/material.dart';
import 'data.dart';

class DmcScoreBar extends StatelessWidget {
  final int score;
  final int combo;
  final int mastered;
  final int total;
  final int queueLength;
  final Rank rank;
  final bool isDarkMode;

  const DmcScoreBar({
    super.key,
    required this.score,
    required this.combo,
    required this.mastered,
    required this.total,
    required this.queueLength,
    required this.rank,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (mastered / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          if (isDarkMode && combo >= 4)
            BoxShadow(color: rank.color.withAlpha(35), blurRadius: 18, spreadRadius: 1)
          else if (!isDarkMode)
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SCORE ',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$score',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'COMBO ',
                        style: TextStyle(
                          color: isDarkMode ? Colors.amberAccent : const Color(0xFFB45309),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$combo STREAK',
                        style: TextStyle(
                          color: rank.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (rank.mult > 1) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'x${rank.mult}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'STYLE RANK',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    rank.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: rank.color,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(rank.color),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Выучено: $mastered / $total',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'В очереди: $queueLength',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
