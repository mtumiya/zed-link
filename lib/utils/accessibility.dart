import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityHelper {
  static void announceForAccessibility(BuildContext context, String message) {
    // Use ScaffoldMessenger as an alternative for announcements
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void provideFeedback() {
    HapticFeedback.lightImpact();
  }

  static void provideSelectionFeedback() {
    HapticFeedback.selectionClick();
  }

  static void provideHeavyFeedback() {
    HapticFeedback.heavyImpact();
  }

  static const double minimumTouchTargetSize = 48.0;
  static const EdgeInsets recommendedPadding = EdgeInsets.all(16.0);
  
  static TextStyle getAccessibleTextStyle(BuildContext context, TextStyle? baseStyle) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor.clamp(1.0, 2.0);
    
    return (baseStyle ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
      fontSize: (baseStyle?.fontSize ?? 14) * textScaleFactor,
    );
  }

  static bool isLargeTextEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }

  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  static bool isAccessibilityEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
}

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;
  
  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      onTap: onPressed != null ? () {
        AccessibilityHelper.provideFeedback();
        onPressed!();
      } : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AccessibilityHelper.minimumTouchTargetSize,
          minHeight: AccessibilityHelper.minimumTouchTargetSize,
        ),
        child: child,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (semanticLabel != null && !excludeFromSemantics) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    return button;
  }
}

class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  
  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: semanticLabel ?? labelText,
      textField: true,
      enabled: enabled,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        enabled: enabled,
        onTap: onTap,
        style: AccessibilityHelper.getAccessibleTextStyle(context, theme.textTheme.bodyLarge),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.all(
            AccessibilityHelper.isLargeTextEnabled(context) ? 20 : 16
          ),
        ),
      ),
    );
  }
}

class HighContrastColors {
  static Color getContrastColor(BuildContext context, Color baseColor) {
    if (AccessibilityHelper.isHighContrast(context)) {
      final brightness = ThemeData.estimateBrightnessForColor(baseColor);
      return brightness == Brightness.light ? Colors.black : Colors.white;
    }
    return baseColor;
  }

  static Color getBackgroundColor(BuildContext context) {
    if (AccessibilityHelper.isHighContrast(context)) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.light ? Colors.white : Colors.black;
    }
    return Theme.of(context).colorScheme.background;
  }

  static Color getTextColor(BuildContext context) {
    if (AccessibilityHelper.isHighContrast(context)) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.light ? Colors.black : Colors.white;
    }
    return Theme.of(context).colorScheme.onBackground;
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: HighContrastColors.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: AccessibilityHelper.isHighContrast(context)
            ? BorderSide(color: HighContrastColors.getTextColor(context), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          minHeight: AccessibilityHelper.minimumTouchTargetSize,
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(
            color: HighContrastColors.getTextColor(context),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: () {
          AccessibilityHelper.provideFeedback();
          onTap!();
        },
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }
}

class LoadingIndicatorWithText extends StatelessWidget {
  final String? message;
  final bool isLoading;
  
  const LoadingIndicatorWithText({
    super.key,
    this.message,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    
    return Semantics(
      label: message ?? 'Loading, please wait',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AccessibilityHelper.getAccessibleTextStyle(
                  context,
                  Theme.of(context).textTheme.bodyMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ScreenReaderText extends StatelessWidget {
  final String text;
  final bool liveRegion;
  
  const ScreenReaderText({
    super.key,
    required this.text,
    this.liveRegion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      liveRegion: liveRegion,
      child: const SizedBox.shrink(),
    );
  }
}

class FocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFocusChanged;
  final String? semanticLabel;
  
  const FocusableWidget({
    super.key,
    required this.child,
    this.onFocusChanged,
    this.semanticLabel,
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Focus(
      focusNode: _focusNode,
      child: Container(
        decoration: _isFocused
            ? BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Semantics(
          label: widget.semanticLabel,
          focusable: true,
          child: widget.child,
        ),
      ),
    );
  }
}