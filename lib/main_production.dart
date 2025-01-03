import 'package:github_repo_finder/app/app.dart';
import 'package:github_repo_finder/bootstrap.dart';
import 'package:github_repo_finder/firebase_options_prod.dart';

void main() {
  bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
