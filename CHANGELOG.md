## 0.1.4

- Fix deprecated `withOpacity()` calls — migrated to `withValues(alpha:)` across all widgets
- Fix deprecated `Color.alpha`, `Color.red`, `Color.green`, `Color.blue` getters — migrated to new `Color.a`, `Color.r`, `Color.g`, `Color.b` API
- Remove unused `package:flutter/material.dart` import from `MetalMaterialConfig`
- Remove unnecessary library name from barrel export file

## 0.1.3

- Fix package name import

## 0.1.2

- Add images to README

## 0.1.1

- Initial release
- `MetalToggleCard` — animated toggle with metallic thumb shine
- `MetallicBorderButton` — button with Cook-Torrance BRDF border shine
- `MetallicBorderTextField` — text field with focus-responsive metallic border
- `PhysicalMetalShinePainter` — standalone painter for custom widgets
- `MetalMaterialConfig` — full material property control with presets:
  - `.chrome()` — polished mirror
  - `.brushedSteel()` — directional anisotropic
  - `.anodized()` — heavy iridescent thin-film
  - `.gold()` — warm high-reflectance
- Cook-Torrance microfacet BRDF (GGX NDF + Schlick Fresnel + Smith G)
- Per-channel thin-film interference (620nm / 530nm / 460nm)
- Anisotropic highlight stretch with configurable brush direction
- Energy conservation via running budget
- Dual-lobe environment map (key + fill light)
- Corner caustics with radial bloom
- Inverse-square distance attenuation
- 5-frequency micro-scratch shimmer
- Radial cross-section torus lighting
