import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/helpers/on_notification_listener.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/cubits/search_repositories_cubit_state.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/widgets/repositories_page_list.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/widgets/repositories_page_search_bar.dart';

class RepositoriesPage extends StatefulWidget {
  const RepositoriesPage({super.key});

  static const String route = 'repositories';
  static const String routeToPush = '/$route';

  @override
  State<RepositoriesPage> createState() => _RepositoriesPageState();
}

class _RepositoriesPageState extends State<RepositoriesPage> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchRepositoriesCubit>(),
      child: BlocBuilder<SearchRepositoriesCubit, SearchRepositoriesCubitState>(
        builder: (context, state) {
          bool isDataState = state is SearchRepositoriesCubitDataState;

          return Scaffold(
            body: NotificationListener(
              onNotification: (ScrollNotification scrollInfo) => onScrollNotification(
                scrollInfo: scrollInfo,
                context: context,
                loadingMore: isDataState ? state.isLoadingMoreData : false,
                hasMoreToLoad: isDataState ? state.hasMoreData : false,
                loadMore: context.read<SearchRepositoriesCubit>().loadNextPage,
              ),
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<SearchRepositoriesCubit>().pullToRefresh(textEditingController.text),
                // 56 - height of TextField.
                edgeOffset: 56 + MediaQuery.paddingOf(context).top,
                child: CustomScrollView(
                  slivers: [
                    SliverRepositoriesPageSearchBar(textEditingController: textEditingController),
                    RepositoriesPageList(textEditingController: textEditingController),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RepositoriesGQLPage extends StatelessWidget {
  const RepositoriesGQLPage({super.key});

  static const String route = 'repositories-gql';
  static const String routeToPush = '/$route';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('In the future... maybe :)'),
      ),
    );
  }
}
