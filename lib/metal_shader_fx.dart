/// Physically-based metallic border shine effects for Flutter.
///
/// Provides three premium widgets with Cook-Torrance BRDF metallic shine:
///
/// - [MetalToggleCard] — A toggle switch with animated metallic thumb
/// - [MetallicBorderButton] — A button with a metallic border shine
/// - [MetallicBorderTextField] — A text field with metallic border shine
///
/// All widgets accept a [MetalMaterialConfig] to tune the physics:
///
/// ```dart
/// MetallicBorderButton(
///   text: 'Submit',
///   color: Colors.deepPurple,
///   onPressed: () {},
///   material: MetalMaterialConfig.chrome(),
/// )
/// ```
///
/// For advanced usage, use [PhysicalMetalShinePainter] directly
/// in your own [CustomPaint] widgets.
library;

export 'src/models/metal_material_config.dart';
export 'src/painters/physical_metal_shine_painter.dart';
export 'src/widgets/metal_toggle_card.dart';
export 'src/widgets/metallic_border_button.dart';
export 'src/widgets/metallic_border_text_field.dart';
