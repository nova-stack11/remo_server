import '../../../infrastructure/controller/rest_controller.dart';

abstract class ResultState<T, E> {}

class DataSuccess<T, E> extends ResultState<T, E> {
  final T data;
  final int code;
  final String message;
  DataSuccess(this.data, {this.code = 200, this.message = 'success'});
}

class DataError<T, E> extends ResultState<T, E> {
  final E? error;
  final String? message;
  DataError(this.error, this.message);
}

class DataLoading<T, E> extends ResultState<T, E> {}