// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_repository_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortRepositoryEntity _$ShortRepositoryEntityFromJson(
        Map<String, dynamic> json) =>
    ShortRepositoryEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      shortOwnerEntity:
          ShortOwnerEntity.fromJson(json['owner'] as Map<String, dynamic>),
      watchersCount: (json['watchers_count'] as num).toInt(),
      description: json['description'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$ShortRepositoryEntityToJson(
        ShortRepositoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'full_name': instance.fullName,
      'description': instance.description,
      'owner': instance.shortOwnerEntity,
      'language': instance.language,
      'watchers_count': instance.watchersCount,
    };
