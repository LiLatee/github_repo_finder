import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/pull_requests_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit_state.dart';

class GetPullRequestsCubit extends Cubit<GetPullRequestsCubitState> {
  GetPullRequestsCubit({
    required PullRequestsRepository pullRequestsRepository,
    required String ownerName,
    required String repoName,
  })  : _pullRequestsRepository = pullRequestsRepository,
        super(const GetPullRequestsCubitLoadingState()) {
    _load();
    _pullRequestsRepository.getPullRequests(ownerName: ownerName, repoName: repoName);
  }

  final PullRequestsRepository _pullRequestsRepository;

  StreamSubscription<Either<Failure, RequestResults<ShortPullRequestEntity>>>? streamSubscription;

  void _load() {
    streamSubscription = _pullRequestsRepository.getPullRequestsStream().listen(
      (event) {
        emit(
          event.fold(
            (failure) => GetPullRequestsCubitErrorState(failure),
            (results) => GetPullRequestsCubitDataState(
              pullRequests: results.items,
              isLoadingMoreData: false,
              hasMoreData: results.paginationLinks?.nextLink != null,
              failure: results.failure,
            ),
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    switch (state) {
      case GetPullRequestsCubitDataState() || GetPullRequestsCubitErrorState():
        emit(const GetPullRequestsCubitLoadingState());
        await streamSubscription?.cancel();
        _load();
      case GetPullRequestsCubitLoadingState():
    }
  }

  Future<void> loadNextPage({bool forceLoad = false}) async {
    assert(
        state is GetPullRequestsCubitDataState, 'To call "loadNextPage" state must be $GetPullRequestsCubitDataState ');

    if (state is! GetPullRequestsCubitDataState) {
      return;
    }

    final GetPullRequestsCubitDataState dataState = state as GetPullRequestsCubitDataState;

    if (dataState.isLoadingMoreData || !dataState.hasMoreData) {
      return;
    }

    if (dataState.failure is Failure403 && !forceLoad) {
      return;
    }

    emit(dataState.copyWith(isLoadingMoreData: true));
    await _pullRequestsRepository.getPullRequestsNextPage();
  }

  @override
  Future<void> close() async {
    await streamSubscription?.cancel();
    return super.close();
  }
}
