import 'package:flutter/material.dart';

class ScreenSize {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }
}

class ResponsiveHelper {
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (ScreenSize.isMobile(context)) {
      return baseFontSize;
    } else if (ScreenSize.isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (ScreenSize.isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (ScreenSize.isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (ScreenSize.isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (ScreenSize.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (ScreenSize.isMobile(context)) {
      return baseSpacing;
    } else if (ScreenSize.isTablet(context)) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  static int getGridColumns(BuildContext context) {
    if (ScreenSize.isMobile(context)) {
      return 1;
    } else if (ScreenSize.isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getMaxWidth(BuildContext context, {double? mobileMax, double? tabletMax, double? desktopMax}) {
    if (ScreenSize.isMobile(context)) {
      return mobileMax ?? double.infinity;
    } else if (ScreenSize.isTablet(context)) {
      return tabletMax ?? 600;
    } else {
      return desktopMax ?? 800;
    }
  }

  static CrossAxisAlignment getResponsiveAlignment(BuildContext context) {
    if (ScreenSize.isMobile(context)) {
      return CrossAxisAlignment.stretch;
    } else {
      return CrossAxisAlignment.center;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ScreenType screenType;
    
    if (ScreenSize.isMobile(context)) {
      screenType = ScreenType.mobile;
    } else if (ScreenSize.isTablet(context)) {
      screenType = ScreenType.tablet;
    } else {
      screenType = ScreenType.desktop;
    }

    return builder(context, screenType);
  }
}

enum ScreenType { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? mobile;
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsivePadding(context),
      margin: margin ?? ResponsiveHelper.getResponsiveMargin(context),
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.getMaxWidth(
            context,
            mobileMax: double.infinity,
            tabletMax: 600,
            desktopMax: 800,
          ),
        ),
        child: child,
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? forceColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.forceColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveHelper.getGridColumns(context);
    
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 
                  ResponsiveHelper.getResponsivePadding(context).horizontal - 
                  (spacing * (columns - 1))) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenSize.isDesktop(context)) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            if (drawer != null)
              SizedBox(
                width: 280,
                child: drawer!,
              ),
            Expanded(
              child: Column(
                children: [
                  if (appBar != null) appBar!,
                  Expanded(child: body),
                ],
              ),
            ),
            if (endDrawer != null)
              SizedBox(
                width: 280,
                child: endDrawer!,
              ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? scaleFactor;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      baseStyle.fontSize ?? 14,
    );

    return Text(
      text,
      style: baseStyle.copyWith(
        fontSize: responsiveFontSize * (scaleFactor ?? 1.0),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}