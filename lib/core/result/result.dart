import 'package:dartz/dartz.dart';
import 'package:ehealth/core/error/failures.dart';

/// Standard return type for every domain use case: either a [Failure] or
/// a successful value of type [T].
typedef Result<T> = Either<Failure, T>;
