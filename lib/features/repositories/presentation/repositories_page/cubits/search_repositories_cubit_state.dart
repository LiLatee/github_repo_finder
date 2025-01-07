import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';

sealed class SearchRepositoriesCubitState extends Equatable {
  const SearchRepositoriesCubitState();

  @override
  List<Object?> get props => [];
}

class SearchRepositoriesCubitLoadingState extends SearchRepositoriesCubitState {
  const SearchRepositoriesCubitLoadingState();
}

class SearchRepositoriesCubitDataState extends SearchRepositoriesCubitState {
  SearchRepositoriesCubitDataState({
    required this.repositories,
    required this.isLoadingMoreData,
    required this.hasMoreData,
    required this.failure,
  });

  final List<ShortRepositoryEntity> repositories;
  final bool isLoadingMoreData;
  final bool hasMoreData;
  final Failure? failure;

  SearchRepositoriesCubitDataState copyWith({
    List<ShortRepositoryEntity>? repositories,
    bool? isLoadingMoreData,
    bool? hasMoreData,
    Failure? failure,
  }) {
    return SearchRepositoriesCubitDataState(
      repositories: repositories ?? this.repositories,
      isLoadingMoreData: isLoadingMoreData ?? this.isLoadingMoreData,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        repositories,
        isLoadingMoreData,
        hasMoreData,
        failure,
      ];
}

class SearchRepositoriesCubitErrorState extends SearchRepositoriesCubitState {
  const SearchRepositoriesCubitErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
