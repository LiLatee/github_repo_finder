import 'package:github_repo_finder/features/repositories/domain/entities/repository_entity.dart';

import 'mock_organization_entity.dart';

RepositoryEntity getMockRepositoryEntity({int? id}) => RepositoryEntity(
      id: id ?? 123,
      name: 'name',
      fullName: 'fullName',
      description: 'description',
      issuesUrl: 'issuesUrl',
      pullsUrl: 'pullsUrl',
      watchersCount: 123,
      hasIssues: true,
      openIssuesCount: 456,
      forksCount: 678,
      homepageUrl: 'homepageUrl',
      organizationEntity: getMockOrganizationEntity(),
    );
