// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RepositoriesService extends RepositoriesService {
  _$RepositoriesService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RepositoriesService;

  @override
  Future<Response<RequestResults<ShortRepositoryEntity>>> search({
    String query = '',
    int? page,
  }) {
    final Uri $url = Uri.parse('search/repositories');
    final Map<String, dynamic> $params = <String, dynamic>{
      'q': query,
      'page': page,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<RequestResults<ShortRepositoryEntity>, ShortRepositoryEntity>(
      $request,
      responseConverter: convertRepositoriesResponse,
    );
  }

  @override
  Future<Response<RepositoryEntity>> getRepository({
    required String ownerName,
    required String repoName,
  }) {
    final Uri $url = Uri.parse('/repos/${ownerName}/${repoName}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<RepositoryEntity, RepositoryEntity>(
      $request,
      responseConverter: convertRepositoryResponse,
    );
  }

  @override
  Future<Response<RequestResults<ShortPullRequestEntity>>> getPullRequests({
    required String ownerName,
    required String repoName,
    int? page,
  }) {
    final Uri $url = Uri.parse('/repos/${ownerName}/${repoName}/pulls');
    final Map<String, dynamic> $params = <String, dynamic>{'page': page};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<RequestResults<ShortPullRequestEntity>, ShortPullRequestEntity>(
      $request,
      responseConverter: convertGetPullRequestsResponse,
    );
  }
}
