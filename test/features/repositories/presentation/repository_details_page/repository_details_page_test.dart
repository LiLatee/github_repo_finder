import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/repository_details_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../helpers/golden_test_runner.dart';
import '../../../../helpers/widget_tester_extension.dart';
import '../../domain/entities/mock_repository_entity.dart';
import '../../domain/entities/mock_short_pull_request_entity.dart';

class MockGetRepositoryDetailsCubit extends Mock implements GetRepositoryDetailsCubit {}

class MockGetPullRequestsCubit extends Mock implements GetPullRequestsCubit {}

void main() {
  const String mockOwnerName = 'ownerName';
  const String mockRepoName = 'repoName';

  late GetRepositoryDetailsCubit mockGetRepositoryDetailsCubit;
  late GetPullRequestsCubit mockGetPullRequestsCubit;

  setUp(
    () {
      mockGetRepositoryDetailsCubit = MockGetRepositoryDetailsCubit();
      sl.registerFactory<GetRepositoryDetailsCubit>(() => mockGetRepositoryDetailsCubit);

      mockGetPullRequestsCubit = MockGetPullRequestsCubit();
      when(() => mockGetPullRequestsCubit.loadNextPage()).thenAnswer((_) async {});
      sl.registerFactory<GetPullRequestsCubit>(() => mockGetPullRequestsCubit);
    },
  );

  tearDown(
    () {
      sl.unregister<GetRepositoryDetailsCubit>();
      sl.unregister<GetPullRequestsCubit>();
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - loading',
    builder: (context) {
      const state = GetRepositoryDetailsCubitLoadingState();

      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - error',
    builder: (context) {
      const state = GetRepositoryDetailsCubitErrorState(FailureWithMessage('message'));
      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - data',
    builder: (context) {
      final state = GetRepositoryDetailsCubitDataState(repository: getMockRepositoryEntity());
      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      final statePullRequests = GetPullRequestsCubitDataState(
        pullRequests: [
          getMockShortPullRequestEntity(),
          getMockShortPullRequestEntity(),
          getMockShortPullRequestEntity(),
        ],
        isLoadingMoreData: true,
        hasMoreData: true,
        failure: null,
      );
      when(() => mockGetPullRequestsCubit.state).thenReturn(statePullRequests);
      when(() => mockGetPullRequestsCubit.stream).thenAnswer((_) => Stream.fromIterable([statePullRequests]));
      when(() => mockGetPullRequestsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - pull to refresh',
    action: (tester) async {
      await tester.pullToRefresh();
      return;
    },
    builder: (context) {
      final state = GetRepositoryDetailsCubitDataState(repository: getMockRepositoryEntity());
      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      final statePullRequests = GetPullRequestsCubitDataState(
        pullRequests: [
          getMockShortPullRequestEntity(),
          getMockShortPullRequestEntity(),
          getMockShortPullRequestEntity(),
        ],
        isLoadingMoreData: false,
        hasMoreData: true,
        failure: null,
      );
      when(() => mockGetPullRequestsCubit.state).thenReturn(statePullRequests);
      when(() => mockGetPullRequestsCubit.stream).thenAnswer((_) => Stream.fromIterable([statePullRequests]));
      when(() => mockGetPullRequestsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - pull requests loading',
    builder: (context) {
      final state = GetRepositoryDetailsCubitDataState(repository: getMockRepositoryEntity());
      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      const statePullRequests = GetPullRequestsCubitLoadingState();
      when(() => mockGetPullRequestsCubit.state).thenReturn(statePullRequests);
      when(() => mockGetPullRequestsCubit.stream).thenAnswer((_) => Stream.fromIterable([statePullRequests]));
      when(() => mockGetPullRequestsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );

  runGoldenTest(
    '$RepositoryDetailsPage - pull requests error',
    builder: (context) {
      final state = GetRepositoryDetailsCubitDataState(repository: getMockRepositoryEntity());
      when(() => mockGetRepositoryDetailsCubit.state).thenReturn(state);
      when(() => mockGetRepositoryDetailsCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));
      when(() => mockGetRepositoryDetailsCubit.close()).thenAnswer((_) async {});

      const statePullRequests = GetPullRequestsCubitErrorState(FailureWithMessage('message'));
      when(() => mockGetPullRequestsCubit.state).thenReturn(statePullRequests);
      when(() => mockGetPullRequestsCubit.stream).thenAnswer((_) => Stream.fromIterable([statePullRequests]));
      when(() => mockGetPullRequestsCubit.close()).thenAnswer((_) async {});

      return const RepositoryDetailsPage(ownerName: mockOwnerName, repoName: mockRepoName);
    },
  );
}
