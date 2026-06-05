import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../repositories/transaction_repository.dart';

class GetSpendingByCategory {
  final TransactionRepository repository;
  GetSpendingByCategory(this.repository);

  Future<Either<Failure, Map<String, double>>> call() =>
      repository.getSpendingByCategory();
}
