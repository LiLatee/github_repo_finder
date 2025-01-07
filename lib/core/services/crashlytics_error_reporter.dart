import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:github_repo_finder/core/dependencies.dart';

class CrashlyticsErrorReporter {
  Future<dynamic> initReporter() async {
    FlutterError.onError = _reportFlutterError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
  }

  Future<void> logException({
    required Object exception,
    required StackTrace stackTrace,
  }) {
    if (kReleaseMode) {
      return FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } else {
      return _printException(exception: exception, stackTrace: stackTrace);
    }
  }

  Future<void> _reportFlutterError(FlutterErrorDetails flutterErrorDetails) async {
    if (kReleaseMode) {
      return FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    } else {
      return _printException(exception: flutterErrorDetails.exception, stackTrace: flutterErrorDetails.stack);
    }
  }

  Future<void> _printException({
    required Object exception,
    StackTrace? stackTrace,
  }) async {
    _printInRed('[🔥] Crashlytics Error reporter - debug mode, only printing');
    _printInRed(exception.toString());
    _printInRed(stackTrace.toString());
  }

  void _printInRed(String text) {
    if (kDebugMode) {
      debugPrintThrottled('\x1B[31m$text\x1B[0m', wrapWidth: 120);
    }
  }
}

/// In order to make it useful during development (in debug mode) remember to:
/// - in [CrashlyticsErrorReporter] set it to true [await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);];
/// - in [CrashlyticsErrorReporter] in [logException] and [_reportFlutterError] change `if(kReleaseMode) => if(true)`
Future<void> testFirebaseCrashlytics() async {
  await sl<CrashlyticsErrorReporter>()
      .logException(exception: Exception('Test: non-fatal'), stackTrace: StackTrace.current);
  await FirebaseCrashlytics.instance
      .recordFlutterError(FlutterErrorDetails(exception: Exception('Test: fatal')), fatal: true);
  FirebaseCrashlytics.instance.crash();
}
