import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> syncWithRemote();
  Future<Either<Failure, double>> getTotalBalance();
  Future<Either<Failure, Map<String, double>>> getSpendingByCategory();
}
