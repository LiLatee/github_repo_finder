import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  /// Makes a gesture for pull to refresh.
  ///
  /// Starts dragging gesture at the center of the phone.
  Future<void> pullToRefresh() async {
    final Offset middleOfPhone = getCenter(find.byType(MaterialApp));

    await TestAsyncUtils.guard(() async {
      await startGesture(middleOfPhone);
      await dragFrom(middleOfPhone, const Offset(0, 75));
    });
  }
}
