import 'package:github_repo_finder/features/repositories/domain/entities/pull_request_state_enum.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_pull_request_entity.dart';

ShortPullRequestEntity getMockShortPullRequestEntity({int? id}) => ShortPullRequestEntity(
      id: id ?? 123,
      url: 'url',
      number: 123,
      state: PullRequestStateEnum.open,
      title: 'title',
      createdAt: DateTime.utc(2024, 11, 21),
    );
