import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GrfAnnotatedRegion extends StatelessWidget {
  const GrfAnnotatedRegion({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: createSystemUiOverlayStyle(context),
      child: child,
    );
  }

  static SystemUiOverlayStyle createSystemUiOverlayStyle(BuildContext context) => SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surfaceTint,
          Theme.of(context).navigationBarTheme.elevation ?? 3,
        ),
        systemStatusBarContrastEnforced: false,
      );
}
