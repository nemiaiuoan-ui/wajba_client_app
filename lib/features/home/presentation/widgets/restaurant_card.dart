import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/models.dart';

// ═══════════════════════════════════════════════
// RESTAURANT CARD
// ═══════════════════════════════════════════════
class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: r.banner != null
                      ? CachedNetworkImage(imageUrl: r.banner!, height: 140, width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [WajbaColors.primary.withOpacity(0.15), WajbaColors.primaryDark.withOpacity(0.25)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 56))),
                        ),
                ),
                // Closed overlay
                if (!r.isOpen)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 140,
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text('FERMÉ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3, fontFamily: 'Cairo')),
                      ),
                    ),
                  ),
                // Promo tag
                if (r.promoTag != null)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: WajbaColors.primary, borderRadius: BorderRadius.circular(20)),
                      child: Text(r.promoTag!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                    ),
                  ),
                // Verified badge
                if (r.isVerified)
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: WajbaColors.primary, size: 12),
                          SizedBox(width: 3),
                          Text('Vérifié', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: WajbaColors.primary, fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ),
                // Logo
                Positioned(
                  bottom: -20, left: 14,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WajbaColors.grey100, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: r.logo != null
                          ? CachedNetworkImage(imageUrl: r.logo!, fit: BoxFit.cover)
                          : const Center(child: Text('🍽️', style: TextStyle(fontSize: 22))),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 26, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(r.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo'), overflow: TextOverflow.ellipsis),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: WajbaColors.warningBg, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: WajbaColors.star, size: 14),
                            const SizedBox(width: 3),
                            Text(r.ratingLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WajbaColors.grey800, fontFamily: 'Cairo')),
                            const SizedBox(width: 2),
                            Text('(${r.reviewCount})', style: const TextStyle(fontSize: 11, color: WajbaColors.grey400, fontFamily: 'Cairo')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.cuisineType, style: const TextStyle(fontSize: 13, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    children: [
                      _StatChip(icon: Icons.access_time_rounded, label: r.deliveryTimeLabel),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.delivery_dining_rounded,
                        label: r.deliveryFeeLabel,
                        color: r.deliveryFee == 0 ? WajbaColors.success : WajbaColors.grey600,
                      ),
                      if (r.distance != null) ...[
                        const SizedBox(width: 8),
                        _StatChip(icon: Icons.location_on_outlined, label: '${r.distance!.toStringAsFixed(1)} km'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, this.color = WajbaColors.grey600});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// CATEGORY CHIP
// ═══════════════════════════════════════════════
class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.category, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: isSelected ? WajbaColors.primary : WajbaColors.grey100,
                shape: BoxShape.circle,
                boxShadow: isSelected ? [BoxShadow(color: WajbaColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
              ),
              child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 5),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11, fontFamily: 'Cairo',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? WajbaColors.primary : WajbaColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
