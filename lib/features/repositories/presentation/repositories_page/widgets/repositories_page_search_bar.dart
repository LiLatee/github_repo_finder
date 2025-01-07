import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';
import 'package:github_repo_finder/l10n/l10n.dart';

class SliverRepositoriesPageSearchBar extends StatelessWidget {
  const SliverRepositoriesPageSearchBar({
    super.key,
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                height: 56,
                child: TextField(
                  controller: textEditingController,
                  onChanged: (query) => context.read<SearchRepositoriesCubit>().search(query),
                  decoration: InputDecoration(
                    hintText: context.l10n.repositoriesPageSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        context.read<SearchRepositoriesCubit>().search('');
                        textEditingController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
