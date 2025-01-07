import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo_finder/core/helpers/debouncer.dart';
import 'package:github_repo_finder/core/helpers/global_settings.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit_state.dart';

const String defaultQuery = 'flutter';

class SearchRepositoriesCubit extends Cubit<SearchRepositoriesCubitState> {
  SearchRepositoriesCubit({required RepositoriesRepository repositoriesRepository})
      : _repositoriesRepository = repositoriesRepository,
        super(const SearchRepositoriesCubitLoadingState()) {
    _load();
    search(defaultQuery);
  }

  final RepositoriesRepository _repositoriesRepository;
  final Debouncer debouncer = Debouncer(duration: grfDebounceDuration);
  StreamSubscription<Either<Failure, RequestResults<ShortRepositoryEntity>>>? streamSubscription;

  void _load() {
    streamSubscription = _repositoriesRepository.searchRepositoriesStream().listen(
      (event) {
        emit(
          event.fold(
            (failure) => SearchRepositoriesCubitErrorState(failure),
            (results) => SearchRepositoriesCubitDataState(
              repositories: results.items,
              isLoadingMoreData: false,
              hasMoreData: results.paginationLinks?.nextLink != null,
              failure: results.failure,
            ),
          ),
        );
      },
    );
  }

  Future<void> pullToRefresh(String query) async {
    switch (state) {
      case SearchRepositoriesCubitDataState() || SearchRepositoriesCubitErrorState():
        await streamSubscription?.cancel();
        _load();
        search(query);
      case SearchRepositoriesCubitLoadingState():
    }
  }

  Future<void> loadNextPage({bool forceLoad = false}) async {
    assert(state is SearchRepositoriesCubitDataState,
        'To call "loadNextPage" state must be $SearchRepositoriesCubitDataState ');

    if (state is! SearchRepositoriesCubitDataState) {
      return;
    }

    final SearchRepositoriesCubitDataState dataState = state as SearchRepositoriesCubitDataState;

    if (dataState.isLoadingMoreData || !dataState.hasMoreData) {
      return;
    }

    if (dataState.failure is Failure403 && !forceLoad) {
      return;
    }

    emit(dataState.copyWith(isLoadingMoreData: true));
    await _repositoriesRepository.searchRepositoriesNextPage();
  }

  void search(String query) {
    emit(const SearchRepositoriesCubitLoadingState());
    debouncer.run(
      () async {
        await _repositoriesRepository.searchRepositories(query: query.isEmpty ? defaultQuery : query);
      },
    );
  }

  @override
  Future<void> close() async {
    debouncer.cancel();
    await streamSubscription?.cancel();
    return super.close();
  }
}
