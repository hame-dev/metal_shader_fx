import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/metal_material_config.dart';

/// Physically-based metallic border shine painter.
///
/// Implements a Cook-Torrance microfacet BRDF adapted for a 1D border ring:
///
/// ```
/// f(l,v) = D(h) · F(l,h) · G(l,v,h) / (4 · (n·l) · (n·v))
/// ```
///
/// Where:
/// - **D** = GGX / Trowbridge-Reitz normal distribution
/// - **F** = Schlick Fresnel with configurable F0 for metals
/// - **G** = Smith height-correlated masking-shadowing
///
/// Additional layers:
/// - Dual-lobe environment map (key + fill light)
/// - Radial cross-section lighting (convex torus profile)
/// - Per-channel thin-film interference (R/G/B wavelengths)
/// - Inverse-square distance attenuation
/// - Multi-frequency micro-scratch shimmer
/// - Corner caustics with radial bloom (rounded rects)
/// - Energy conservation via running budget
class PhysicalMetalShinePainter extends CustomPainter {
  /// Current rotation angle of the light source in radians.
  final double rotation;

  /// Overall energy/brightness of the effect (0.0 = off, 1.0 = full).
  final double energy;

  /// Base tint color for the metallic shine.
  final Color tint;

  /// Border radius for rounded rectangle shapes.
  final double borderRadius;

  /// Width of the metallic ring stroke.
  final double ringWidth;

  /// Whether the shape is a circle (`true`) or rounded rect (`false`).
  final bool isCircle;

  /// Physical material configuration.
  final MetalMaterialConfig material;

  PhysicalMetalShinePainter({
    required this.rotation,
    required this.energy,
    required this.tint,
    required this.borderRadius,
    required this.ringWidth,
    required this.isCircle,
    this.material = const MetalMaterialConfig(),
  });

  // ══════════════════════════════════════════════════════════════════
  //  PHYSICS HELPERS
  // ══════════════════════════════════════════════════════════════════

  /// Schlick Fresnel: F(θ) = F0 + (1 - F0)(1 - cosθ)^5
  double _fresnel(double cosTheta) {
    final x = (1.0 - cosTheta).clamp(0.0, 1.0);
    return material.f0 + (1.0 - material.f0) * x * x * x * x * x;
  }

  /// GGX (Trowbridge-Reitz) NDF, normalized so peak = 1.0
  /// [t] ∈ [0, 1] : 0 = on-axis, 1 = 90° off-axis
  double _ggxNDF(double t) {
    final cosH = math.cos(t * math.pi * 0.5);
    final a2 = material.roughness * material.roughness;
    final d = a2 / (math.pi * math.pow(cosH * cosH * (a2 - 1.0) + 1.0, 2.0));
    final dPeak = a2 / (math.pi * a2 * a2);
    return (d / dPeak).clamp(0.0, 1.0);
  }

  /// Smith height-correlated masking-shadowing for GGX.
  double _smithG(double cosL, double cosV) {
    double g1(double cosX) {
      if (cosX <= 0) return 0.0;
      final a2 = material.roughness * material.roughness;
      return 2.0 *
          cosX /
          (cosX + math.sqrt(a2 + (1.0 - a2) * cosX * cosX));
    }
    return g1(cosL) * g1(cosV);
  }

  /// Inverse-square distance attenuation.
  double _distanceAttenuation(double angularOffset) {
    final sinHalf =
        math.sin(angularOffset.abs().clamp(0.0, math.pi) * 0.5);
    final d = material.lightDistance + 2.0 * sinHalf;
    final d0 = material.lightDistance;
    return math.pow(d0 / d, 2.0 * material.distanceFalloffStrength).toDouble();
  }

  /// Thin-film interference — per-channel.
  /// Evaluates at λ_R=620nm, λ_G=530nm, λ_B=460nm.
  List<double> _thinFilmRGB(double cosTheta) {
    const n = 1.45;
    final d = material.filmThickness * 400.0;
    final opticalPath = 2.0 * n * d * cosTheta;
    double ch(double wl) => 0.5 + 0.5 * math.cos(2.0 * math.pi * opticalPath / wl);
    return [ch(620.0), ch(530.0), ch(460.0)];
  }

  Color _applyThinFilm(Color base, double cosTheta) {
    if (material.filmThickness <= 0.001) return base;
    final rgb = _thinFilmRGB(cosTheta);
    return Color.fromARGB(
      base.alpha,
      (base.red * rgb[0]).round().clamp(0, 255),
      (base.green * rgb[1]).round().clamp(0, 255),
      (base.blue * rgb[2]).round().clamp(0, 255),
    );
  }

