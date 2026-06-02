import 'package:dartz/dartz.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../datasources/local/transaction_local_ds.dart';
import '../datasources/remote/transaction_remote_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<Either<String, List<TransactionEntity>>> getTransactions() async {
    try {
      final localTransactions = await localDataSource.getTransactions();
      
      if (await networkInfo.isConnected) {
        try {
          final remoteTransactions = await remoteDataSource.getTransactions();
          await localDataSource.insertTransactions(remoteTransactions);
          return Right(remoteTransactions.map((t) => t.toEntity()).toList());
        } catch (e) {
          // If remote fails, still return local
          return Right(localTransactions.map((t) => t.toEntity()).toList());
        }
      }
      
      return Right(localTransactions.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        category: transaction.category,
        paymentMethod: transaction.paymentMethod,
        refId: transaction.refId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.insertTransaction(model);
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.addTransaction(model);
      }
      
      return Right(model.toEntity());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTransaction(id);
      }
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}