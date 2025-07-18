import 'package:dartz/dartz.dart';
import 'package:billora/src/core/errors/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>; 
