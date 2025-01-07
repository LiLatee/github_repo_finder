import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/helpers/on_notification_listener.dart';
import 'package:github_repo_finder/core/widgets/grf_error_widget.dart';
import 'package:github_repo_finder/core/widgets/grf_progress_indicator.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/repositories_page.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_repository_details_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/widgets/homepage_link.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/widgets/owner_name_with_avatar.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/widgets/sliver_pull_requests_list.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/widgets/stars_and_forks.dart';
import 'package:github_repo_finder/l10n/l10n.dart';

class RepositoryDetailsPage extends StatelessWidget {
  const RepositoryDetailsPage({
    super.key,
    required this.ownerName,
    required this.repoName,
  });

  static const String ownerParamKey = 'owner';
  static const String repoNameParamKey = 'repo';

  static const String route = ':$ownerParamKey/:$repoNameParamKey';
  static String routeToPush({
    required String owner,
    required String repo,
  }) =>
      '${RepositoriesPage.routeToPush}/$owner/$repo';

  final String ownerName;
  final String repoName;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<GetRepositoryDetailsCubit>(param1: ownerName, param2: repoName)),
        BlocProvider(create: (context) => sl<GetPullRequestsCubit>(param1: ownerName, param2: repoName)),
      ],
      child: BlocBuilder<GetRepositoryDetailsCubit, GetRepositoryDetailsCubitState>(
        builder: (context, state) {
          Widget bodyWidget = switch (state) {
            GetRepositoryDetailsCubitLoadingState() => const Center(child: GrfProgressIndicator()),
            GetRepositoryDetailsCubitErrorState() =>
              GrfErrorWidget(onPressed: context.read<GetRepositoryDetailsCubit>().load),
            GetRepositoryDetailsCubitDataState(repository: RepositoryEntity repository) => _DataWidget(
                repository: repository,
                ownerName: ownerName,
                repoName: repoName,
              ),
          };
          final bool isDataState = state is GetRepositoryDetailsCubitDataState;

          return RefreshIndicator(
            onRefresh: () async => context.read<GetRepositoryDetailsCubit>().load(),
            edgeOffset: MediaQuery.paddingOf(context).top,
            child: Scaffold(
              extendBodyBehindAppBar: !isDataState,
              appBar: AppBar(
                title: Text('$ownerName/$repoName'),
                centerTitle: false,
              ),
              body: bodyWidget,
            ),
          );
        },
      ),
    );
  }
}

class _DataWidget extends StatelessWidget {
  const _DataWidget({
    required this.repository,
    required this.ownerName,
    required this.repoName,
  });

  final RepositoryEntity repository;
  final String ownerName;
  final String repoName;

  @override
  Widget build(BuildContext context) {
    final GetPullRequestsCubitState cubitPullRequestsState = context.watch<GetPullRequestsCubit>().state;
    bool isDataStateGetPullRequestsCubit = cubitPullRequestsState is GetPullRequestsCubitDataState;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) => onScrollNotification(
          scrollInfo: scrollInfo,
          context: context,
          loadingMore: isDataStateGetPullRequestsCubit ? cubitPullRequestsState.isLoadingMoreData : false,
          hasMoreToLoad: isDataStateGetPullRequestsCubit ? cubitPullRequestsState.hasMoreData : false,
          loadMore: context.read<GetPullRequestsCubit>().loadNextPage,
        ),
        child: CustomScrollView(
          slivers: [
                OwnerNameWithAvatar(repository: repository),
                const Gap(8),
                Text(
                  repository.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(12),
                if (repository.description != null) ...[
                  Text(repository.description!),
                  const Gap(12),
                ],
                if (repository.homepageUrl != null && repository.homepageUrl!.isNotEmpty) ...[
                  HomePageLink(repository: repository),
                  const Gap(12),
                ],
                StarsAndForks(repository: repository),
                const Divider(),
                const Gap(4),
                Text(
                  context.l10n.repositoryDetailsPagePullRequests,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(8),
              ].map<Widget>((e) => SliverToBoxAdapter(child: e)).toList(growable: false) +
              [
                SliverPullRequestsList(ownerName: ownerName, repoName: repoName),
              ],
        ),
      ),
    );
  }
}
