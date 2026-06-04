import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_digital_wallet/presentation/pages/transactions/transactions_screen.dart';
import '../../../data/datasources/local/database_factory.dart';
import '../../../data/datasources/local/local_database.dart';
import '../../../data/models/transaction_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late LocalDatabase localDatabase;
  List<TransactionModel> transactions = [];
  double totalBalance = 0.0;
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _initialize();
    _listenToAuthChanges();
  }

  Future<void> _initialize() async {
    localDatabase = DatabaseFactory.create();
    await localDatabase.init();
    await _loadTransactions();
    setState(() => isLoading = false);
  }

  void _listenToAuthChanges() {
    currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() => currentUser = user);
      if (user != null) _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    final all = await localDatabase.getTransactions();
    setState(() {
      transactions = all;
      totalBalance = 0;
      for (var t in transactions) {
        totalBalance += t.type == 'income' ? t.amount : -t.amount;
      }
    });
  }

  Future<void> _addTransaction(String type) async {
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: type == 'income' ? 'Salary' : 'Shopping',
      amount: type == 'income' ? 1500 : 350,
      type: type,
      category: type == 'income' ? 'Salary' : 'Food',
      paymentMethod: 'Telebirr',
      refId: 'REF${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await localDatabase.insertTransaction(newTx);
    await _loadTransactions();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${type == 'income' ? 'Income' : 'Expense'} added')),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  List<TransactionModel> get recentTransactions =>
      transactions.take(5).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 158, 133, 86),
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 230, 229, 228),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Color(0xFF1E2A3E), fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1E2A3E)),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

// Profile info row
Container(
  margin: const EdgeInsets.only(bottom: 20),
  child: Row(
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF54B998),
        child: const Icon(Icons.person, color: Colors.white, size: 28),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              currentUser?.displayName ?? 'Guest User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3E),
              ),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E2A3E)),
        onPressed: () {
          // Future: profile settings
        },
      ),
    ],
  ),
),
                    // ========== BALANCE CARD (Modern FinTech Style) ==========
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(60),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color.fromARGB(255, 84, 185, 152), Color.fromARGB(255, 84, 185, 152)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 84, 185, 152).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(10, 30),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalBalance.toStringAsFixed(2)} birr',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildBalanceInfo(Icons.arrow_upward, 'Income',
                                  _totalIncome().toStringAsFixed(2), Colors.greenAccent),
                              const SizedBox(width: 24),
                              _buildBalanceInfo(Icons.arrow_downward, 'Expense',
                                  _totalExpense().toStringAsFixed(2), Colors.orangeAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ========== ACTION BUTTONS ==========
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Income',
                            color: Colors.green,
                            onTap: () => _addTransaction('income'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.remove_circle_outline,
                            label: 'Expense',
                            color: Colors.red,
                            onTap: () => _addTransaction('expense'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ========== RECENT TRANSACTIONS SECTION ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2A3E),
                          ),
                        ),
                        TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionsScreen()),
    );
  },
  child: const Text(
    'See all',
    style: TextStyle(color: Color(0xFF4A90E2)),
  ),
),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (recentTransactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No transactions yet.\nTap + to add.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = recentTransactions[index];
                          return _buildTransactionTile(tx);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceInfo(IconData icon, String label, String amount, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('$amount birr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final isIncome = tx.type == 'income';
    final amountStr = '${isIncome ? '+' : '-'} ${tx.amount.toStringAsFixed(2)} birr';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.category,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(tx.createdAt),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _totalIncome() =>
      transactions.where((t) => t.type == 'income').fold(0, (s, t) => s + t.amount);
  double _totalExpense() =>
      transactions.where((t) => t.type == 'expense').fold(0, (s, t) => s + t.amount);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}