  /// 5-frequency micro-scratch shimmer.
  double _shimmer(double angle) {
    return 0.35 * math.sin(angle * 7.0) +
        0.25 * math.sin(angle * 16.3 + 0.8) +
        0.18 * math.sin(angle * 31.7 + 2.1) +
        0.12 * math.sin(angle * 53.1 + 4.6) +
        0.10 * math.sin(angle * 97.3 + 1.4);
  }

  /// Anisotropic stretch factor.
  double _anisotropicStretch(double lightAngle) {
    final alignment =
        math.cos(2.0 * (lightAngle - material.brushAngle));
    return 1.0 + material.anisotropy * alignment;
  }

  // ══════════════════════════════════════════════════════════════════
  //  PAINT
  // ══════════════════════════════════════════════════════════════════

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final drawRect = rect.deflate(ringWidth * 0.5);

    // ── Derived colors ──
    final metalDark = Color.lerp(tint, const Color(0xFF111111), 0.82)!;
    final metalMid = Color.lerp(tint, const Color(0xFF7A7A7A), 0.52)!;
    final tintBright = Color.lerp(tint, Colors.white, 0.42)!;
    final white98 = Colors.white.withOpacity(0.98);

    // ── Shimmer ──
    final shim = _shimmer(rotation);
    final liveEnergy = energy * (0.82 + 0.18 * shim);

    // ── Path ──
    final path = Path();
    if (isCircle) {
      path.addOval(drawRect);
    } else {
      path.addRRect(
        RRect.fromRectAndRadius(drawRect, Radius.circular(borderRadius)),
      );
    }

    // ==================================================================
    //  Layer 0: Radial cross-section lighting
    // ==================================================================
    final outerRingRect = rect.deflate(ringWidth * 0.15);
    final innerRingRect = rect.deflate(ringWidth * 0.85);

    final outerPath = Path();
    final innerPath = Path();
    if (isCircle) {
      outerPath.addOval(outerRingRect);
      innerPath.addOval(innerRingRect);
    } else {
      outerPath.addRRect(RRect.fromRectAndRadius(
          outerRingRect, Radius.circular(borderRadius + ringWidth * 0.35)));
      innerPath.addRRect(RRect.fromRectAndRadius(
          innerRingRect, Radius.circular(borderRadius - ringWidth * 0.35)));
    }

