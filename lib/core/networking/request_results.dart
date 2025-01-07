import 'package:equatable/equatable.dart';
import 'package:github_repo_finder/core/networking/failure.dart';
import 'package:github_repo_finder/core/networking/pagination_links.dart';

class RequestResults<T> extends Equatable {
  RequestResults({
    required this.requestUri,
    required this.items,
    this.failure,
    this.paginationLinks,
  });

  final Uri requestUri;
  final List<T> items;
  final Failure? failure;
  final PaginationLinks? paginationLinks;

  RequestResults<T> copyWith({
    Uri? requestUri,
    Map<String, String>? query,
    List<T>? items,
    Failure? failure,
    PaginationLinks? paginationLinks,
  }) {
    return RequestResults<T>(
      requestUri: requestUri ?? this.requestUri,
      items: items ?? this.items,
      failure: failure ?? this.failure,
      paginationLinks: paginationLinks ?? this.paginationLinks,
    );
  }

  @override
  List<Object?> get props => [
        requestUri,
        items,
        failure,
        paginationLinks,
      ];
}
