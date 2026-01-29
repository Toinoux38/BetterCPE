/// Result wrapper for handling success and error states
sealed class Result<T> {
  const Result();
  
  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message, {int? statusCode}) = Failure<T>;
  
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  });
}

final class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    return success(data);
  }
}

final class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  
  const Failure(this.message, {this.statusCode});
  
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    return failure(message, statusCode);
  }
}
