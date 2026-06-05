import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;
  AddTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(TransactionEntity transaction) =>
      repository.addTransaction(transaction);
}
