import 'dart:io';

class TestsManager {
  bool duringTestExecution = Platform.environment.containsKey('FLUTTER_TEST');
}
