import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/core/helpers/utils.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/widgets/grf_error_widget.dart';
import 'package:github_repo_finder/core/widgets/grf_progress_indicator.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/cubits/get_pull_requests_cubit_state.dart';
import 'package:github_repo_finder/l10n/l10n.dart';
import 'package:timeago/timeago.dart' as time_ago;

class SliverPullRequestsList extends StatelessWidget {
  const SliverPullRequestsList({
    super.key,
    required this.ownerName,
    required this.repoName,
  });

  final String ownerName;
  final String repoName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPullRequestsCubit, GetPullRequestsCubitState>(
      builder: (context, state) {
        switch (state) {
          case GetPullRequestsCubitLoadingState():
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: GrfProgressIndicator(),
              ),
            );

          case GetPullRequestsCubitErrorState():
            return SliverFillRemaining(
              hasScrollBody: false,
              child: GrfErrorWidget(
                onPressed: () async => context.read<GetPullRequestsCubit>().refresh(),
              ),
            );
          case GetPullRequestsCubitDataState():
            return _SliverData(
              state: state,
              ownerName: ownerName,
              repoName: repoName,
            );
        }
      },
    );
  }
}

class _SliverData extends StatelessWidget {
  const _SliverData({
    required this.state,
    required this.ownerName,
    required this.repoName,
  });

  final GetPullRequestsCubitDataState state;
  final String ownerName;
  final String repoName;

  @override
  Widget build(BuildContext context) {
    if (state.pullRequests.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          children: [
            const Gap(24),
            Text(
              context.l10n.genericEmptyList,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(24),
          ],
        ),
      );
    }

    return SliverList.builder(
      itemCount: state.isLoadingMoreData || state.failure is Failure403
          ? state.pullRequests.length + 1
          : state.pullRequests.length,
      itemBuilder: (context, index) {
        if (index == state.pullRequests.length) {
          if (state.failure is Failure403) {
            return TextButton(
              onPressed: () => context.read<GetPullRequestsCubit>().loadNextPage(forceLoad: true),
              child: Text(context.l10n.genericTryAgain),
            );
          }

          // Last item. Show loading more data indicator.
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 16),
            child: const GrfProgressIndicator(),
          );
        }

        final ShortPullRequestEntity pullRequest = state.pullRequests[index];

        return InkWell(
          onTap: () => openUrl('https://github.com/$ownerName/$repoName/pull/${pullRequest.number}'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fork_left_outlined, color: Colors.green),
            title: Text.rich(
              TextSpan(
                text: pullRequest.title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: ' #${pullRequest.number}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
            trailing: pullRequest.createdAt != null ? Text(time_ago.format(pullRequest.createdAt!)) : null,
          ),
        );
      },
    );
  }
}
