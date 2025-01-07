// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationEntity _$OrganizationEntityFromJson(Map<String, dynamic> json) =>
    OrganizationEntity(
      id: (json['id'] as num).toInt(),
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );

Map<String, dynamic> _$OrganizationEntityToJson(OrganizationEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'avatar_url': instance.avatarUrl,
    };
