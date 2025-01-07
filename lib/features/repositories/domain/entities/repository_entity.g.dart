// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepositoryEntity _$RepositoryEntityFromJson(Map<String, dynamic> json) =>
    RepositoryEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      issuesUrl: json['issues_url'] as String,
      pullsUrl: json['pulls_url'] as String,
      watchersCount: (json['watchers_count'] as num).toInt(),
      hasIssues: json['has_issues'] as bool,
      openIssuesCount: (json['open_issues_count'] as num).toInt(),
      forksCount: (json['forks'] as num).toInt(),
      homepageUrl: json['homepage'] as String?,
      organizationEntity: json['organization'] == null
          ? null
          : OrganizationEntity.fromJson(
              json['organization'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepositoryEntityToJson(RepositoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'full_name': instance.fullName,
      'description': instance.description,
      'issues_url': instance.issuesUrl,
      'pulls_url': instance.pullsUrl,
      'watchers_count': instance.watchersCount,
      'has_issues': instance.hasIssues,
      'open_issues_count': instance.openIssuesCount,
      'forks': instance.forksCount,
      'homepage': instance.homepageUrl,
      'organization': instance.organizationEntity,
    };
