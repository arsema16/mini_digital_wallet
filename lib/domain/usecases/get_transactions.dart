import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() =>
      repository.getTransactions();
}
