import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:retry/retry.dart';

class RetryInterceptor implements Interceptor {
  RetryInterceptor({
    this.retries = 8,
    this.delay = const Duration(milliseconds: 200),
  });

  final int retries;
  final Duration delay;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final r = RetryOptions(maxAttempts: retries, delayFactor: delay);

    return await r.retry(
      () async {
        return await chain.proceed(chain.request);
      },
      retryIf: (e) {
        log('RetryInterceptor got Exception: $e');
        return e is TimeoutException || e is SocketException;
      },
    );
  }
}
