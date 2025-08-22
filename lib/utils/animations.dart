import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutQuart;
}

class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Curve curve;
  
  const SlideInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.begin = const Offset(0, 1),
    this.curve = AppAnimations.slideCurve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            begin.dx * (1 - value),
            begin.dy * (1 - value),
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  
  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.defaultCurve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

class ScaleInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double begin;
  final Curve curve;
  
  const ScaleInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.begin = 0.0,
    this.curve = AppAnimations.bounceCurve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleAmount;
  
  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = AppAnimations.fast,
    this.scaleAmount = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceVariant;
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.surface.withOpacity(0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration interval;
  final Axis direction;
  
  const StaggeredAnimation({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.interval = const Duration(milliseconds: 100),
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final animationDelay = delay + (interval * index);
        
        return SlideInAnimation(
          delay: animationDelay,
          begin: direction == Axis.vertical 
              ? const Offset(0, 0.5) 
              : const Offset(0.5, 0),
          child: child,
        );
      }).toList(),
    );
  }
}

class FloatingActionButtonWithAnimation extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? heroTag;
  final Color? backgroundColor;
  final bool isVisible;
  
  const FloatingActionButtonWithAnimation({
    super.key,
    this.onPressed,
    required this.child,
    this.heroTag,
    this.backgroundColor,
    this.isVisible = true,
  });

  @override
  State<FloatingActionButtonWithAnimation> createState() => 
      _FloatingActionButtonWithAnimationState();
}

class _FloatingActionButtonWithAnimationState 
    extends State<FloatingActionButtonWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.bounceCurve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FloatingActionButtonWithAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 * 2,
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              heroTag: widget.heroTag,
              backgroundColor: widget.backgroundColor,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}