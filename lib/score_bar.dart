import 'package:flutter/material.dart';
import 'data.dart';

class DmcScoreBar extends StatelessWidget {
  final int score;
  final int combo;
  final int mastered;
  final int total;
  final int queueLength;
  final Rank rank;

  const DmcScoreBar({
    super.key,
    required this.score,
    required this.combo,
    required this.mastered,
    required this.total,
    required this.queueLength,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (mastered / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: combo >= 4
            ? [BoxShadow(color: rank.color.withAlpha(35), blurRadius: 18, spreadRadius: 1)]
            : null,
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
                      const Text('SCORE ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('$score', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('COMBO ', style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w900)),
                      Text('$combo STREAK', style: TextStyle(color: rank.color, fontSize: 14, fontWeight: FontWeight.w900)),
                      if (rank.mult > 1) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: Colors.amberAccent.withAlpha(40), borderRadius: BorderRadius.circular(4)),
                          child: Text('x${rank.mult}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('STYLE RANK', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w900)),
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
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(rank.color),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Выучено: $mastered / $total', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text('В очереди: $queueLength', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
