import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/metal_material_config.dart';
import '../painters/physical_metal_shine_painter.dart';

/// A premium card containing a metallic toggle switch with
/// physically-based shine animation.
///
/// ```dart
/// MetalToggleCard(
///   value: _enabled,
///   onChanged: (v) => setState(() => _enabled = v),
///   accentColor: const Color(0xFFE3AA00),
///   width: 400,
///   height: 142,
///   enabledLabel: 'Active',
///   disabledLabel: 'Inactive',
/// )
/// ```
class MetalToggleCard extends StatelessWidget {
  /// Whether the toggle is on.
  final bool value;

  /// Called when the user taps the toggle.
  final ValueChanged<bool> onChanged;

  /// Accent color for the metallic shine and active text tint.
  final Color accentColor;

  /// Overall width of the card. If `null`, stretches to parent.
  final double? width;

  /// Height of the card. Defaults to `142`.
  final double height;

  /// Text shown when [value] is `true`. Defaults to `'Enabled'`.
  final String enabledLabel;

  /// Text shown when [value] is `false`. Defaults to `'Disabled'`.
  final String disabledLabel;

  /// Font size for the label text. Defaults to `42`.
  final double labelFontSize;

  /// Card corner radius. Defaults to `30`.
  final double cardBorderRadius;

  /// Horizontal padding inside the card. Defaults to `26`.
  final double horizontalPadding;

  /// Physical material properties for the toggle thumb shine.
  final MetalMaterialConfig material;

  /// Width of the toggle track. Defaults to `170`.
  final double toggleWidth;

  /// Height of the toggle track. Defaults to `92`.
  final double toggleHeight;

  /// Size of the toggle thumb circle. Defaults to `74`.
  final double thumbSize;

  /// Padding between the track edge and the thumb. Defaults to `9`.
  final double thumbPadding;

  const MetalToggleCard({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    this.width,
    this.height = 142,
    this.enabledLabel = 'Enabled',
    this.disabledLabel = 'Disabled',
    this.labelFontSize = 42,
    this.cardBorderRadius = 30,
    this.horizontalPadding = 26,
    this.material = const MetalMaterialConfig(),
    this.toggleWidth = 170,
    this.toggleHeight = 92,
    this.thumbSize = 74,
    this.thumbPadding = 9,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = value
        ? Color.lerp(accentColor, Colors.black, 0.4)!
        : const Color(0xFFB8BBC3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        color: Colors.white.withOpacity(0.84),
        border: Border.all(
          color: Colors.white.withOpacity(0.92),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.95),
            blurRadius: 12,
            offset: const Offset(-4, -4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.4,
                color: textColor,
              ),
              child: Text(
                value ? enabledLabel : disabledLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _PremiumMetalToggle(
            value: value,
            accentColor: accentColor,
            onChanged: onChanged,
            material: material,
            width: toggleWidth,
            height: toggleHeight,
            thumbSize: thumbSize,
            thumbPadding: thumbPadding,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
//  INTERNAL: Toggle track
// ======================================================================
class _PremiumMetalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  final MetalMaterialConfig material;
  final double width;
  final double height;
  final double thumbSize;
  final double thumbPadding;

  const _PremiumMetalToggle({
    required this.value,
    required this.onChanged,
    required this.accentColor,
    required this.material,
    required this.width,
    required this.height,
    required this.thumbSize,
    required this.thumbPadding,
  });

  @override
  Widget build(BuildContext context) {
    final trackBase = value
        ? Color.lerp(accentColor, Colors.white, 0.84)!
        : const Color(0xFFE9E9ED);
    final trackHighlight = value
        ? Color.lerp(accentColor, Colors.white, 0.68)!
        : const Color(0xFFF8F8FA);
    final ambientGlow = value
        ? Color.lerp(accentColor, Colors.white, 0.22)!
        : const Color(0xFFD3D5DB);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 460),
              curve: Curves.easeOutCubic,
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    trackHighlight.withOpacity(0.78),
                    trackBase,
                    trackBase.withOpacity(0.97),
                  ],
                ),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.92),
                    blurRadius: 10,
                    offset: const Offset(-3, -3),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(4, 8),
                    spreadRadius: -4,
                  ),
                  if (value)
                    BoxShadow(
                      color: ambientGlow.withOpacity(0.30),
                      blurRadius: 18,
                      spreadRadius: 1.5,
                    ),
                ],
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 560),
              curve: Curves.easeOutCubic,
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(thumbPadding),
                child: _PremiumMetalThumb(
                  size: thumbSize,
                  active: value,
                  color: accentColor,
                  material: material,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
//  INTERNAL: Animated thumb
// ======================================================================
class _PremiumMetalThumb extends StatefulWidget {
  final double size;
  final bool active;
  final Color color;
  final MetalMaterialConfig material;

  const _PremiumMetalThumb({
    required this.size,
    required this.active,
    required this.color,
    required this.material,
  });

  @override
  State<_PremiumMetalThumb> createState() => _PremiumMetalThumbState();
}

class _PremiumMetalThumbState extends State<_PremiumMetalThumb>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: widget.material.shineDuration ??
          const Duration(milliseconds: 4000),
    )..repeat();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    if (widget.active) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PremiumMetalThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerGlow = widget.active
        ? Color.lerp(widget.color, Colors.white, 0.2)!
        : const Color(0xFFD9DAE0);

    return AnimatedBuilder(
      animation: Listenable.merge([_rotation, _pulse]),
      builder: (context, child) {
        final rot = _rotation.value * math.pi * 2;
        final p = widget.active ? _pulse.value : 0.0;
        final e = widget.active ? (0.84 + p * 0.14) : 0.38;
        final s = lerpDouble(0.992, 1.0, p)!;

        return Transform.scale(
          scale: s,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      outerGlow.withOpacity(widget.active ? 0.35 : 0.10),
                  blurRadius: widget.active ? 20 : 8,
                  spreadRadius: widget.active ? 2.0 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(2, 7),
                ),
              ],
            ),
            child: CustomPaint(
              foregroundPainter: PhysicalMetalShinePainter(
                rotation: rot,
                energy: e,
                tint: widget.color,
                borderRadius: widget.size / 2,
                ringWidth: widget.material.ringWidth ?? 4.5,
                isCircle: true,
                material: widget.material,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF5F6FA),
                      Color(0xFFE7E9EF),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
