import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/widgets/grf_error_widget.dart';
import 'package:github_repo_finder/core/widgets/grf_network_image.dart';
import 'package:github_repo_finder/core/widgets/grf_progress_indicator.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/repository_details_page.dart';
import 'package:github_repo_finder/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class RepositoriesPageList extends StatelessWidget {
  RepositoriesPageList({
    super.key,
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
      listener: (BuildContext context, SearchRepositoriesCubitState state) {
        if (state is SearchRepositoriesCubitDataState && state.failure is Failure403)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.repositoriesPage403Error),
              action: SnackBarAction(
                label: context.l10n.genericTryAgain,
                onPressed: () => context.read<SearchRepositoriesCubit>().loadNextPage(forceLoad: true),
              ),
            ),
          );
      },
      builder: (context, state) {
        return switch (state) {
          SearchRepositoriesCubitLoadingState() => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: const GrfProgressIndicator()),
            ),
          SearchRepositoriesCubitDataState(
            repositories: List<ShortRepositoryEntity> repositories,
            isLoadingMoreData: bool isLoadingMoreData,
            failure: Failure? failure,
          ) =>
            repositories.isEmpty
                ? _SliverEmptyList(query: textEditingController.text)
                : _SliverRepositoriesList(
                    repositories: repositories, failure: failure, isLoadingMoreData: isLoadingMoreData),
          SearchRepositoriesCubitErrorState(failure: Failure _) =>
            const SliverFillRemaining(hasScrollBody: false, child: GrfErrorWidget()),
        };
      },
    );
  }
}

class _SliverEmptyList extends StatelessWidget {
  const _SliverEmptyList({
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(64),
            Text(
              context.l10n.repositoriesPageNoResults(query),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverRepositoriesList extends StatelessWidget {
  const _SliverRepositoriesList({
    required this.repositories,
    required this.failure,
    required this.isLoadingMoreData,
  });

  final List<ShortRepositoryEntity> repositories;
  final Failure? failure;
  final bool isLoadingMoreData;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == repositories.length) {
            if (failure is Failure403) {
              return TextButton(
                onPressed: () => context.read<SearchRepositoriesCubit>().loadNextPage(forceLoad: true),
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
          final ShortRepositoryEntity repo = repositories[index];

          return InkWell(
            onTap: () => context.push(RepositoryDetailsPage.routeToPush(
              owner: repo.shortOwnerEntity.login,
              repo: repo.name,
            )),
            child: ListTile(
              title: Text(repo.fullName, maxLines: 2),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repo.description != null) Text(repo.description!, maxLines: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_outline),
                      const Gap(4),
                      Text(repo.watchersCount.toString()),
                    ],
                  ),
                ],
              ),
              leading: SizedBox(
                width: 64,
                child: GrfNetworkImage(
                  url: repo.shortOwnerEntity.avatarUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    foregroundImage: imageProvider,
                    radius: 32,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          );
        },
        childCount: isLoadingMoreData || failure is Failure403 ? repositories.length + 1 : repositories.length,
      ),
    );
  }
}
