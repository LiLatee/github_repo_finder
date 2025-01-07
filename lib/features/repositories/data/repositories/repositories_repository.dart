import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:either_dart/either.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';
import 'package:rxdart/subjects.dart';

class RepositoriesRepository {
  RepositoriesRepository({
    required RepositoriesService repositoriesService,
  }) : _repositoriesService = repositoriesService;
  final RepositoriesService _repositoriesService;

  late final BehaviorSubject<Either<Failure, RequestResults<ShortRepositoryEntity>>> _repositoriesSubject =
      BehaviorSubject();

  Stream<Either<Failure, RequestResults<ShortRepositoryEntity>>> searchRepositoriesStream() =>
      _repositoriesSubject.stream;

  Future<void> searchRepositories({
    required String query,
  }) async {
    try {
      final Either<Failure, RequestResults<ShortRepositoryEntity>>? lastValue = _repositoriesSubject.valueOrNull;

      // Make request if:
      // - there was no any value yet,
      // - OR last value was an error (left),
      // - OR it's different request than previous one.
      if (lastValue == null ||
          lastValue.isLeft ||
          (lastValue.isRight && lastValue.right.requestUri.queryParameters['q'] != query)) {
        final Response<RequestResults<ShortRepositoryEntity>> response =
            await _repositoriesService.search(query: query);

        final RequestResults<ShortRepositoryEntity>? body = response.body;
        if (body != null) {
          _repositoriesSubject.add(Right(body));
          return;
        } else {
          unawaited(sl<CrashlyticsErrorReporter>().logException(
            exception: Exception(
                'Unexpected: Called [searchRepositories] with query=$query but body was null. Data: $response'),
            stackTrace: StackTrace.current,
          ));
          _repositoriesSubject.add(const Left(FailureApiReturnedNull()));
          return;
        }
      }
    } catch (err, st) {
      const String errorMessage = '[searchRepositories] unexpected error. Possibly internet issues.';
      unawaited(sl<CrashlyticsErrorReporter>().logException(
        exception: Exception(errorMessage),
        stackTrace: st,
      ));
    }
  }

  Future<void> searchRepositoriesNextPage() async {
    try {
      final Either<Failure, RequestResults<ShortRepositoryEntity>>? lastValue = _repositoriesSubject.valueOrNull;
      if (lastValue == null) {
        unawaited(sl<CrashlyticsErrorReporter>().logException(
          exception:
              Exception('Unexpected: Tried to call [searchRepositoriesNextPage] without fetching repositories once.'),
          stackTrace: StackTrace.current,
        ));
        return;
      }

      final Uri? nextLink = lastValue.right.paginationLinks?.nextLink;
      final Map<String, String> queryParameters = lastValue.right.requestUri.queryParameters;
      final List<ShortRepositoryEntity> currentItems = lastValue.right.items;

      if (nextLink != null) {
        final int nextPage = int.parse(nextLink.queryParameters['page'] as String);

        final Response<RequestResults<ShortRepositoryEntity>> response = await _repositoriesService.search(
          query: queryParameters['q']!,
          page: nextPage,
        );

        final RequestResults<ShortRepositoryEntity>? body = response.body;
        if (body != null) {
          _repositoriesSubject.add(
            Right(body.copyWith(items: [...currentItems, ...body.items])),
          );
          return;
        } else {
          unawaited(sl<CrashlyticsErrorReporter>().logException(
            exception: Exception(
                'Unexpected: Called [searchRepositoriesNextPage] but body was null, so last known value was returned. Data: $response'),
            stackTrace: StackTrace.current,
          ));

          if (response.statusCode == 403 && lastValue.isRight) {
            _repositoriesSubject.add(Right(lastValue.right.copyWith(failure: const Failure403())));
          } else {
            _repositoriesSubject.add(lastValue);
          }
          return;
        }
      }
    } catch (err, st) {
      const String errorMessage = '[searchRepositoriesNextPage] unexpected error. Possibly internet issues.';
      unawaited(sl<CrashlyticsErrorReporter>().logException(
        exception: Exception(errorMessage),
        stackTrace: st,
      ));
    }
  }

  Future<Either<Failure, RepositoryEntity>> getRepository({
    required String ownerName,
    required String repoName,
  }) async {
    try {
      final Response<RepositoryEntity> response =
          await _repositoriesService.getRepository(ownerName: ownerName, repoName: repoName);

      if (response.body != null) {
        return Right(response.body!);
      } else {
        unawaited(sl<CrashlyticsErrorReporter>().logException(
          exception: Exception('[getRepository] returned null body. Data: $response'),
          stackTrace: StackTrace.current,
        ));
        return Left(FailureWithMessage('[getRepository] returned null', stackTrace: StackTrace.current));
      }
    } catch (err, st) {
      const String errorMessage = '[getRepository] unexpected error. Possibly internet issues.';
      unawaited(sl<CrashlyticsErrorReporter>().logException(
        exception: Exception(errorMessage),
        stackTrace: StackTrace.current,
      ));
      return Left(FailureWithMessage(errorMessage, stackTrace: st));
    }
  }
}
