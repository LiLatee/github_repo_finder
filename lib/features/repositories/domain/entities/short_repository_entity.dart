import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/short_owner_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'short_repository_entity.g.dart';

@JsonSerializable()
class ShortRepositoryEntity extends Equatable {
  ShortRepositoryEntity({
    required this.id,
    required this.name,
    required this.fullName,
    required this.shortOwnerEntity,
    required this.watchersCount,
    this.description,
    this.language,
  });

  factory ShortRepositoryEntity.fromJson(Map<String, dynamic> json) => _$ShortRepositoryEntityFromJson(json);

  final int id;
  final String name;

  /// Consists from `<owner>/<repository-name>`
  @JsonKey(name: 'full_name')
  final String fullName;

  final String? description;

  @JsonKey(name: 'owner')
  final ShortOwnerEntity shortOwnerEntity;
  final String? language;

  @JsonKey(name: 'watchers_count')
  final int watchersCount;

  Map<String, dynamic> toJson() => _$ShortRepositoryEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        fullName,
        description,
        shortOwnerEntity,
        language,
        watchersCount,
      ];
}
