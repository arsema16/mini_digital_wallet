import 'package:flutter/material.dart';
import '../../../data/datasources/local/database_factory.dart';
import '../../../data/datasources/local/local_database.dart';
import '../../../data/models/transaction_model.dart';
import '../details/transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late LocalDatabase localDatabase;
  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  bool isLoading = true;

  // Filter state
  String? selectedType;
  String? selectedCategory;
  DateTimeRange? selectedDateRange;
  String searchQuery = '';

  final List<String> categories = [
    'All', 'Salary', 'Food', 'Shopping', 'Transport', 'Entertainment', 'Bills', 'Health', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    localDatabase = DatabaseFactory.create();
    await localDatabase.init();
    await _loadTransactions();
    setState(() => isLoading = false);
  }

  Future<void> _loadTransactions() async {
    final all = await localDatabase.getTransactions();
    setState(() {
      allTransactions = all;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List<TransactionModel>.from(allTransactions);

    if (selectedType != null && selectedType != 'All') {
      filtered = filtered.where((t) => t.type == selectedType).toList();
    }
    if (selectedCategory != null && selectedCategory != 'All') {
      filtered = filtered.where((t) => t.category == selectedCategory).toList();
    }
    if (selectedDateRange != null) {
      filtered = filtered.where((t) {
        final date = t.createdAt;
        return date.isAfter(selectedDateRange!.start) &&
            date.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
          t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    setState(() => filteredTransactions = filtered);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setStateBottom) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'income', label: Text('Income')),
                      ButtonSegment(value: 'expense', label: Text('Expense')),
                    ],
                    selected: {selectedType ?? 'All'},
                    onSelectionChanged: (set) {
                      setStateBottom(() {
                        selectedType = set.first == 'All' ? null : set.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory ?? 'All',
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) {
                      setStateBottom(() {
                        selectedCategory = val == 'All' ? null : val;
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final range = await showDateRangePicker(
                              context: ctx, // ✅ Use ctx from bottom sheet
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (range != null) {
                              setStateBottom(() {
                                selectedDateRange = range;
                              });
                            }
                          },
                          child: Text(selectedDateRange == null
                              ? 'Select range'
                              : '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'),
                        ),
                      ),
                      if (selectedDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setStateBottom(() {
                              selectedDateRange = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStateBottom(() {
                            selectedType = null;
                            selectedCategory = null;
                            selectedDateRange = null;
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color.fromARGB(255, 230, 229, 228),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TransactionSearchDelegate(allTransactions, (query) {
                  setState(() {
                    searchQuery = query;
                    _applyFilters();
                  });
                }),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('No transactions match your filters.'))
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (ctx, idx) {
                        final tx = filteredTransactions[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                tx.type == 'income' ? Icons.trending_up : Icons.trending_down,
                                color: tx.type == 'income' ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(tx.title),
                            subtitle: Text('${tx.category} • ${_formatDate(tx.createdAt)}'),
                            trailing: Text(
                              '${tx.type == 'income' ? '+' : '-'}${tx.amount.toStringAsFixed(2)} birr',
                              style: TextStyle(
                                color: tx.type == 'income' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailScreen(transaction: tx),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

// Search delegate
class TransactionSearchDelegate extends SearchDelegate {
  final List<TransactionModel> transactions;
  final Function(String) onSearch;

  TransactionSearchDelegate(this.transactions, this.onSearch);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onSearch('');
          },
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return _buildResultsList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearch(query);
    return _buildResultsList();
  }

  Widget _buildResultsList() {
    final filtered = transactions.where((t) =>
        t.title.toLowerCase().contains(query.toLowerCase()) ||
        t.category.toLowerCase().contains(query.toLowerCase())).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(filtered[i].title),
        subtitle: Text(filtered[i].category),
        trailing: Text('${filtered[i].amount} birr'),
        onTap: () {
          close(ctx, null);
        },
      ),
    );
  }
}