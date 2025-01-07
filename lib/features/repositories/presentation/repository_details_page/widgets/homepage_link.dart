import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/core/helpers/utils.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';

class HomePageLink extends StatelessWidget {
  const HomePageLink({
    super.key,
    required this.repository,
  });

  final RepositoryEntity repository;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: repository.homepageUrl != null ? () => openUrl(repository.homepageUrl!) : null,
      child: Row(
        children: [
          const Icon(Icons.link, size: 24),
          const Gap(4),
          Text(
            repository.homepageUrl!,
            style: const TextStyle().copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
