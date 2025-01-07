import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';

sealed class GetPullRequestsCubitState extends Equatable {
  const GetPullRequestsCubitState();

  @override
  List<Object?> get props => [];
}

class GetPullRequestsCubitLoadingState extends GetPullRequestsCubitState {
  const GetPullRequestsCubitLoadingState();
}

class GetPullRequestsCubitDataState extends GetPullRequestsCubitState {
  GetPullRequestsCubitDataState({
    required this.pullRequests,
    required this.isLoadingMoreData,
    required this.hasMoreData,
    required this.failure,
  });

  final List<ShortPullRequestEntity> pullRequests;
  final bool isLoadingMoreData;
  final bool hasMoreData;
  final Failure? failure;

  GetPullRequestsCubitDataState copyWith({
    List<ShortPullRequestEntity>? pullRequests,
    bool? isLoadingMoreData,
    bool? hasMoreData,
    Failure? failure,
  }) {
    return GetPullRequestsCubitDataState(
      pullRequests: pullRequests ?? this.pullRequests,
      isLoadingMoreData: isLoadingMoreData ?? this.isLoadingMoreData,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        pullRequests,
        isLoadingMoreData,
        hasMoreData,
        failure,
      ];
}

class GetPullRequestsCubitErrorState extends GetPullRequestsCubitState {
  const GetPullRequestsCubitErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
