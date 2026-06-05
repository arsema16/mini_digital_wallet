part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const AddTransaction(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const UpdateTransaction(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;
  const DeleteTransaction(this.id);
  @override
  List<Object?> get props => [id];
}

class SyncTransactions extends TransactionEvent {}

class FilterTransactions extends TransactionEvent {
  final String? type;
  final String? category;
  final DateTimeRange? dateRange;
  final String? searchQuery;
  const FilterTransactions({this.type, this.category, this.dateRange, this.searchQuery});
  @override
  List<Object?> get props => [type, category, dateRange, searchQuery];
}