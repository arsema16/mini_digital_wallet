import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;
  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.deleteTransaction(id);
}
