import 'package:equatable/equatable.dart';

class PaginationLinks extends Equatable {
  PaginationLinks({
    this.firstLink,
    this.lastLink,
    this.prevLink,
    this.nextLink,
  });

  factory PaginationLinks.fromLinkHeader(String linkHeader) {
    final RegExp linkRegExp = RegExp(r'<([^>]+)>;\s*rel="([^"]+)"');
    Uri? firstLink, lastLink, prevLink, nextLink;

    for (final match in linkRegExp.allMatches(linkHeader)) {
      if (match.groupCount == 2) {
        final url = Uri.parse(match.group(1)!);
        final rel = match.group(2);

        switch (rel) {
          case 'first':
            firstLink = url;
            break;
          case 'last':
            lastLink = url;
            break;
          case 'prev':
            prevLink = url;
            break;
          case 'next':
            nextLink = url;
            break;
        }
      }
    }

    return PaginationLinks(
      firstLink: firstLink,
      lastLink: lastLink,
      prevLink: prevLink,
      nextLink: nextLink,
    );
  }

  final Uri? firstLink;
  final Uri? lastLink;
  final Uri? prevLink;
  final Uri? nextLink;

  @override
  List<Object?> get props => [
        firstLink,
        lastLink,
        prevLink,
        nextLink,
      ];
}
