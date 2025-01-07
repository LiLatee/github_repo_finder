// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_owner_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortOwnerEntity _$ShortOwnerEntityFromJson(Map<String, dynamic> json) =>
    ShortOwnerEntity(
      id: (json['id'] as num).toInt(),
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );

Map<String, dynamic> _$ShortOwnerEntityToJson(ShortOwnerEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'avatar_url': instance.avatarUrl,
    };
