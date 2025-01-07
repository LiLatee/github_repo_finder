import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/chopper_client/interceptors/retry_interceptor.dart';
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

const int _cacheMaxSizeInBytes = 10000;

Client httpClient() {
  if (Platform.isAndroid) {
    final engine = CronetEngine.build(
      cacheMode: CacheMode.memory,
      cacheMaxSize: _cacheMaxSizeInBytes,
    );
    return CronetClient.fromCronetEngine(engine);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    final config = URLSessionConfiguration.ephemeralSessionConfiguration()
      ..cache = URLCache.withCapacity(memoryCapacity: _cacheMaxSizeInBytes);
    return CupertinoClient.fromSessionConfiguration(config);
  }
  return IOClient();
}

ChopperClient getChopperClient() {
  return ChopperClient(
    baseUrl: Uri(
      scheme: 'https',
      host: 'api.github.com',
    ),
    interceptors: [
      HttpLoggingInterceptor(),
      RetryInterceptor(),
    ],
    client: sl<Client>(),
    services: [
      RepositoriesService.create(),
    ],
  );
}
