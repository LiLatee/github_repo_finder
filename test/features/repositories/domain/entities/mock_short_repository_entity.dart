import 'package:github_repo_finder/features/repositories/domain/entities/short_repository_entity.dart';

import 'mock_short_owner_entity.dart';

ShortRepositoryEntity getMockShortRepositoryEntity({
  int? id,
  String? fullName,
  int? watchersCount,
}) =>
    ShortRepositoryEntity(
      id: id ?? 123,
      name: 'name',
      fullName: fullName ?? 'fullName',
      shortOwnerEntity: getMockShortOwnerEntity(),
      watchersCount: watchersCount ?? 321,
    );
