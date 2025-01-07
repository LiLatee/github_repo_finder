import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:either_dart/either.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/request_results.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:rxdart/subjects.dart';

class PullRequestsRepository {
  PullRequestsRepository({
    required RepositoriesService repositoriesService,
  }) : _repositoriesService = repositoriesService;
  final RepositoriesService _repositoriesService;

  late final BehaviorSubject<Either<Failure, RequestResults<ShortPullRequestEntity>>> _pullRequestsSubject =
      BehaviorSubject();

  Stream<Either<Failure, RequestResults<ShortPullRequestEntity>>> getPullRequestsStream() =>
      _pullRequestsSubject.stream;

  Future<void> getPullRequests({
    required String ownerName,
    required String repoName,
  }) async {
    try {
      final Either<Failure, RequestResults<ShortPullRequestEntity>>? lastValue = _pullRequestsSubject.valueOrNull;

      // Make request if:
      // - there was no any value yet,
      // - OR last value was an error (left),
      // - OR it's different request than previous one.
      if (lastValue == null ||
          lastValue.isLeft ||
          (lastValue.isRight && lastValue.right.requestUri.queryParameters['q'] != query)) {
        final Response<RequestResults<ShortPullRequestEntity>> response =
            await _repositoriesService.getPullRequests(ownerName: ownerName, repoName: repoName);

        final RequestResults<ShortPullRequestEntity>? body = response.body;
        if (body != null) {
          _pullRequestsSubject.add(Right(body));
          return;
        } else {
          unawaited(sl<CrashlyticsErrorReporter>().logException(
            exception:
                Exception('Unexpected: Called [getPullRequests] with query=$query but body was null. Data: $response'),
            stackTrace: StackTrace.current,
          ));
          _pullRequestsSubject.add(const Left(FailureApiReturnedNull()));
          return;
        }
      }
    } catch (err, st) {
      const String errorMessage = '[getPullRequests] unexpected error. Possibly internet issues.';
      unawaited(sl<CrashlyticsErrorReporter>().logException(
        exception: Exception(errorMessage),
        stackTrace: st,
      ));
    }
  }

  Future<void> getPullRequestsNextPage() async {
    try {
      final Either<Failure, RequestResults<ShortPullRequestEntity>>? lastValue = _pullRequestsSubject.valueOrNull;
      if (lastValue == null) {
        unawaited(sl<CrashlyticsErrorReporter>().logException(
          exception:
              Exception('Unexpected: Tried to call [getPullRequestsNextPage] without fetching pullRequests once.'),
          stackTrace: StackTrace.current,
        ));
        return;
      }

      final Uri? nextLink = lastValue.right.paginationLinks?.nextLink;
      final String ownerName =
          lastValue.right.requestUri.pathSegments[lastValue.right.requestUri.pathSegments.length - 3];
      final String repoName =
          lastValue.right.requestUri.pathSegments[lastValue.right.requestUri.pathSegments.length - 2];
      final List<ShortPullRequestEntity> currentItems = lastValue.right.items;

      if (nextLink != null) {
        final int nextPage = int.parse(nextLink.queryParameters['page'] as String);

        final Response<RequestResults<ShortPullRequestEntity>> response = await _repositoriesService.getPullRequests(
          ownerName: ownerName,
          repoName: repoName,
          page: nextPage,
        );

        final RequestResults<ShortPullRequestEntity>? body = response.body;
        if (body != null) {
          _pullRequestsSubject.add(
            Right(body.copyWith(items: [...currentItems, ...body.items])),
          );
          return;
        } else {
          unawaited(sl<CrashlyticsErrorReporter>().logException(
            exception: Exception(
                'Unexpected: Called [getPullRequestsNextPage] but body was null, so last known value was returned. Data: $response'),
            stackTrace: StackTrace.current,
          ));

          if (response.statusCode == 403 && lastValue.isRight) {
            _pullRequestsSubject.add(Right(lastValue.right.copyWith(failure: const Failure403())));
          } else {
            _pullRequestsSubject.add(lastValue);
          }
          return;
        }
      }
    } catch (err, st) {
      const String errorMessage = '[getPullRequestsNextPage] unexpected error. Possibly internet issues.';
      unawaited(sl<CrashlyticsErrorReporter>().logException(
        exception: Exception(errorMessage),
        stackTrace: st,
      ));
    }
  }
}
