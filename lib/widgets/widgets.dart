import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

// ─── BOUTON PRINCIPAL ─────────────────────────────────────────────
class WajbaButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onTap;
  final bool     isLoading;
  final IconData? icon;
  final Color?   color;

  const WajbaButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: isLoading ? null : onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? WajbaColors.primary,
    ),
    child: isLoading
        ? const SizedBox(height: 20, width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          ),
  );
}

// ─── IMAGE RÉSEAU ─────────────────────────────────────────────────
class WajbaImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit  fit;
  final BorderRadius? radius;

  const WajbaImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit    = BoxFit.cover,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final img = CachedNetworkImage(
      imageUrl: url,
      width:  width,
      height: height,
      fit:    fit,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor:     WajbaColors.grey200,
        highlightColor: WajbaColors.grey100,
        child: Container(color: WajbaColors.grey200, width: width, height: height),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width, height: height,
        color: WajbaColors.grey100,
        child: const Icon(Icons.restaurant, color: WajbaColors.grey400, size: 40),
      ),
    );

    if (radius != null) {
      return ClipRRect(borderRadius: radius!, child: img);
    }
    return img;
  }
}

// ─── CHIP CATÉGORIE ───────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String  label;
  final bool    selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? WajbaColors.primary : WajbaColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? WajbaColors.primary : WajbaColors.grey200,
        ),
        boxShadow: selected ? [
          BoxShadow(color: WajbaColors.primary.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 2))
        ] : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? WajbaColors.white : WajbaColors.grey600,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
    ),
  );
}

// ─── BADGE STATUT COMMANDE ────────────────────────────────────────
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge(this.status, {super.key});

  Color get _color {
    switch (status) {
      case 'delivered':  return WajbaColors.success;
      case 'cancelled':  return WajbaColors.error;
      case 'delivering': return WajbaColors.primary;
      case 'preparing':  return WajbaColors.warning;
      default:           return WajbaColors.grey400;
    }
  }

  String get _label {
    switch (status) {
      case 'pending':    return 'En attente';
      case 'confirmed':  return 'Confirmée';
      case 'preparing':  return 'En préparation';
      case 'ready':      return 'Prête';
      case 'delivering': return 'En livraison';
      case 'delivered':  return 'Livrée';
      case 'cancelled':  return 'Annulée';
      default:           return status;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      _label,
      style: TextStyle(
        color: _color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── EMPTY STATE ──────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final String?  buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(kPaddingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: WajbaColors.grey200),
          const SizedBox(height: 16),
          Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                                   color: WajbaColors.grey800)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: WajbaColors.grey600)),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: 24),
            SizedBox(width: 200,
              child: WajbaButton(label: buttonLabel!, onTap: onButton)),
          ],
        ],
      ),
    ),
  );
}

// ─── SNACKBAR HELPER ──────────────────────────────────────────────
void showSnack(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: isError ? WajbaColors.error : WajbaColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}
