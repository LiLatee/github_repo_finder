import 'package:github_repo_finder/core/dependencies.dart';
import 'package:github_repo_finder/core/services/crashlytics_error_reporter.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openUrl(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    await sl<CrashlyticsErrorReporter>().logException(
      exception: Exception('Cannot launch url: $url'),
      stackTrace: StackTrace.current,
    );
  }
}
