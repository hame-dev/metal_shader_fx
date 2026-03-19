import 'package:flutter/material.dart';

/// Configuration for the physically-based metal material properties.
///
/// Controls the appearance of the metallic shine effect across all widgets.
/// Tweak these to go from mirror-polished chrome to heavily anodized aluminum.
///
/// ```dart
/// MetalMaterialConfig(
///   roughness: 0.05,          // mirror chrome
///   filmThickness: 0.7,       // heavy iridescent anodization
///   anisotropy: 0.0,          // isotropic (polished)
/// )
/// ```
class MetalMaterialConfig {
  /// GGX roughness parameter (α).
  ///
  /// - `0.0` = perfect mirror
  /// - `0.05` = polished chrome
  /// - `0.15` = brushed stainless (default)
  /// - `0.35` = satin finish
  /// - `1.0` = fully diffuse
  final double roughness;

  /// Base Fresnel reflectance (F0) for the metal.
  ///
  /// Metals have high F0 values:
  /// - Gold ≈ 0.95
  /// - Silver ≈ 0.97
  /// - Aluminum ≈ 0.91
  /// - Default: `0.88`
  final double f0;

  /// Thin-film oxide layer thickness (normalized 0..1).
  ///
  /// Controls the iridescent color shift from the anodized oxide layer.
  /// - `0.0` = bare metal (no color shift)
  /// - `0.38` = subtle anodization (default)
  /// - `0.7` = heavy iridescence with spectral separation
  /// - `1.0` = maximum thin-film effect
  final double filmThickness;

  /// Anisotropy of the surface micro-scratches.
  ///
  /// Controls how directional the highlight stretches.
  /// - `0.0` = isotropic (polished)
  /// - `0.30` = light brushing (default)
  /// - `0.8` = heavily brushed / lathe-turned
  final double anisotropy;

  /// Direction of the surface brush pattern in radians.
  ///
  /// `0.0` = horizontal brushing (default).
  /// `π/2` = vertical brushing.
  final double brushAngle;

  /// Normalized distance of the virtual light source from the center.
  ///
  /// Controls how much the far side dims via inverse-square falloff.
  /// - `2.0` = close light (strong falloff)
  /// - `3.0` = moderate (default)
  /// - `6.0` = distant light (nearly uniform)
  final double lightDistance;

  /// Strength of the inverse-square distance falloff.
  ///
  /// - `0.0` = no falloff
  /// - `0.25` = subtle (default)
  /// - `0.5` = strong falloff on the far side
  final double distanceFalloffStrength;

  /// Number of sub-segments for the GGX specular tail.
  ///
  /// More steps = smoother falloff. `6` is a good balance (default).
  /// `10` for ultra-smooth on high-end devices, `3` for performance.
  final int ggxTailSteps;

  /// Width of the metallic border ring in logical pixels.
  ///
  /// If `null`, each widget uses its own default.
  final double? ringWidth;

  /// Duration of one full shine rotation cycle.
  ///
  /// If `null`, each widget uses its own default.
  final Duration? shineDuration;

  const MetalMaterialConfig({
    this.roughness = 0.15,
    this.f0 = 0.88,
    this.filmThickness = 0.38,
    this.anisotropy = 0.30,
    this.brushAngle = 0.0,
    this.lightDistance = 3.0,
    this.distanceFalloffStrength = 0.25,
    this.ggxTailSteps = 6,
    this.ringWidth,
    this.shineDuration,
  });

  /// Polished chrome preset — mirror-like, no anodization.
  const MetalMaterialConfig.chrome()
      : roughness = 0.05,
        f0 = 0.95,
        filmThickness = 0.0,
        anisotropy = 0.0,
        brushAngle = 0.0,
        lightDistance = 3.0,
        distanceFalloffStrength = 0.25,
        ggxTailSteps = 6,
        ringWidth = null,
        shineDuration = null;

  /// Brushed stainless steel preset.
  const MetalMaterialConfig.brushedSteel()
      : roughness = 0.22,
        f0 = 0.88,
        filmThickness = 0.08,
        anisotropy = 0.65,
        brushAngle = 0.0,
        lightDistance = 3.5,
        distanceFalloffStrength = 0.20,
        ggxTailSteps = 6,
        ringWidth = null,
        shineDuration = null;

  /// Heavy anodized aluminum — strong iridescent color shift.
  const MetalMaterialConfig.anodized()
      : roughness = 0.12,
        f0 = 0.91,
        filmThickness = 0.70,
        anisotropy = 0.15,
        brushAngle = 0.0,
        lightDistance = 3.0,
        distanceFalloffStrength = 0.30,
        ggxTailSteps = 6,
        ringWidth = null,
        shineDuration = null;

  /// Gold preset — warm, high reflectance, subtle film.
  const MetalMaterialConfig.gold()
      : roughness = 0.08,
        f0 = 0.95,
        filmThickness = 0.25,
        anisotropy = 0.10,
        brushAngle = 0.0,
        lightDistance = 3.0,
        distanceFalloffStrength = 0.20,
        ggxTailSteps = 6,
        ringWidth = null,
        shineDuration = null;

  MetalMaterialConfig copyWith({
    double? roughness,
    double? f0,
    double? filmThickness,
    double? anisotropy,
    double? brushAngle,
    double? lightDistance,
    double? distanceFalloffStrength,
    int? ggxTailSteps,
    double? ringWidth,
    Duration? shineDuration,
  }) {
    return MetalMaterialConfig(
      roughness: roughness ?? this.roughness,
      f0: f0 ?? this.f0,
      filmThickness: filmThickness ?? this.filmThickness,
      anisotropy: anisotropy ?? this.anisotropy,
      brushAngle: brushAngle ?? this.brushAngle,
      lightDistance: lightDistance ?? this.lightDistance,
      distanceFalloffStrength:
          distanceFalloffStrength ?? this.distanceFalloffStrength,
      ggxTailSteps: ggxTailSteps ?? this.ggxTailSteps,
      ringWidth: ringWidth ?? this.ringWidth,
      shineDuration: shineDuration ?? this.shineDuration,
    );
  }
}
