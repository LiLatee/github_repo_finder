import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/tests_manager.dart';

final Duration grfDebounceDuration =
    sl<TestsManager>().duringTestExecution ? Duration.zero : const Duration(milliseconds: 500);
