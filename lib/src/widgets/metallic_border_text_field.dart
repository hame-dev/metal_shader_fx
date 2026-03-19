import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/metal_material_config.dart';
import '../painters/physical_metal_shine_painter.dart';

/// A text field with a physically-based metallic border shine animation.
///
/// The shine intensifies when the field is focused.
///
/// ```dart
/// MetallicBorderTextField(
///   controller: _controller,
///   hintText: 'Enter your email',
///   color: const Color(0xFFE3AA00),
///   onChanged: (value) => print(value),
///   onSubmitted: (value) => print('submitted: $value'),
/// )
/// ```
class MetallicBorderTextField extends StatefulWidget {
  /// Text editing controller.
  final TextEditingController? controller;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Label text displayed above the field.
  final String? labelText;

  /// Accent color for the metallic shine.
  final Color color;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses enter).
  final ValueChanged<String>? onSubmitted;

  /// Called when the field gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Called when the user taps the field.
  final VoidCallback? onTap;

  /// Fixed width. If `null`, stretches to parent.
  final double? width;

  /// Field height. Defaults to `64`.
  final double height;

  /// Corner radius. Defaults to `22`.
  final double borderRadius;

  /// Physical material properties for the border shine.
  final MetalMaterialConfig material;

  /// Text style for the input text.
  final TextStyle? style;

  /// Text style for the hint text.
  final TextStyle? hintStyle;

  /// Whether the field is obscured (e.g. password). Defaults to `false`.
  final bool obscureText;

  /// Character used for obscuring text. Defaults to `'•'`.
  final String obscuringCharacter;

  /// Whether the field is enabled. Defaults to `true`.
  final bool enabled;

  /// Whether the field is read-only. Defaults to `false`.
  final bool readOnly;

  /// Maximum number of lines. Defaults to `1`.
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum text length.
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action (e.g. done, next, search).
  final TextInputAction? textInputAction;

  /// Input formatters for restricting input.
  final List<TextInputFormatter>? inputFormatters;

  /// Prefix widget inside the field.
  final Widget? prefixIcon;

  /// Suffix widget inside the field.
  final Widget? suffixIcon;

  /// Content padding. Defaults to `EdgeInsets.symmetric(horizontal: 22, vertical: 20)`.
  final EdgeInsetsGeometry? contentPadding;

  /// Autofocus. Defaults to `false`.
  final bool autofocus;

  /// External focus node. If `null`, the widget manages its own.
  final FocusNode? focusNode;

  const MetallicBorderTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    required this.color,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onTap,
    this.width,
    this.height = 64,
    this.borderRadius = 22,
    this.material = const MetalMaterialConfig(),
    this.style,
    this.hintStyle,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<MetallicBorderTextField> createState() =>
      _MetallicBorderTextFieldState();
}

class _MetallicBorderTextFieldState extends State<MetallicBorderTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: widget.material.shineDuration ??
          const Duration(milliseconds: 5400),
    )..repeat();

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  void _onFocusChange() {
    setState(() {});
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  void didUpdateWidget(covariant MetallicBorderTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
      _controller = widget.controller!;
    }
    if (widget.focusNode != null && oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final bg = Color.lerp(widget.color, Colors.white, 0.96)!;
    final ringW = widget.material.ringWidth ?? (focused ? 3.0 : 2.0);
    final effectiveEnergy = widget.enabled ? (focused ? 1.0 : 0.45) : 0.2;

    final defaultStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFF14151A),
      fontWeight: FontWeight.w500,
    );

    final defaultHintStyle = TextStyle(
      color: Colors.black.withOpacity(0.34),
      fontSize: 16,
    );

    final defaultPadding = const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 20,
    );

    return AnimatedBuilder(
      animation: _shine,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: PhysicalMetalShinePainter(
            rotation: _shine.value * math.pi * 2,
            energy: effectiveEnergy,
            tint: widget.color,
            borderRadius: widget.borderRadius,
            ringWidth: ringW,
            isCircle: false,
            material: widget.material,
          ),
          child: Container(
            width: widget.width,
            height: widget.maxLines > 1 ? null : widget.height,
            constraints: widget.maxLines > 1
                ? BoxConstraints(minHeight: widget.height)
                : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: bg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                if (focused)
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            alignment:
                widget.maxLines == 1 ? Alignment.center : Alignment.topLeft,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              cursorColor: widget.color,
              obscureText: widget.obscureText,
              obscuringCharacter: widget.obscuringCharacter,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              style: widget.style ?? defaultStyle,
              decoration: InputDecoration(
                isCollapsed: widget.prefixIcon == null &&
                    widget.suffixIcon == null &&
                    widget.labelText == null,
                hintText: widget.hintText,
                labelText: widget.labelText,
                hintStyle: widget.hintStyle ?? defaultHintStyle,
                contentPadding: widget.contentPadding ?? defaultPadding,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        );
      },
    );
  }
}
