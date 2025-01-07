import 'package:flutter/material.dart';
import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/tests_manager.dart';

class GrfProgressIndicator extends StatelessWidget {
  const GrfProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (sl<TestsManager>().duringTestExecution) {
      return Text(
        'test loading',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      );
    } else {
      return RepaintBoundary(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeCap: StrokeCap.round,
        ),
      );
    }
  }
}
