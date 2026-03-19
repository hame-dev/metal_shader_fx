import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/metal_material_config.dart';
import '../painters/physical_metal_shine_painter.dart';

/// A button with a physically-based metallic border shine animation.
///
/// ```dart
/// MetallicBorderButton(
///   text: 'Continue',
///   color: const Color(0xFF55267E),
///   onPressed: () => print('tapped'),
///   width: 300,
///   height: 64,
/// )
/// ```
///
/// For custom content, use [child] instead of [text]:
///
/// ```dart
/// MetallicBorderButton(
///   color: Colors.blue,
///   onPressed: () {},
///   child: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       Icon(Icons.send, color: Colors.white, size: 18),
///       SizedBox(width: 8),
///       Text('Send', style: TextStyle(color: Colors.white)),
///     ],
///   ),
/// )
/// ```
class MetallicBorderButton extends StatefulWidget {
  /// Button label text. Ignored if [child] is provided.
  final String? text;

  /// Custom child widget. Takes precedence over [text].
  final Widget? child;

  /// Base color of the button fill and metallic shine tint.
  final Color color;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Fixed width. If `null`, sizes to content / parent.
  final double? width;

  /// Button height. Defaults to `64`.
  final double height;

  /// Corner radius. Defaults to `22`.
  final double borderRadius;

  /// Physical material properties for the border shine.
  final MetalMaterialConfig material;

  /// Text style override for the label. Defaults to white, 18px, w600.
  final TextStyle? textStyle;

  /// Whether the button is enabled. Defaults to `true`.
  /// When disabled, the shine dims and [onPressed] is not called.
  final bool enabled;

  const MetallicBorderButton({
    super.key,
    this.text,
    this.child,
    required this.color,
    this.onPressed,
    this.onLongPress,
    this.width,
    this.height = 64,
    this.borderRadius = 22,
    this.material = const MetalMaterialConfig(),
    this.textStyle,
    this.enabled = true,
  }) : assert(text != null || child != null,
            'Provide either text or child');

  @override
  State<MetallicBorderButton> createState() => _MetallicBorderButtonState();
}

class _MetallicBorderButtonState extends State<MetallicBorderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: widget.material.shineDuration ??
          const Duration(milliseconds: 4800),
    )..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  double get _effectiveEnergy {
    if (!widget.enabled) return 0.3;
    return _pressed ? 0.80 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;
    final top = Color.lerp(base, Colors.white, 0.16)!;
    final bottom = Color.lerp(base, Colors.black, 0.14)!;
    final ringW = widget.material.ringWidth ?? 3.5;

    final defaultTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    );

    final content = widget.child ??
        Text(
          widget.text!,
          style: widget.textStyle ?? defaultTextStyle,
        );

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1.0,
        child: AnimatedBuilder(
          animation: _shine,
          builder: (context, child) {
            return CustomPaint(
              foregroundPainter: PhysicalMetalShinePainter(
                rotation: _shine.value * math.pi * 2,
                energy: _effectiveEnergy,
                tint: widget.color,
                borderRadius: widget.borderRadius,
                ringWidth: ringW,
                isCircle: false,
                material: widget.material,
              ),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [top, base, bottom],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(base, Colors.black, 0.55)!
                          .withOpacity(widget.enabled ? 0.30 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(child: content),
              ),
            );
          },
        ),
      ),
    );
  }
}
