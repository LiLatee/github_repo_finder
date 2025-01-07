import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chopper/chopper.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/pull_requests_repository.dart';

import '../../domain/entities/mock_short_pull_request_entity.dart';

class MockStackTrace extends Mock implements StackTrace {}

class MockRepositoriesService extends Mock implements RepositoriesService {}

class MockCrashlyticsErrorReporter extends Mock implements CrashlyticsErrorReporter {}

base class MockResponse<RequestResults> extends Mock with MockResponseMixin<RequestResults> {}

void main() {
  late PullRequestsRepository repository;
  late MockRepositoriesService mockRepositoriesService;
  late MockCrashlyticsErrorReporter mockCrashlyticsErrorReporter;
  late Response<RequestResults<ShortPullRequestEntity>> mockChopperResponse;

  setUpAll(() {
    registerFallbackValue(MockStackTrace());
  });

  setUp(() {
    mockChopperResponse = MockResponse<RequestResults<ShortPullRequestEntity>>();

    mockRepositoriesService = MockRepositoriesService();
    when(() => mockRepositoriesService.getPullRequests(
          ownerName: 'flutter',
          repoName: 'flutter',
        )).thenAnswer((_) async => mockChopperResponse);

    repository = PullRequestsRepository(repositoriesService: mockRepositoriesService);

    mockCrashlyticsErrorReporter = MockCrashlyticsErrorReporter();
    when((() => mockCrashlyticsErrorReporter.logException(
        exception: any(named: 'exception'), stackTrace: any(named: 'stackTrace')))).thenAnswer((_) async {});
    sl.registerLazySingleton<CrashlyticsErrorReporter>(() => mockCrashlyticsErrorReporter);
  });

  tearDown(() {
    sl.unregister<CrashlyticsErrorReporter>();
  });

  group('$PullRequestsRepository -', () {
    test('[getPullRequests] emits Right with data when API call succeeds', () async {
      final mockResponse = RequestResults<ShortPullRequestEntity>(
        items: [getMockShortPullRequestEntity()],
        paginationLinks: null,
        requestUri: Uri.parse('https://api.github.com/repos/flutter/flutter/pulls'),
      );

      when(() => mockChopperResponse.body).thenAnswer((_) => mockResponse);

      await repository.getPullRequests(ownerName: 'flutter', repoName: 'flutter');
      final result = await repository.getPullRequestsStream().first;

      expect(result.right.items, equals(mockResponse.items));
    });

    test('[getPullRequests] emits Left with FailureApiReturnedNull on null body', () async {
      when(() => mockChopperResponse.body).thenAnswer((_) => null);

      await repository.getPullRequests(ownerName: 'flutter', repoName: 'flutter');
      final result = await repository.getPullRequestsStream().first;

      verify(
        () => mockCrashlyticsErrorReporter.logException(
            exception: any(named: 'exception'), stackTrace: any(named: 'stackTrace')),
      );
      expect(result.left, isA<FailureApiReturnedNull>());
    });

    test('[getPullRequestsNextPage] emits updated data on valid nextLink', () async {
      final initialResponse = RequestResults<ShortPullRequestEntity>(
        items: [getMockShortPullRequestEntity()],
        paginationLinks:
            PaginationLinks(nextLink: Uri.parse('https://api.github.com/repos/flutter/flutter/pulls?page=2')),
        requestUri: Uri.parse('https://api.github.com/repos/flutter/flutter/pulls'),
      );
      final nextResponse = RequestResults<ShortPullRequestEntity>(
        items: [getMockShortPullRequestEntity()],
        paginationLinks: null,
        requestUri: Uri.parse('https://api.github.com/repos/flutter/flutter/pulls?page=2'),
      );

      Response<RequestResults<ShortPullRequestEntity>> mockChopperResponseInitial =
          MockResponse<RequestResults<ShortPullRequestEntity>>();
      when(() => mockChopperResponseInitial.body).thenAnswer((_) => initialResponse);
      when(() => mockRepositoriesService.getPullRequests(
            ownerName: 'flutter',
            repoName: 'flutter',
          )).thenAnswer((_) async => mockChopperResponseInitial);

      Response<RequestResults<ShortPullRequestEntity>> mockChopperResponseNext =
          MockResponse<RequestResults<ShortPullRequestEntity>>();
      when(() => mockChopperResponseNext.body).thenAnswer((_) => nextResponse);

      when(() => mockRepositoriesService.getPullRequests(
            ownerName: 'flutter',
            repoName: 'flutter',
            page: 2,
          )).thenAnswer((_) async => mockChopperResponseNext);

      await repository.getPullRequests(ownerName: 'flutter', repoName: 'flutter');
      await repository.getPullRequestsStream().first;

      await repository.getPullRequestsNextPage();
      final result = await repository.getPullRequestsStream().first;

      expect(result.right.items.length, equals(2));
    });
  });
}
