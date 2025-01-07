import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/features/repositories/domain/entities/pull_request_state_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'short_pull_request_entity.g.dart';

@JsonSerializable()
class ShortPullRequestEntity extends Equatable {
  ShortPullRequestEntity({
    required this.id,
    required this.url,
    required this.number,
    required this.state,
    required this.title,
    required this.createdAt,
  });

  factory ShortPullRequestEntity.fromJson(Map<String, dynamic> json) => _$ShortPullRequestEntityFromJson(json);

  final int id;
  final String url;
  final int number;

  static PullRequestStateEnum stateFromString(String value) => PullRequestStateEnum.fromString(value);

  static String stateToString(PullRequestStateEnum value) => value.toString();

  @JsonKey(fromJson: stateFromString, toJson: stateToString)
  final PullRequestStateEnum state;

  final String title;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$ShortPullRequestEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        url,
        number,
        state,
        title,
        createdAt,
      ];
}
