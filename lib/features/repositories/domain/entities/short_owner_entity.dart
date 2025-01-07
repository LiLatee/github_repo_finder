import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'short_owner_entity.g.dart';

@JsonSerializable()
class ShortOwnerEntity extends Equatable {
  ShortOwnerEntity({
    required this.id,
    required this.login,
    required this.avatarUrl,
  });

  factory ShortOwnerEntity.fromJson(Map<String, dynamic> json) => _$ShortOwnerEntityFromJson(json);

  final int id;
  final String login;

  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  Map<String, dynamic> toJson() => _$ShortOwnerEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        login,
        avatarUrl,
      ];
}
