import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';
import 'package:github_repo_finder/l10n/l10n.dart';

class StarsAndForks extends StatelessWidget {
  const StarsAndForks({
    super.key,
    required this.repository,
  });

  final RepositoryEntity repository;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_outline),
        const Gap(4),
        Text(
          repository.watchersCount.toString(),
          style: const TextStyle().copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(2),
        Text(context.l10n.repositoryStars),
        const Gap(12),
        const Icon(Icons.fork_right),
        const Gap(4),
        Text(
          repository.forksCount.toString(),
          style: const TextStyle().copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(2),
        Text(context.l10n.repositoryForks),
      ],
    );
  }
}
