import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/repositories_page.dart';

import '../../../../helpers/golden_test_runner.dart';
import '../../../../helpers/widget_tester_extension.dart';
import '../../domain/entities/mock_short_repository_entity.dart';

class MockSearchRepositoriesCubit extends Mock implements SearchRepositoriesCubit {}

void main() {
  late SearchRepositoriesCubit mockSearchRepositoriesCubit;
  setUp(
    () {
      mockSearchRepositoriesCubit = MockSearchRepositoriesCubit();
      when(() => mockSearchRepositoriesCubit.loadNextPage()).thenAnswer((_) async {});
      sl.registerFactory<SearchRepositoriesCubit>(() => mockSearchRepositoriesCubit);
    },
  );

  tearDown(
    () {
      sl.unregister<SearchRepositoriesCubit>();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - loading',
    builder: (context) {
      const state = SearchRepositoriesCubitLoadingState();

      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - error',
    builder: (context) {
      const state = SearchRepositoriesCubitErrorState(FailureWithMessage('message'));
      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - data',
    builder: (context) {
      final state = SearchRepositoriesCubitDataState(
        repositories: [
          getMockShortRepositoryEntity(),
          getMockShortRepositoryEntity(
            fullName:
                'Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name ',
            watchersCount: 567890,
          ),
          getMockShortRepositoryEntity(watchersCount: 0),
        ],
        isLoadingMoreData: true,
        hasMoreData: true,
        failure: null,
      );
      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - data - $Failure403',
    builder: (context) {
      final state = SearchRepositoriesCubitDataState(
        repositories: [
          getMockShortRepositoryEntity(),
          getMockShortRepositoryEntity(
            fullName:
                'Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name ',
            watchersCount: 567890,
          ),
          getMockShortRepositoryEntity(watchersCount: 0),
        ],
        isLoadingMoreData: true,
        hasMoreData: true,
        failure: const Failure403(),
      );
      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - empty list',
    builder: (context) {
      final state = SearchRepositoriesCubitDataState(
        repositories: const [],
        isLoadingMoreData: true,
        hasMoreData: true,
        failure: null,
      );
      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );

  runGoldenTest(
    '$RepositoriesPage - pull to refresh',
    action: (tester) async {
      await tester.pullToRefresh();
      return;
    },
    builder: (context) {
      final state = SearchRepositoriesCubitDataState(
        repositories: [
          getMockShortRepositoryEntity(),
          getMockShortRepositoryEntity(
            fullName:
                'Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name Long name ',
            watchersCount: 567890,
          ),
          getMockShortRepositoryEntity(watchersCount: 0),
        ],
        isLoadingMoreData: false,
        hasMoreData: true,
        failure: null,
      );
      when(() => mockSearchRepositoriesCubit.state).thenReturn(state);
      when(() => mockSearchRepositoriesCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      when(() => mockSearchRepositoriesCubit.close()).thenAnswer((_) async {});

      return const RepositoriesPage();
    },
  );
}
