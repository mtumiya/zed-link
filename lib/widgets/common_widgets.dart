import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: elevation ?? 1,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        color: backgroundColor ?? theme.colorScheme.surface,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonType type;
  final Size? size;
  
  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.primary,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: type == ButtonType.primary 
              ? Colors.white 
              : theme.colorScheme.primary,
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    switch (type) {
      case ButtonType.primary:
        return Container(
          width: size?.width,
          height: size?.height ?? 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isLoading || onPressed == null
                ? null
                : LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withBlue(
                        (theme.colorScheme.primary.blue * 0.8).round(),
                      ),
                    ],
                  ),
            boxShadow: isLoading || onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoading || onPressed == null
                  ? theme.colorScheme.onSurface.withOpacity(0.12)
                  : Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.secondary:
        return Container(
          width: size?.width,
          height: size?.height ?? 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: theme.colorScheme.primary,
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.text:
        return Container(
          width: size?.width,
          height: size?.height ?? 56,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: theme.colorScheme.primary,
            ),
            child: buttonChild,
          ),
        );
    }
  }
}

enum ButtonType { primary, secondary, text }

class ModernTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  
  const ModernTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: enabled 
            ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
            : theme.colorScheme.onSurface.withOpacity(0.05),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        maxLines: maxLines,
        enabled: enabled,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled 
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.38),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixText: prefixText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: enabled 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: enabled ? onSuffixIconPressed : null,
                  icon: Icon(
                    suffixIcon,
                    color: enabled 
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withOpacity(0.38),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          labelStyle: TextStyle(
            color: enabled 
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface.withOpacity(0.38),
          ),
          hintStyle: TextStyle(
            color: enabled 
                ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6)
                : theme.colorScheme.onSurface.withOpacity(0.38),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  
  const InfoCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? theme.colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}