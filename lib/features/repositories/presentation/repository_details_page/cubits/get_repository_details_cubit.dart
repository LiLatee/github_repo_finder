import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit_state.dart';

class GetRepositoryDetailsCubit extends Cubit<GetRepositoryDetailsCubitState> {
  GetRepositoryDetailsCubit({
    required RepositoriesRepository repositoriesRepository,
    required String ownerName,
    required String repoName,
  })  : _repositoriesRepository = repositoriesRepository,
        _ownerName = ownerName,
        _repoName = repoName,
        super(const GetRepositoryDetailsCubitLoadingState()) {
    unawaited(load());
  }

  final RepositoriesRepository _repositoriesRepository;
  final String _ownerName;
  final String _repoName;

  Future<void> load() async {
    Either<Failure, RepositoryEntity> either =
        await _repositoriesRepository.getRepository(ownerName: _ownerName, repoName: _repoName);

    emit(
      either.fold(
        (failure) => GetRepositoryDetailsCubitErrorState(failure),
        (repository) => GetRepositoryDetailsCubitDataState(repository: repository),
      ),
    );
  }
}