    canvas.drawPath(
      outerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth * 0.35
        ..color = Colors.white.withOpacity(0.12 * energy),
    );
    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth * 0.35
        ..color = Colors.black.withOpacity(0.08 * energy),
    );

    // ==================================================================
    //  Layer 1: Dual-lobe environment map (Key + Fill)
    // ==================================================================
    final filmNormal = _applyThinFilm(tintBright, 0.92);
    final filmGrazing = _applyThinFilm(tintBright, 0.25);
    final keyBright1 = Color.lerp(filmNormal, Colors.white, 0.35)!;
    final keyBright2 = Color.lerp(filmGrazing, Colors.white, 0.35)!;

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..shader = SweepGradient(
          transform: GradientRotation(rotation),
          colors: [
            metalDark, metalMid, white98, keyBright1,
            metalDark, metalMid, keyBright2, metalDark,
          ],
          stops: const [0.0, 0.13, 0.22, 0.36, 0.50, 0.63, 0.77, 1.0],
        ).createShader(rect),
    );

    // Fill light sweep
    final fillOffset = rotation + math.pi * 0.72;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth * 0.7
        ..shader = SweepGradient(
          transform: GradientRotation(fillOffset),
          colors: [
            Colors.transparent,
            metalMid.withOpacity(0.25),
            Colors.white.withOpacity(0.35),
            metalMid.withOpacity(0.20),
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: const [0.0, 0.10, 0.18, 0.28, 0.38, 0.50, 0.75, 1.0],
        ).createShader(rect),
    );

    // ==================================================================
    //  Layer 2: Fresnel rim
    // ==================================================================
    _drawFresnelRim(canvas, path, rect, rotation);

    // ==================================================================
    //  Layers 3–5: Cook-Torrance specular lobes
    // ==================================================================
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final pathLength = metric.length;

    double remainingEnergy = 1.0;

    // Primary specular (key light)
    final aniso = _anisotropicStretch(rotation);
    final primaryFraction = 0.13 * liveEnergy * aniso;
    final primarySpent = _drawCookTorranceHighlight(
      canvas: canvas,
      metric: metric,
      pathLength: pathLength,
      lightAngle: rotation,
      fraction: primaryFraction,
      maxOpacity: 0.95 * liveEnergy,
      strokeWidthRatio: 0.72,
      energyBudget: remainingEnergy,
      useThinFilm: true,
    );
    remainingEnergy = (remainingEnergy - primarySpent * 0.6).clamp(0.05, 1.0);

    // Secondary specular (fill light)
    final fillAngle = rotation + math.pi * 0.72;
    final fillFraction = 0.08 * energy * aniso;
    final fillSpent = _drawCookTorranceHighlight(
      canvas: canvas,
      metric: metric,
      pathLength: pathLength,
      lightAngle: fillAngle,
      fraction: fillFraction,
      maxOpacity: 0.45 * energy,
      strokeWidthRatio: 0.5,
      energyBudget: remainingEnergy,
      useThinFilm: true,
    );
    remainingEnergy = (remainingEnergy - fillSpent * 0.4).clamp(0.05, 1.0);

    // Rim / back light
    final rimAngle = rotation + math.pi;
    final fresnelBack = _fresnel(0.12);
    _drawCookTorranceHighlight(
      canvas: canvas,
      metric: metric,
      pathLength: pathLength,
      lightAngle: rimAngle,
      fraction: 0.10 * energy * fresnelBack,
      maxOpacity: 0.38 * energy * fresnelBack * remainingEnergy,
      strokeWidthRatio: 0.45,
      energyBudget: remainingEnergy,
      useThinFilm: false,
      overrideColor: Colors.white,
    );

    // ==================================================================
    //  Layer 6: Corner caustics (rrect only)
    // ==================================================================
    if (!isCircle) {
      _drawCornerCausticsWithBloom(
        canvas,
        RRect.fromRectAndRadius(drawRect, Radius.circular(borderRadius)),
        rotation,
        liveEnergy,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  COOK-TORRANCE HIGHLIGHT
  // ══════════════════════════════════════════════════════════════════
  double _drawCookTorranceHighlight({
    required Canvas canvas,
    required PathMetric metric,
    required double pathLength,
    required double lightAngle,
    required double fraction,
    required double maxOpacity,
    required double strokeWidthRatio,
    required double energyBudget,
    required bool useThinFilm,
    Color? overrideColor,
  }) {
    if (fraction <= 0.002 || energyBudget <= 0.01) return 0.0;

    final normalizedAngle =
        ((lightAngle % (math.pi * 2)) / (math.pi * 2)) * pathLength;
    final halfArc = pathLength * fraction * 0.5;

    double totalSpent = 0.0;
    final totalSteps = material.ggxTailSteps;

    for (int i = 0; i <= totalSteps; i++) {
      final t = i / totalSteps.toDouble();
      final ndf = _ggxNDF(t);
      if (ndf < 0.005) continue;

      final cosTheta = math.cos(t * math.pi * 0.48);
      final fres = _fresnel(cosTheta);
      final g = _smithG(cosTheta, 0.9);
      final dist = _distanceAttenuation(t * fraction * math.pi);
      final brdf = (ndf * fres * g * dist).clamp(0.0, 1.0);
      final segmentOpacity =
          (maxOpacity * brdf * energyBudget).clamp(0.0, 1.0);

      if (segmentOpacity < 0.003) continue;

      Color segColor;
      if (overrideColor != null) {
        segColor = overrideColor;
      } else {
        final baseColor =
            useThinFilm ? _applyThinFilm(tint, cosTheta) : tint;
        final bright = Color.lerp(baseColor, Colors.white, 0.4)!;
        segColor = Color.lerp(bright, Colors.white, fres * 0.6)!;
      }

      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth * strokeWidthRatio * (1.0 - t * 0.35)
        ..strokeCap = StrokeCap.round
        ..color = segColor.withOpacity(segmentOpacity);

      if (i == 0) {
        _drawWrappedSegment(canvas, metric, pathLength,
            normalizedAngle - halfArc * 0.25, normalizedAngle + halfArc * 0.25, segPaint);
      } else {
        final innerT = (i - 1) / totalSteps.toDouble();
        final segStart = halfArc * (0.25 + 0.75 * innerT);
        final segEnd = halfArc * (0.25 + 0.75 * t);
        _drawWrappedSegment(canvas, metric, pathLength,
            normalizedAngle + segStart, normalizedAngle + segEnd, segPaint);
        _drawWrappedSegment(canvas, metric, pathLength,
            normalizedAngle - segEnd, normalizedAngle - segStart, segPaint);
      }

      totalSpent += segmentOpacity * (1.0 / totalSteps);
    }

    return totalSpent.clamp(0.0, 1.0);
  }

  // ══════════════════════════════════════════════════════════════════
  //  FRESNEL RIM
  // ══════════════════════════════════════════════════════════════════
  void _drawFresnelRim(
      Canvas canvas, Path shapePath, Rect rect, double lightAngle) {
    final metrics = shapePath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final len = metric.length;

    for (final offset in [0.25, -0.25]) {
      final rimPos = ((lightAngle / (math.pi * 2)) + offset) * len;
      final arcLen = len * 0.08 * energy;
      final cosTheta = math.cos(offset.abs() * math.pi * 2.0).abs();
      final fres = _fresnel(cosTheta);
      final rimColor =
          Color.lerp(_applyThinFilm(tint, cosTheta), Colors.white, 0.65)!;

      _drawWrappedSegment(
        canvas,
        metric,
        len,
        rimPos - arcLen * 0.5,
        rimPos + arcLen * 0.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * 0.5
          ..strokeCap = StrokeCap.round
          ..color = rimColor.withOpacity(0.20 * energy * fres),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  CORNER CAUSTICS WITH BLOOM
  // ══════════════════════════════════════════════════════════════════
  void _drawCornerCausticsWithBloom(
      Canvas canvas, RRect rrect, double lightAngle, double liveEnergy) {
    final center = Offset(
      (rrect.left + rrect.right) * 0.5,
      (rrect.top + rrect.bottom) * 0.5,
    );

    final corners = [
      Offset(rrect.left + rrect.tlRadiusX, rrect.top + rrect.tlRadiusY),
      Offset(rrect.right - rrect.trRadiusX, rrect.top + rrect.trRadiusY),
      Offset(rrect.right - rrect.brRadiusX, rrect.bottom - rrect.brRadiusY),
      Offset(rrect.left + rrect.blRadiusX, rrect.bottom - rrect.blRadiusY),
    ];

    for (final corner in corners) {
      final dx = corner.dx - center.dx;
      final dy = corner.dy - center.dy;
      final cornerAngle = math.atan2(dy, dx);
      final alignment = math.cos(cornerAngle - lightAngle);
      if (alignment < 0.25) continue;

      final intensity = alignment * liveEnergy;
      final causticRadius = borderRadius * 0.55;

      // Bloom
      canvas.drawCircle(
        corner,
        causticRadius * 2.2,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors: [
              Color.lerp(tint, Colors.white, 0.7)!
                  .withOpacity(0.18 * intensity),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: corner, radius: causticRadius * 2.2)),
      );

      // Sharp caustic arc
      canvas.drawArc(
        Rect.fromCircle(center: corner, radius: causticRadius),
        cornerAngle - 0.35,
        0.70,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * 0.3
          ..strokeCap = StrokeCap.round
          ..color =
              Colors.white.withOpacity((0.55 * intensity).clamp(0.0, 1.0)),
      );

      // Thin-film tinted caustic
      final filmCaustic = _applyThinFilm(tint, alignment);
      canvas.drawArc(
        Rect.fromCircle(center: corner, radius: causticRadius * 1.15),
        cornerAngle - 0.5,
        1.0,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * 0.2
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(filmCaustic, Colors.white, 0.5)!
              .withOpacity((0.3 * intensity).clamp(0.0, 1.0)),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  SEGMENT HELPER
  // ══════════════════════════════════════════════════════════════════
  void _drawWrappedSegment(
    Canvas canvas,
    PathMetric metric,
    double length,
    double start,
    double end,
    Paint paint,
  ) {
    start = start % length;
    if (start < 0) start += length;
    end = end % length;
    if (end < 0) end += length;

    if (start < end) {
      canvas.drawPath(metric.extractPath(start, end), paint);
    } else {
      canvas.drawPath(metric.extractPath(start, length), paint);
      canvas.drawPath(metric.extractPath(0, end), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PhysicalMetalShinePainter old) {
    return old.rotation != rotation ||
        old.energy != energy ||
        old.tint != tint ||
        old.borderRadius != borderRadius ||
        old.ringWidth != ringWidth ||
        old.isCircle != isCircle;
  }
}
