import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_entity.g.dart';

@JsonSerializable()
class OrganizationEntity extends Equatable {
  OrganizationEntity({
    required this.id,
    required this.login,
    required this.avatarUrl,
  });

  factory OrganizationEntity.fromJson(Map<String, dynamic> json) => _$OrganizationEntityFromJson(json);

  final int id;

  final String login;

  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  Map<String, dynamic> toJson() => _$OrganizationEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        login,
        avatarUrl,
      ];
}
