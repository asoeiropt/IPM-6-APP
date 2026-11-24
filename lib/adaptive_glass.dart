import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_data.dart';

/// Ativa o visual Liquid Glass APENAS no iPhone (e nunca no Modo Alto Contraste)
bool get isIosLiquidGlass =>
    !kIsWeb &&
    defaultTargetPlatform == TargetPlatform.iOS &&
    !isHighContrast;

/// Container reutilizável:
/// - No iPhone: aplica vidro translúcido com blur e borda especular
/// - No Android / Web: mantém exatamente o cartão escuro atual
class AdaptiveGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color fallbackColor;
  final Color fallbackBorderColor;

  const AdaptiveGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.fallbackColor = const Color(0xFF141923),
    this.fallbackBorderColor = const Color(0x0DFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (!isIosLiquidGlass) {
      // Android, Web e Alto Contraste mantêm o design original intacto
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: isHighContrast ? Colors.black : fallbackColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isHighContrast
                ? const Color(0xFFFFD600)
                : fallbackBorderColor,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        child: child,
      );
    }

    // No iPhone: efeito Liquid Glass
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}