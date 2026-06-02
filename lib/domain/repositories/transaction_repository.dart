import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction);
  
  Future<Either<Failure, void>> deleteTransaction(String id);
  
  Future<Either<Failure, void>> syncWithRemote();
  
  Stream<List<TransactionEntity>> watchTransactions();
  
  Future<Either<Failure, double>> getTotalBalance();
  
  Future<Either<Failure, Map<String, double>>> getSpendingByCategory();
}

class Failure {
  final String message;
  Failure(this.message);
}