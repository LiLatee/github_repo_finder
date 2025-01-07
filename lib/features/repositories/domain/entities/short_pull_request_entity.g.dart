// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_pull_request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortPullRequestEntity _$ShortPullRequestEntityFromJson(
        Map<String, dynamic> json) =>
    ShortPullRequestEntity(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      number: (json['number'] as num).toInt(),
      state: ShortPullRequestEntity.stateFromString(json['state'] as String),
      title: json['title'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ShortPullRequestEntityToJson(
        ShortPullRequestEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'number': instance.number,
      'state': ShortPullRequestEntity.stateToString(instance.state),
      'title': instance.title,
      'created_at': instance.createdAt?.toIso8601String(),
    };
