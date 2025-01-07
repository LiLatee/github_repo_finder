import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/organization_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repository_entity.g.dart';

@JsonSerializable()
class RepositoryEntity extends Equatable {
  RepositoryEntity({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.issuesUrl,
    required this.pullsUrl,
    required this.watchersCount,
    required this.hasIssues,
    required this.openIssuesCount,
    required this.forksCount,
    required this.homepageUrl,
    required this.organizationEntity,
  });

  factory RepositoryEntity.fromJson(Map<String, dynamic> json) => _$RepositoryEntityFromJson(json);

  final int id;
  final String name;

  @JsonKey(name: 'full_name')
  final String fullName;

  final String? description;

  @JsonKey(name: 'issues_url')
  final String issuesUrl;

  @JsonKey(name: 'pulls_url')
  final String pullsUrl;

  @JsonKey(name: 'watchers_count')
  final int watchersCount;

  @JsonKey(name: 'has_issues')
  final bool hasIssues;

  @JsonKey(name: 'open_issues_count')
  final int openIssuesCount;

  @JsonKey(name: 'forks')
  final int forksCount;

  @JsonKey(name: 'homepage')
  final String? homepageUrl;

  @JsonKey(name: 'organization')
  final OrganizationEntity? organizationEntity;

  Map<String, dynamic> toJson() => _$RepositoryEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        fullName,
        description,
        issuesUrl,
        pullsUrl,
        watchersCount,
        hasIssues,
        openIssuesCount,
        forksCount,
        homepageUrl,
        organizationEntity,
      ];
}
