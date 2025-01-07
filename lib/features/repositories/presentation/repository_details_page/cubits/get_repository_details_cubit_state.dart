import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';

sealed class GetRepositoryDetailsCubitState extends Equatable {
  const GetRepositoryDetailsCubitState();

  @override
  List<Object?> get props => [];
}

class GetRepositoryDetailsCubitLoadingState extends GetRepositoryDetailsCubitState {
  const GetRepositoryDetailsCubitLoadingState();
}

class GetRepositoryDetailsCubitDataState extends GetRepositoryDetailsCubitState {
  GetRepositoryDetailsCubitDataState({
    required this.repository,
  });

  final RepositoryEntity repository;

  @override
  List<Object?> get props => [
        repository,
      ];
}

class GetRepositoryDetailsCubitErrorState extends GetRepositoryDetailsCubitState {
  const GetRepositoryDetailsCubitErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
