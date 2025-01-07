import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';

part 'repositories_service.chopper.dart';

@ChopperApi()
abstract class RepositoriesService extends ChopperService {
  // A helper method that helps instantiating the service. You can omit this method and use the generated class directly instead.
  static RepositoriesService create([ChopperClient? client]) => _$RepositoriesService(client);

  @FactoryConverter(
    response: convertRepositoriesResponse,
  )
  @Get(path: 'search/repositories')
  Future<Response<RequestResults<ShortRepositoryEntity>>> search({
    @Query('q') String query = '',
    @Query('page') int? page,
  });

  @FactoryConverter(
    response: convertRepositoryResponse,
  )
  @Get(path: '/repos/{ownerName}/{repoName}')
  Future<Response<RepositoryEntity>> getRepository({
    @Path('ownerName') required String ownerName,
    @Path('repoName') required String repoName,
  });

  @FactoryConverter(
    response: convertGetPullRequestsResponse,
  )
  @Get(path: '/repos/{ownerName}/{repoName}/pulls')
  Future<Response<RequestResults<ShortPullRequestEntity>>> getPullRequests({
    @Path('ownerName') required String ownerName,
    @Path('repoName') required String repoName,
    @Query('page') int? page,
  });
}

Response<RequestResults<ShortRepositoryEntity>> convertRepositoriesResponse(Response<dynamic> response) {
  try {
    final json = jsonDecode(response.bodyString);
    if (json is Map) {
      final items = json['items'] as List;

      final String? linkHeader = response.headers['link'];
      final List<ShortRepositoryEntity> itemsConverted =
          items.map((item) => ShortRepositoryEntity.fromJson(item as Map<String, dynamic>)).toList(growable: false);

      return Response(
        response.base,
        RequestResults<ShortRepositoryEntity>(
          requestUri: response.base.request!.url,
          items: itemsConverted,
          paginationLinks: linkHeader == null || linkHeader.isEmpty ? null : PaginationLinks.fromLinkHeader(linkHeader),
        ),
      );
    }

    throw Exception('Unexpected Error: ${response.base.request!.url} returned not a Map object.');
  } catch (err, st) {
    unawaited(sl<CrashlyticsErrorReporter>().logException(exception: err, stackTrace: st));
    return Response(response.base, null);
  }
}

Response<RepositoryEntity> convertRepositoryResponse(Response<dynamic> response) {
  try {
    final json = jsonDecode(response.bodyString);
    if (json is Map<String, dynamic>) {
      return Response(response.base, RepositoryEntity.fromJson(json));
    }

    throw Exception('Unexpected Error: ${response.base.request!.url} returned not a Map object.');
  } catch (err, st) {
    unawaited(sl<CrashlyticsErrorReporter>().logException(exception: err, stackTrace: st));
    return Response(response.base, null);
  }
}

Response<RequestResults<ShortPullRequestEntity>> convertGetPullRequestsResponse(Response<dynamic> response) {
  try {
    final json = jsonDecode(response.bodyString);
    if (json is List) {
      final String? linkHeader = response.headers['link'];

      final List<ShortPullRequestEntity> itemsConverted =
          json.map((item) => ShortPullRequestEntity.fromJson(item as Map<String, dynamic>)).toList(growable: false);

      return Response(
        response.base,
        RequestResults<ShortPullRequestEntity>(
          requestUri: response.base.request!.url,
          items: itemsConverted,
          paginationLinks: linkHeader == null || linkHeader.isEmpty ? null : PaginationLinks.fromLinkHeader(linkHeader),
        ),
      );
    }

    throw Exception('Unexpected Error: ${response.base.request!.url} returned not a Map object.');
  } catch (err, st) {
    unawaited(sl<CrashlyticsErrorReporter>().logException(exception: err, stackTrace: st));
    return Response(response.base, null);
  }
}
