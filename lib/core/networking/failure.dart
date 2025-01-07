import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class FailureWithMessage extends Failure {
  const FailureWithMessage(
    this.message, {
    this.stackTrace,
  });

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return '''
    $FailureWithMessage(
      message: $message,
      stackTrace: $stackTrace,
    )
    ''';
  }

  @override
  List<Object?> get props => [
        message,
        stackTrace,
      ];
}

class FailureApiReturnedNull extends Failure {
  const FailureApiReturnedNull();

  @override
  String toString() {
    return '$FailureApiReturnedNull';
  }
}

class Failure403 extends Failure {
  const Failure403();

  @override
  String toString() {
    return '$Failure403';
  }

  @override
  List<Object?> get props => [];
}
