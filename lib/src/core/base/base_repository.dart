import 'package:general/src/core/index.dart';

typedef ResultFuture<T> = Future<Either<NetworkExceptions, T>>;
typedef ResultVoid = Future<Either<NetworkExceptions, void>>;

ResultFuture<T> execute<T>(Future<T> Function() fun) async {

  try {
    final result = await fun();
    return Right(result);
  } catch (error) {
    if (kDebugMode) {
      String message = NetworkExceptions.getErrorMessage(
        NetworkExceptions.getDioException(error),
      );
      Methods.printLog("error in execute ===> $message");
    }
    final left = NetworkExceptions.getDioException(error);
    return Left(left);
  }
}
