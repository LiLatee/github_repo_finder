import 'package:flutter/material.dart';

bool onScrollNotification({
  required ScrollNotification scrollInfo,
  required BuildContext context,
  required bool loadingMore,
  required bool hasMoreToLoad,
  required VoidCallback? loadMore,
}) {
  final double pixelsFromBottomToStartLoadMore = MediaQuery.of(context).size.height;

  final bool shouldLoadMore =
      scrollInfo.metrics.pixels > scrollInfo.metrics.maxScrollExtent - pixelsFromBottomToStartLoadMore;
  final bool isDepthZero = scrollInfo.depth == 0;

  if (isDepthZero && shouldLoadMore) {
    if (!loadingMore && hasMoreToLoad) {
      loadMore?.call();
    }
  }
  return false;
}
