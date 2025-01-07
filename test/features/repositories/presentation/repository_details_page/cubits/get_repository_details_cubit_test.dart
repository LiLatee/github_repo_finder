import 'package:either_dart/either.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../domain/entities/mock_repository_entity.dart';
import '../../repositories_page/cubits/search_repositories_cubit_test.dart';

void main() {
  group(
    '$GetRepositoryDetailsCubit -',
    () {
      const String mockOwnerName = 'ownerName';
      const String mockRepoName = 'repoName';
      const Failure mockFailure = FailureWithMessage('message');
      final RepositoryEntity mockRepositoryEntity1 = getMockRepositoryEntity(id: 1);
      final RepositoryEntity mockRepositoryEntity2 = getMockRepositoryEntity(id: 2);

      late RepositoriesRepository mockRepositoriesRepository;

      setUp(() {
        mockRepositoriesRepository = MockRepositoriesRepository();
        when(() => mockRepositoriesRepository.getRepository(ownerName: mockOwnerName, repoName: mockRepoName))
            .thenAnswer((_) async => Right(mockRepositoryEntity1));
      });

      GetRepositoryDetailsCubit createCubit() => GetRepositoryDetailsCubit(
            repositoriesRepository: mockRepositoriesRepository,
            ownerName: mockOwnerName,
            repoName: mockRepoName,
          );

      test(
        'on start state is $GetRepositoryDetailsCubitLoadingState',
        () async {
          final cubit = createCubit();

          expect(cubit.state, const GetRepositoryDetailsCubitLoadingState());
        },
      );

      test(
        'on start when data is loaded state is $GetRepositoryDetailsCubitDataState',
        () async {
          final cubit = createCubit();
          await pumpEventQueue();

          expect(cubit.state, GetRepositoryDetailsCubitDataState(repository: mockRepositoryEntity1));
        },
      );

      test(
        'when load is called and repository returns failure then emit $GetRepositoryDetailsCubitErrorState',
        () async {
          when(() => mockRepositoriesRepository.getRepository(ownerName: mockOwnerName, repoName: mockRepoName))
              .thenAnswer((_) async => const Left(mockFailure));

          final cubit = createCubit();
          await pumpEventQueue();

          expect(cubit.state, const GetRepositoryDetailsCubitErrorState(mockFailure));
        },
      );

      test(
        'when load is called and repository returns data then emit $GetRepositoryDetailsCubitDataState with new data',
        () async {
          final cubit = createCubit();
          await pumpEventQueue();

          expect(cubit.state, GetRepositoryDetailsCubitDataState(repository: mockRepositoryEntity1));

          when(() => mockRepositoriesRepository.getRepository(ownerName: mockOwnerName, repoName: mockRepoName))
              .thenAnswer((_) async => Right(mockRepositoryEntity2));

          await cubit.load();
          await pumpEventQueue();

          expect(cubit.state, GetRepositoryDetailsCubitDataState(repository: mockRepositoryEntity2));
        },
      );
    },
  );
}
