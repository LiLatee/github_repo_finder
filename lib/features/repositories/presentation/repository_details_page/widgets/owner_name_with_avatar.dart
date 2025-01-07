import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/core/widgets/grf_network_image.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';

class OwnerNameWithAvatar extends StatelessWidget {
  const OwnerNameWithAvatar({
    super.key,
    required this.repository,
  });

  final RepositoryEntity repository;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (repository.organizationEntity != null) ...[
          GrfNetworkImage(
            url: repository.organizationEntity!.avatarUrl,
            imageBuilder: (context, imageProvider) => Image(
              image: imageProvider,
              width: 24,
              height: 24,
            ),
          ),
          const Gap(4),
          Text(repository.organizationEntity!.login),
        ]
      ],
    );
  }
}
