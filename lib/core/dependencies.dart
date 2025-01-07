import 'dart:async';
import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:github_repo_finder/core/navigation/go_router.dart';
import 'package:github_repo_finder/core/navigation/go_router_extension.dart';
import 'package:github_repo_finder/core/networking/chopper_client/chopper_client.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:github_repo_finder/core/tests_manager.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/pull_requests_repository.dart';
import 'package:github_repo_finder/features/repositories/data/repositories/repositories_repository.dart';
import 'package:github_repo_finder/features/repositories/data/services/repositories_service.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart';

final sl = GetIt.instance;

Future<void> setupDependencies({required FirebaseApp firebaseApp}) async {
  /// CrashlyticsErrorReporter must be initialized ASAP in order to handle errors from runZonedGuarded.
  final errorReporter = CrashlyticsErrorReporter();
  await errorReporter.initReporter();
  sl.registerLazySingleton<CrashlyticsErrorReporter>(() => errorReporter);

  sl.registerLazySingleton(() => FirebaseAnalytics.instanceFor(app: firebaseApp));

  await initializeDateFormatting();
  goRouter.routerDelegate.addListener(
    () {
      if (kReleaseMode) {
        sl<FirebaseAnalytics>().logScreenView(
          screenName: goRouter.fullPath,
          parameters: goRouter.pathParameters,
        );
        log('📄 [ANALYTICS][SENT] Screen name: ${goRouter.fullPath}, parameters: ${goRouter.pathParameters}');
      } else {
        log('📄 [ANALYTICS] Screen name: ${goRouter.fullPath}, parameters: ${goRouter.pathParameters}');
      }
    },
  );

  sl.registerLazySingleton<GoRouter>(() => goRouter);
  sl.registerLazySingleton<ChopperClient>(getChopperClient);
  sl.registerLazySingleton<Client>(httpClient);
  sl.registerLazySingleton<TestsManager>(() => TestsManager());

  // ! Repositories
  sl.registerLazySingleton(
    () => RepositoriesRepository(repositoriesService: sl<ChopperClient>().getService<RepositoriesService>()),
  );
  sl.registerLazySingleton(
    () => PullRequestsRepository(repositoriesService: sl<ChopperClient>().getService<RepositoriesService>()),
  );

  // ! Blocs/Cubits
  sl.registerFactory(() => SearchRepositoriesCubit(repositoriesRepository: sl<RepositoriesRepository>()));
  sl.registerFactoryParam<GetRepositoryDetailsCubit, String, String>(
    (String ownerName, String repoName) => GetRepositoryDetailsCubit(
      repositoriesRepository: sl<RepositoriesRepository>(),
      ownerName: ownerName,
      repoName: repoName,
    ),
  );
  sl.registerFactoryParam<GetPullRequestsCubit, String, String>(
    (String ownerName, String repoName) => GetPullRequestsCubit(
      pullRequestsRepository: sl<PullRequestsRepository>(),
      ownerName: ownerName,
      repoName: repoName,
    ),
  );
}
