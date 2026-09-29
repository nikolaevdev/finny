import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A small illustrated chapter header shared by the game screens.
class AdventureBanner extends StatelessWidget {
  const AdventureBanner({
    super.key,
    required this.title,
    required this.icon,
    this.color = AppColors.purple,
    this.imageAsset = 'assets/images/home/explorer_room_story.webp',
    this.height = 94,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String imageAsset;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.textPrimary.withValues(alpha: .94),
                      color.withValues(alpha: .84),
                      color.withValues(alpha: .34),
                    ],
                    stops: const [0, .67, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Icon(icon, color: Colors.white, size: 27),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            )),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
}
