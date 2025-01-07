# GitHub Repo Finder
Project based on [starting_flutter_project](https://github.com/LiLatee/starting_flutter_project#secrets). In case of any questions on how the project is built try to find the answer there.

API based on: https://docs.github.com/en/rest/quickstart?apiVersion=2022-11-28

Tools used by that project are defined in `.tools-version` file.

APK to download the app:

Project uses:
- Firebase for ErrorReporting,
- unit tests with [mocktail](https://pub.dev/packages/mocktail),
- golden tests with [golden_test](https://pub.dev/packages/golden_test) package. Goldens can be found here:
- routing handled by [go_router](https://pub.dev/packages/go_router),
- Polish and English languages,
- dark and light mode,
- [flutter_bloc](pub.dev/packages/flutter_bloc) for state management,
- [get_it](pub.dev/packages/get_it) for dependency injection,
- [chopper](pub.dev/packages/chopper) for handling REST endpoints,
- [url_launcher](pub.dev/packages/url_launcher) for opening links,
- and more...

