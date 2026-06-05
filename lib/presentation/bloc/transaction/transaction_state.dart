part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> filteredTransactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> categorySpending;

  const TransactionLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpending,
  });

  TransactionLoaded copyWith({
    List<TransactionModel>? filteredTransactions,
    Map<String, double>? categorySpending,
  }) {
    return TransactionLoaded(
      allTransactions: allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categorySpending: categorySpending ?? this.categorySpending,
    );
  }

  @override
  List<Object?> get props => [
        allTransactions,
        filteredTransactions,
        totalBalance,
        totalIncome,
        totalExpense,
        categorySpending,
      ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionSyncSuccess extends TransactionState {}
