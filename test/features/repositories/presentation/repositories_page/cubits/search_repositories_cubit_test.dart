import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/subjects.dart';
import 'package:test/test.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';

import '../../../domain/entities/mock_short_repository_entity.dart';

class MockRepositoriesRepository extends Mock implements RepositoriesRepository {}

void main() {
  const String mockQuery = 'mock query';
  final Uri mockUri = Uri.parse('https://api.github.com/search?q=$mockQuery');
  final Uri mockDefaultUri = Uri.parse('https://api.github.com/search?q=$defaultQuery');

  final ShortRepositoryEntity mockShortRepositoryEntity1 = getMockShortRepositoryEntity(id: 1);
  final ShortRepositoryEntity mockShortRepositoryEntity2 = getMockShortRepositoryEntity(id: 2);
  final SearchRepositoriesCubitDataState dataState1 = SearchRepositoriesCubitDataState(
    repositories: [mockShortRepositoryEntity1],
    isLoadingMoreData: false,
    hasMoreData: true,
    failure: null,
  );

  final SearchRepositoriesCubitDataState dataState2 = SearchRepositoriesCubitDataState(
    repositories: [mockShortRepositoryEntity2],
    isLoadingMoreData: false,
    hasMoreData: true,
    failure: null,
  );

  group(
    '${SearchRepositoriesCubit} -',
    () {
      late RepositoriesRepository mockRepositoriesRepository;
      final BehaviorSubject<Either<Failure, RequestResults<ShortRepositoryEntity>>> subject = BehaviorSubject.seeded(
        Right(
          RequestResults(
            requestUri: mockUri,
            items: [mockShortRepositoryEntity1],
            paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
          ),
        ),
      );

      setUp(() {
        mockRepositoriesRepository = MockRepositoriesRepository();
        when(() => mockRepositoriesRepository.searchRepositoriesStream()).thenAnswer((_) => subject.stream);
        when(() => mockRepositoriesRepository.searchRepositories(query: defaultQuery)).thenAnswer((_) async {});
        when(() => mockRepositoriesRepository.searchRepositories(query: mockQuery)).thenAnswer((_) async {});
        when(() => mockRepositoriesRepository.searchRepositoriesNextPage()).thenAnswer((_) async {});
      });

      tearDownAll(
        () {
          subject.close();
        },
      );

      SearchRepositoriesCubit createCubit() =>
          SearchRepositoriesCubit(repositoriesRepository: mockRepositoriesRepository);

      test(
        'on start state is $SearchRepositoriesCubitLoadingState, then $SearchRepositoriesCubitDataState',
        () async {
          final SearchRepositoriesCubit cubit = createCubit();
          expect(cubit.state, const SearchRepositoriesCubitLoadingState());

          await pumpEventQueue();
          expect(
            cubit.state,
            SearchRepositoriesCubitDataState(
              repositories: [mockShortRepositoryEntity1],
              isLoadingMoreData: false,
              hasMoreData: true,
              failure: null,
            ),
          );
        },
      );

      group('search -', () {
        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'on search emit new $SearchRepositoriesCubitDataState',
          build: createCubit,
          setUp: () {
            when(() => mockRepositoriesRepository.searchRepositories(query: mockQuery)).thenAnswer((_) async {});
            subject.add(Right(RequestResults(requestUri: mockUri, items: [mockShortRepositoryEntity2])));
          },
          act: (cubit) => cubit.search(mockQuery),
          expect: () => [
            SearchRepositoriesCubitDataState(
              repositories: [mockShortRepositoryEntity2],
              isLoadingMoreData: false,
              hasMoreData: false,
              failure: null,
            ),
          ],
        );

        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'on search with empty query use $defaultQuery as query',
          build: createCubit,
          setUp: () {
            when(() => mockRepositoriesRepository.searchRepositories(query: defaultQuery)).thenAnswer((_) async {});
            subject.add(Right(RequestResults(requestUri: mockDefaultUri, items: [mockShortRepositoryEntity2])));
          },
          act: (cubit) => cubit.search(''),
          expect: () => [
            SearchRepositoriesCubitDataState(
              repositories: [mockShortRepositoryEntity2],
              isLoadingMoreData: false,
              hasMoreData: false,
              failure: null,
            ),
          ],
        );
      });

      group('loadNextPage -', () {
        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'when called with isLoadingMoreData=true THEN do nothing',
          build: createCubit,
          seed: () => SearchRepositoriesCubitDataState(
            repositories: [mockShortRepositoryEntity1],
            isLoadingMoreData: true,
            hasMoreData: true,
            failure: null,
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verifyNever(() => mockRepositoriesRepository.searchRepositoriesNextPage()),
          ],
        );

        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'when called with hasMoreData=false THEN do nothing',
          build: createCubit,
          seed: () => SearchRepositoriesCubitDataState(
            repositories: [mockShortRepositoryEntity1],
            isLoadingMoreData: false,
            hasMoreData: false,
            failure: null,
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verifyNever(() => mockRepositoriesRepository.searchRepositoriesNextPage()),
          ],
        );

        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'when called with $Failure403 and forceLoad=false THEN do nothing',
          build: createCubit,
          seed: () => SearchRepositoriesCubitDataState(
            repositories: [mockShortRepositoryEntity1],
            isLoadingMoreData: false,
            hasMoreData: true,
            failure: const Failure403(),
          ),
          act: (cubit) => cubit.loadNextPage(forceLoad: false),
          verify: (bloc) => [
            verifyNever(() => mockRepositoriesRepository.searchRepositoriesNextPage()),
          ],
        );

        blocTest<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
          'when called with Failure other than $Failure403 THEN call [searchRepositoriesNextPage]',
          build: createCubit,
          seed: () => SearchRepositoriesCubitDataState(
            repositories: [mockShortRepositoryEntity1],
            isLoadingMoreData: false,
            hasMoreData: true,
            failure: const FailureApiReturnedNull(),
          ),
          act: (cubit) => cubit.loadNextPage(),
          verify: (bloc) => [
            verify(() => mockRepositoriesRepository.searchRepositoriesNextPage()),
          ],
        );

        final SearchRepositoriesCubitDataState dataStateWithFailure403 =
            dataState1.copyWith(failure: const Failure403());

        test('''WHEN called with $Failure403 and forceLoad=true
          THEN call "searchRepositoriesNextPage" and emit [$SearchRepositoriesCubitDataState(isLoadingMoreData=true) and $SearchRepositoriesCubitDataState with data from next page]''',
            () async {
          // Emit initial state with [Failure403].
          final BehaviorSubject<Either<Failure, RequestResults<ShortRepositoryEntity>>> subject =
              BehaviorSubject.seeded(
            Right(
              RequestResults(
                requestUri: mockUri,
                items: [mockShortRepositoryEntity1],
                paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
                failure: const Failure403(),
              ),
            ),
          );
          when(() => mockRepositoriesRepository.searchRepositoriesStream()).thenAnswer((_) => subject.stream);

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
            items: [mockShortRepositoryEntity2],
            paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
          )));
          await pumpEventQueue();

          // Verify data from next page.
          expect(cubit.state, dataState2);
          verify(() => mockRepositoriesRepository.searchRepositoriesNextPage());

          await subject.close();
        });
      });

      test('when called [pullToRefresh] emit new data', () async {
        // Emit initial state with [dataState1].
        final BehaviorSubject<Either<Failure, RequestResults<ShortRepositoryEntity>>> subject = BehaviorSubject.seeded(
          Right(
            RequestResults(
              requestUri: mockUri,
              items: [mockShortRepositoryEntity1],
              paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
              failure: null,
            ),
          ),
        );
        when(() => mockRepositoriesRepository.searchRepositoriesStream()).thenAnswer((_) => subject.stream);

        final cubit = createCubit();
        // Wait for first _load action that emits dataState1.
        await pumpEventQueue();
        expect(cubit.state, dataState1);

        await cubit.pullToRefresh(mockQuery);

        subject.add(Right(RequestResults(
          requestUri: mockDefaultUri,
          items: [mockShortRepositoryEntity2],
          paginationLinks: PaginationLinks(nextLink: Uri.parse('https://nextlink.com')),
        )));
        await pumpEventQueue();

        // Verify new data after pullToRefresh action.
        expect(cubit.state, dataState2);
        // [searchRepositoriesStream] should be called in constructor and after pullToRefresh.
        verify(() => mockRepositoriesRepository.searchRepositoriesStream()).called(2);

        await subject.close();
      });
    },
  );
}
