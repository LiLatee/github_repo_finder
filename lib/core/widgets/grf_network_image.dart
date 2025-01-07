import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/tests_manager.dart';
import 'package:github_repo_finder/core/widgets/grf_progress_indicator.dart';

class GrfNetworkImage extends StatelessWidget {
  const GrfNetworkImage({
    required this.url,
    required this.imageBuilder,
    this.testPlaceholderHeight = 100,
    this.testPlaceholderWidth = 100,
    this.placeholder,
    super.key,
  });

  final String url;
  final Widget Function(BuildContext context, ImageProvider imageProvider) imageBuilder;
  final Widget Function(BuildContext context, String url)? placeholder;
  final double testPlaceholderHeight;
  final double testPlaceholderWidth;

  @override
  Widget build(BuildContext context) {
    if (sl<TestsManager>().duringTestExecution) {
      return Placeholder(
        fallbackHeight: testPlaceholderHeight,
        fallbackWidth: testPlaceholderWidth,
      );
    }

    const Widget errorWidget = Center(child: Icon(Icons.error));

    if (url.isEmpty) {
      return errorWidget;
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: imageBuilder,
      fit: BoxFit.fitHeight,
      placeholder: placeholder ?? (context, url) => const Center(child: GrfProgressIndicator()),
      errorWidget: (context, url, error) => errorWidget,
    );
  }
}
