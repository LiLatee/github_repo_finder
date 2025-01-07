import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../domain/entities/mock_short_repository_entity.dart';

class MockStackTrace extends Mock implements StackTrace {}

class MockRepositoriesService extends Mock implements RepositoriesService {}

class MockCrashlyticsErrorReporter extends Mock implements CrashlyticsErrorReporter {}

base class MockResponse<RequestResults> extends Mock with MockResponseMixin<RequestResults> {}

void main() {
  const String mockQuery = 'mockQuery';
  late RepositoriesRepository repository;
  late MockRepositoriesService mockRepositoriesService;
  late MockCrashlyticsErrorReporter mockCrashlyticsErrorReporter;
  late Response<RequestResults<ShortRepositoryEntity>> mockChopperResponse;

  setUpAll(() {
    registerFallbackValue(MockStackTrace());
  });

  setUp(() {
    mockChopperResponse = MockResponse<RequestResults<ShortRepositoryEntity>>();

    mockRepositoriesService = MockRepositoriesService();
    when(() => mockRepositoriesService.search(query: mockQuery)).thenAnswer((_) async => mockChopperResponse);

    repository = RepositoriesRepository(repositoriesService: mockRepositoriesService);

    mockCrashlyticsErrorReporter = MockCrashlyticsErrorReporter();
    when((() => mockCrashlyticsErrorReporter.logException(
        exception: any(named: 'exception'), stackTrace: any(named: 'stackTrace')))).thenAnswer((_) async {});
    sl.registerLazySingleton<CrashlyticsErrorReporter>(() => mockCrashlyticsErrorReporter);
  });

  tearDown(() {
    sl.unregister<CrashlyticsErrorReporter>();
  });

  group('$RepositoriesRepository -', () {
    test('[searchRepositories] emits Right with data when API call succeeds', () async {
      final mockResponse = RequestResults<ShortRepositoryEntity>(
        items: [getMockShortRepositoryEntity()],
        paginationLinks: null,
        requestUri: Uri.parse('https://api.github.com/repos/flutter/flutter/pulls'),
      );

      when(() => mockChopperResponse.body).thenAnswer((_) => mockResponse);

      await repository.searchRepositories(query: mockQuery);
      final result = await repository.searchRepositoriesStream().first;

      expect(result.right.items, equals(mockResponse.items));
    });

    test('[searchRepositories] emits Left with FailureApiReturnedNull on null body', () async {
      when(() => mockChopperResponse.body).thenAnswer((_) => null);

      await repository.searchRepositories(query: mockQuery);
      final result = await repository.searchRepositoriesStream().first;

      verify(
        () => mockCrashlyticsErrorReporter.logException(
            exception: any(named: 'exception'), stackTrace: any(named: 'stackTrace')),
      );
      expect(result.left, isA<FailureApiReturnedNull>());
    });

    test('[searchRepositoriesNextPage] emits updated data on valid nextLink', () async {
      final initialResponse = RequestResults<ShortRepositoryEntity>(
        items: [getMockShortRepositoryEntity()],
        paginationLinks: PaginationLinks(nextLink: Uri.parse('https://api.github.com/search?q=$mockQuery&page=2')),
        requestUri: Uri.parse('https://api.github.com/search?q=$mockQuery'),
      );
      final nextResponse = RequestResults<ShortRepositoryEntity>(
        items: [getMockShortRepositoryEntity()],
        paginationLinks: null,
        requestUri: Uri.parse('https://api.github.com/search?q=$mockQuery&page=2'),
      );

      Response<RequestResults<ShortRepositoryEntity>> mockChopperResponseInitial =
          MockResponse<RequestResults<ShortRepositoryEntity>>();
      when(() => mockChopperResponseInitial.body).thenAnswer((_) => initialResponse);
      when(() => mockRepositoriesService.search(query: mockQuery)).thenAnswer((_) async => mockChopperResponseInitial);

      Response<RequestResults<ShortRepositoryEntity>> mockChopperResponseNext =
          MockResponse<RequestResults<ShortRepositoryEntity>>();

      when(() => mockChopperResponseNext.body).thenAnswer((_) => nextResponse);
      when(() => mockRepositoriesService.search(query: mockQuery, page: 2))
          .thenAnswer((_) async => mockChopperResponseNext);

      await repository.searchRepositories(query: mockQuery);
      await repository.searchRepositoriesStream().first;

      await repository.searchRepositoriesNextPage();
      final result = await repository.searchRepositoriesStream().first;

      expect(result.right.items.length, equals(2));
    });
  });
}
