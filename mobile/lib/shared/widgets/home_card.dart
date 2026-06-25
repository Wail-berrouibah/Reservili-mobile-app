import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/home_model.dart';
import 'soft_card.dart';

class HomeCard extends StatelessWidget {
  final HomeModel home;
  final VoidCallback? onTap;

  const HomeCard({
    super.key,
    required this.home,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              image: home.imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(home.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: home.imageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.home_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  home.name,
                  style: AppTextStyles.title3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!home.isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'Unavailable',
                    style: AppTextStyles.caption1.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  home.address,
                  style: AppTextStyles.footnote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                '\$${home.pricePerNight.toStringAsFixed(0)}',
                style: AppTextStyles.headline.copyWith(color: AppColors.primary),
              ),
              Text(
                ' / night',
                style: AppTextStyles.footnote,
              ),
              const Spacer(),
              Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${home.maxGuests} guests',
                style: AppTextStyles.footnote,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
