import 'package:flutter/material.dart';
import '../services/watchx_database_service.dart';
import '../theme/watchx_theme.dart';

class WatchFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const WatchFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? WatchXColors.goldPrimary : WatchXColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? WatchXColors.goldPrimary : WatchXColors.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: selected ? WatchXColors.bgBlack : WatchXColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class AtelierWatchCard extends StatelessWidget {
  final WatchItem watch;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const AtelierWatchCard({
    super.key,
    required this.watch,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WatchXColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WatchXColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      watch['image_url'].toString(),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.watch,
                          color: WatchXColors.goldPrimary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            WatchXColors.bgBlack.withValues(alpha: 0.75),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: WatchXColors.goldPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              watch['brand']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                letterSpacing: 1.1,
                color: WatchXColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              watch['short_name']?.toString() ?? watch['name'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WatchXColors.textWhite,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatWatchPrice(watch['price']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: WatchXColors.goldPrimary,
                  ),
                ),
                Text(
                  watch['spec_tag']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 9,
                    color: WatchXColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogWatchCard extends StatelessWidget {
  final WatchItem watch;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onQuickAddTap;
  final VoidCallback onTap;

  const CatalogWatchCard({
    super.key,
    required this.watch,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onQuickAddTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WatchXColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WatchXColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      watch['image_url'].toString(),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.watch,
                          color: WatchXColors.goldPrimary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: WatchXColors.bgBlack.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        watch['badge']?.toString() ?? 'IN VAULT',
                        style: const TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.0,
                          color: WatchXColors.goldPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            WatchXColors.bgBlack.withValues(alpha: 0.75),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: WatchXColors.goldPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              watch['brand']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                letterSpacing: 1.1,
                color: WatchXColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              watch['name']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WatchXColors.textWhite,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 12,
                  color: WatchXColors.goldPrimary,
                ),
                const SizedBox(width: 3),
                Text(
                  '${watch['rating']} (${watch['reviews']})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: WatchXColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatWatchPrice(watch['price']),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WatchXColors.goldPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onQuickAddTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: WatchXColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: WatchXColors.borderDark),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 14,
                      color: WatchXColors.goldPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AtelierTrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AtelierTrustBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: WatchXColors.goldPrimary),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 0.9,
            color: WatchXColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: WatchXColors.textWhite),
        ),
      ],
    );
  }
}