enum PullRequestStateEnum {
  open,
  closed,
  all;

  static PullRequestStateEnum fromString(String string) {
    if (string == 'open') {
      return PullRequestStateEnum.open;
    } else if (string == 'closed') {
      return PullRequestStateEnum.closed;
    } else if (string == 'all') {
      return PullRequestStateEnum.all;
    } else {
      throw Exception('Unexpected pull request state: $string');
    }
  }
}
