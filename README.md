# metallic_shine

Physically-based metallic border shine effects for Flutter widgets. Features a full **Cook-Torrance microfacet BRDF** adapted for UI border rings — the same math used in game engines and 3D renderers, now running on your buttons, toggles, and text fields.

![metallic shine preview](assets/images/image.gif)

## Features

- **Cook-Torrance BRDF** — GGX normal distribution, Schlick Fresnel, Smith G masking-shadowing
- **Thin-film interference** — per-channel (R/G/B wavelength) spectral color separation simulating anodized aluminum
- **Anisotropic highlights** — configurable brush direction and stretch for brushed metal looks
- **Energy conservation** — running budget prevents physically impossible over-brightening
- **Dual-lobe environment map** — key + fill light simulating studio 3-point lighting
- **Corner caustics with bloom** — light concentration at rounded corners with soft radial glow
- **Inverse-square falloff** — far side of the border dims naturally
- **5-frequency micro-scratch shimmer** — non-harmonic sine layers eliminate digital repetition
- **Radial cross-section lighting** — convex torus profile with bright crown and shadow bevel

## Widgets

| Widget | Description |
|---|---|
| `MetalToggleCard` | Toggle switch card with animated metallic thumb |
| `MetallicBorderButton` | Button with metallic border shine |
| `MetallicBorderTextField` | Text field with metallic border that intensifies on focus |

## Installation

```yaml
dependencies:
  metallic_shine: ^1.0.0
```

## Quick Start

```dart
import 'package:metallic_shine/metallic_shine.dart';

// Toggle
MetalToggleCard(
  value: _enabled,
  onChanged: (v) => setState(() => _enabled = v),
  accentColor: const Color(0xFFE3AA00),
);

// Button
MetallicBorderButton(
  text: 'Continue',
  color: const Color(0xFF55267E),
  onPressed: () => print('tapped'),
);

// Text field
MetallicBorderTextField(
  controller: _controller,
  hintText: 'Enter your email',
  color: const Color(0xFFE3AA00),
  onChanged: (value) => print(value),
);
```

## Material Presets

Use built-in presets or create your own:

```dart
// Polished chrome — mirror-like, no anodization
MetallicBorderButton(
  text: 'Chrome',
  color: Colors.blue,
  onPressed: () {},
  material: const MetalMaterialConfig.chrome(),
);

// Brushed stainless steel
material: const MetalMaterialConfig.brushedSteel()

// Heavy anodized aluminum — strong iridescence
material: const MetalMaterialConfig.anodized()

// Gold — warm, high reflectance
material: const MetalMaterialConfig.gold()

// Custom
material: const MetalMaterialConfig(
  roughness: 0.10,      // 0 = mirror, 1 = diffuse
  f0: 0.92,             // Fresnel base reflectance
  filmThickness: 0.5,   // thin-film iridescence strength
  anisotropy: 0.4,      // brush direction stretch
  brushAngle: 1.57,     // vertical brushing (π/2)
)
```

## MetalMaterialConfig Properties

| Property | Default | Description |
|---|---|---|
| `roughness` | `0.15` | GGX α (0 = mirror, 1 = diffuse) |
| `f0` | `0.88` | Base Fresnel reflectance |
| `filmThickness` | `0.38` | Thin-film oxide layer (0 = bare, 1 = max iridescence) |
| `anisotropy` | `0.30` | Directional stretch (0 = isotropic, 1 = fully anisotropic) |
| `brushAngle` | `0.0` | Brush direction in radians |
| `lightDistance` | `3.0` | Virtual light distance (affects falloff) |
| `distanceFalloffStrength` | `0.25` | Inverse-square falloff intensity |
| `ggxTailSteps` | `6` | GGX sub-segments (more = smoother, costlier) |
| `ringWidth` | per-widget | Border ring stroke width |
| `shineDuration` | per-widget | Full rotation cycle duration |

## Widget API Reference

### MetalToggleCard

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `bool` | required | Toggle state |
| `onChanged` | `ValueChanged<bool>` | required | State change callback |
| `accentColor` | `Color` | required | Shine tint color |
| `width` | `double?` | stretches | Card width |
| `height` | `double` | `142` | Card height |
| `enabledLabel` | `String` | `'Enabled'` | On-state text |
| `disabledLabel` | `String` | `'Disabled'` | Off-state text |
| `toggleWidth` | `double` | `170` | Toggle track width |
| `toggleHeight` | `double` | `92` | Toggle track height |
| `thumbSize` | `double` | `74` | Thumb diameter |
| `material` | `MetalMaterialConfig` | default | Physics config |

### MetallicBorderButton

| Property | Type | Default | Description |
|---|---|---|---|
| `text` | `String?` | — | Button label |
| `child` | `Widget?` | — | Custom content (overrides text) |
| `color` | `Color` | required | Button color and shine tint |
| `onPressed` | `VoidCallback?` | — | Tap callback |
| `onLongPress` | `VoidCallback?` | — | Long-press callback |
| `width` | `double?` | content-sized | Fixed width |
| `height` | `double` | `64` | Button height |
| `borderRadius` | `double` | `22` | Corner radius |
| `enabled` | `bool` | `true` | Enable/disable |
| `textStyle` | `TextStyle?` | white/18/w600 | Label style |
| `material` | `MetalMaterialConfig` | default | Physics config |

### MetallicBorderTextField

| Property | Type | Default | Description |
|---|---|---|---|
| `controller` | `TextEditingController?` | auto-created | Text controller |
| `color` | `Color` | required | Shine tint color |
| `hintText` | `String?` | — | Hint text |
| `labelText` | `String?` | — | Label text |
| `onChanged` | `ValueChanged<String>?` | — | Text change callback |
| `onSubmitted` | `ValueChanged<String>?` | — | Submit callback |
| `onFocusChanged` | `ValueChanged<bool>?` | — | Focus change callback |
| `onTap` | `VoidCallback?` | — | Tap callback |
| `width` | `double?` | stretches | Fixed width |
| `height` | `double` | `64` | Field height |
| `borderRadius` | `double` | `22` | Corner radius |
| `enabled` | `bool` | `true` | Enable/disable |
| `obscureText` | `bool` | `false` | Password mode |
| `maxLines` | `int` | `1` | Max lines |
| `maxLength` | `int?` | — | Max text length |
| `keyboardType` | `TextInputType?` | — | Keyboard type |
| `textInputAction` | `TextInputAction?` | — | Input action |
| `inputFormatters` | `List<TextInputFormatter>?` | — | Input restrictions |
| `prefixIcon` | `Widget?` | — | Prefix icon |
| `suffixIcon` | `Widget?` | — | Suffix icon |
| `focusNode` | `FocusNode?` | auto-created | External focus node |
| `material` | `MetalMaterialConfig` | default | Physics config |

## Advanced: Using the Painter Directly

For custom widgets, use `PhysicalMetalShinePainter` in any `CustomPaint`:

```dart
CustomPaint(
  foregroundPainter: PhysicalMetalShinePainter(
    rotation: _animationController.value * 3.14159 * 2,
    energy: 1.0,
    tint: Colors.amber,
    borderRadius: 16,
    ringWidth: 3.0,
    isCircle: false,
    material: const MetalMaterialConfig.gold(),
  ),
  child: YourWidget(),
)
```

## Shoutout

Shoutout to [@aligrids](https://x.com/aligrids?s=21&t=eUd6PuHrSUYHPnXfrQkxZA) for sparking the idea.

## License

MIT
