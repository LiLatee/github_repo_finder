import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/pull_requests_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/subjects.dart';
import 'package:test/test.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit.dart';

import '../../../domain/entities/mock_short_pull_request_entity.dart';

class MockPullRequestsRepository extends Mock implements PullRequestsRepository {}

void main() {
  final Uri mockUri = Uri.parse('https://api.github.com/repos/owneName/repoName/pulls');
  const String mockOwnerName = 'ownerName';
  const String mockRepoName = 'repoName';
  final ShortPullRequestEntity mockShortPullRequestEntity1 = getMockShortPullRequestEntity(id: 1);
  final ShortPullRequestEntity mockShortPullRequestEntity2 = getMockShortPullRequestEntity(id: 2);

  late PullRequestsRepository mockPullRequestsRepository;

  final GetPullRequestsCubitDataState dataState1 = GetPullRequestsCubitDataState(
    pullRequests: [mockShortPullRequestEntity1],
    isLoadingMoreData: false,
    hasMoreData: true,
    failure: null,
  );

  final GetPullRequestsCubitDataState dataState2 = GetPullRequestsCubitDataState(
    pullRequests: [mockShortPullRequestEntity2],
    isLoadingMoreData: false,
    hasMoreData: true,
    failure: null,
  );

  final BehaviorSubject<Either<Failure, RequestResults<ShortPullRequestEntity>>> subject = BehaviorSubject.seeded(
    Right(
      RequestResults(
        requestUri: mockUri,
        items: [mockShortPullRequestEntity1],
        paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
      ),
    ),
  );

  GetPullRequestsCubit createCubit() => GetPullRequestsCubit(
        pullRequestsRepository: mockPullRequestsRepository,
        ownerName: mockOwnerName,
        repoName: mockRepoName,
      );

  setUp(() {
    mockPullRequestsRepository = MockPullRequestsRepository();

    when(() => mockPullRequestsRepository.getPullRequests(ownerName: mockOwnerName, repoName: mockRepoName)).thenAnswer(
      (invocation) async => Right<Failure, GetPullRequestsCubitDataState>(dataState1),
    );

    when(() => mockPullRequestsRepository.getPullRequestsStream()).thenAnswer((_) => subject.stream);
    when(() => mockPullRequestsRepository.getPullRequestsNextPage()).thenAnswer((_) async {});
  });

  tearDownAll(
    () {
      subject.close();
    },
  );

  group(
    '$GetPullRequestsCubit -',
    () {
      test(
        'on start state is $GetPullRequestsCubitLoadingState',
        () async {
          final cubit = createCubit();

          expect(cubit.state, const GetPullRequestsCubitLoadingState());
        },
      );

      group('loadNextPage -', () {
        blocTest<GetPullRequestsCubit, GetPullRequestsCubitState>(
          'when called with isLoadingMoreData=true THEN do nothing',
          build: createCubit,
          seed: () => GetPullRequestsCubitDataState(
            pullRequests: [mockShortPullRequestEntity1],
            isLoadingMoreData: true,
            hasMoreData: true,
            failure: null,
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verifyNever(() => mockPullRequestsRepository.getPullRequestsNextPage()),
          ],
        );

        blocTest<GetPullRequestsCubit, GetPullRequestsCubitState>(
          'when called with hasMoreData=false THEN do nothing',
          build: createCubit,
          seed: () => GetPullRequestsCubitDataState(
            pullRequests: [mockShortPullRequestEntity1],
            isLoadingMoreData: false,
            hasMoreData: false,
            failure: null,
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verifyNever(() => mockPullRequestsRepository.getPullRequestsNextPage()),
          ],
        );

        blocTest<GetPullRequestsCubit, GetPullRequestsCubitState>(
          'when called with $Failure403 and forceLoad=false THEN do nothing',
          build: createCubit,
          seed: () => GetPullRequestsCubitDataState(
            pullRequests: [mockShortPullRequestEntity1],
            isLoadingMoreData: false,
            hasMoreData: true,
            failure: const Failure403(),
          ),
          act: (cubit) => cubit.loadNextPage(forceLoad: false),
          verify: (bloc) => [
            verifyNever(() => mockPullRequestsRepository.getPullRequestsNextPage()),
          ],
        );

        blocTest<GetPullRequestsCubit, GetPullRequestsCubitState>(
          'when called with Failure other than $Failure403 THEN call [searchRepositoriesNextPage]',
          build: createCubit,
          seed: () => GetPullRequestsCubitDataState(
            pullRequests: [mockShortPullRequestEntity1],
            isLoadingMoreData: false,
            hasMoreData: true,
            failure: const FailureApiReturnedNull(),
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verify(() => mockPullRequestsRepository.getPullRequestsNextPage()),
          ],
        );

        final GetPullRequestsCubitDataState dataStateWithFailure403 = dataState1.copyWith(failure: const Failure403());

        test('''WHEN called with $Failure403 and forceLoad=true
          THEN call "searchRepositoriesNextPage" and emit [$GetPullRequestsCubitDataState(isLoadingMoreData=true) and $GetPullRequestsCubitDataState with data from next page]''',
            () async {
          // Emit initial state with [Failure403].
          final BehaviorSubject<Either<Failure, RequestResults<ShortPullRequestEntity>>> subject =
              BehaviorSubject.seeded(
            Right(
              RequestResults(
                requestUri: mockUri,
                items: [mockShortPullRequestEntity1],
                paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
                failure: const Failure403(),
              ),
            ),
          );
          when(() => mockPullRequestsRepository.getPullRequestsStream()).thenAnswer((_) => subject.stream);

          final cubit = createCubit();
          // Wait for first _load action that emits data state with Failure403..
          await pumpEventQueue();
          expect(cubit.state, dataStateWithFailure403);

          final Future<void> loadextPageFuture = cubit.loadNextPage(forceLoad: true);
          // Change data to isLoadingMoreData=true.
          expect(
            cubit.state,
            dataStateWithFailure403.copyWith(isLoadingMoreData: true),
          );
          await loadextPageFuture;
          await pumpEventQueue();

          subject.add(Right(RequestResults(
            requestUri: mockUri,
            items: [mockShortPullRequestEntity2],
            paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
          )));
          await pumpEventQueue();

          // Verify data from next page.
          expect(cubit.state, dataState2);
          verify(() => mockPullRequestsRepository.getPullRequestsNextPage());

          await subject.close();
        });
      });

      test('when called [refresh] emit new data', () async {
        // Emit initial state with [dataState1].
        final BehaviorSubject<Either<Failure, RequestResults<ShortPullRequestEntity>>> subject = BehaviorSubject.seeded(
          Right(
            RequestResults(
              requestUri: mockUri,
              items: [mockShortPullRequestEntity1],
              paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
              failure: null,
            ),
          ),
        );
        when(() => mockPullRequestsRepository.getPullRequestsStream()).thenAnswer((_) => subject.stream);

        final cubit = createCubit();
        // Wait for first _load action that emits dataState1.
        await pumpEventQueue();
        expect(cubit.state, dataState1);

        await cubit.refresh();
        expect(cubit.state, const GetPullRequestsCubitLoadingState());

        subject.add(Right(RequestResults(
          requestUri: mockUri,
          items: [mockShortPullRequestEntity2],
          paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
        )));
        await pumpEventQueue();

        // Verify new data after pullToRefresh action.
        expect(cubit.state, dataState2);
        // [getPullRequestsStream] should be called in constructor and after pullToRefresh.
        verify(() => mockPullRequestsRepository.getPullRequestsStream()).called(2);

        await subject.close();
      });
    },
  );
}
