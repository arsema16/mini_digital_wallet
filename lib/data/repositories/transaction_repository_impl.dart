import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/failures/failure.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/local_database.dart';
import '../datasources/remote/transaction_remote_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDatabase localDb;
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final FirebaseAuth auth;

  TransactionRepositoryImpl({
    required this.localDb,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.auth,
  });

  bool get _online => auth.currentUser != null;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final local = await localDb.getTransactions();

      if (await networkInfo.isConnected && _online) {
        try {
          final remote = await remoteDataSource.getTransactions();
          for (final tx in remote) {
            if (!local.any((l) => l.id == tx.id)) {
              await localDb.insertTransaction(tx);
            }
          }
          final merged = await localDb.getTransactions();
          return Right(merged.map((m) => m.toEntity()).toList());
        } catch (_) {
          // fall through to local
        }
      }

      return Right(local.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(
      TransactionEntity transaction) async {
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
        isSynced: false,
      );

      await localDb.insertTransaction(model);

      if (await networkInfo.isConnected && _online) {
        try {
          await remoteDataSource.addTransaction(model);
          await localDb.markAsSynced(model.id);
        } catch (_) {}
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
      TransactionEntity transaction) async {
    try {
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        category: transaction.category,
        paymentMethod: transaction.paymentMethod,
        refId: transaction.refId,
        createdAt: transaction.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await localDb.updateTransaction(model);

      if (await networkInfo.isConnected && _online) {
        try {
          await remoteDataSource.addTransaction(model);
          await localDb.markAsSynced(model.id);
        } catch (_) {}
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDb.deleteTransaction(id);
      if (await networkInfo.isConnected && _online) {
        try {
          await remoteDataSource.deleteTransaction(id);
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithRemote() async {
    if (!_online) return const Left(AuthFailure('Not authenticated'));

    try {
      final unsynced = await localDb.getUnsyncedTransactions();
      for (final tx in unsynced) {
        await remoteDataSource.addTransaction(tx);
        await localDb.markAsSynced(tx.id);
      }

      final remote = await remoteDataSource.getTransactions();
      final localIds = (await localDb.getTransactions()).map((t) => t.id).toSet();
      for (final tx in remote) {
        if (!localIds.contains(tx.id)) {
          await localDb.insertTransaction(tx);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalBalance() async {
    try {
      return Right(await localDb.getTotalBalance());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getSpendingByCategory() async {
    try {
      final txns = await localDb.getTransactions();
      final Map<String, double> result = {};
      for (final tx in txns.where((t) => t.type == 'expense')) {
        result[tx.category] = (result[tx.category] ?? 0) + tx.amount;
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
