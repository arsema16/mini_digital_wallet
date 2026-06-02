import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/local/database_factory.dart';
import 'data/datasources/local/local_database.dart';
import 'data/models/transaction_model.dart';
import 'firebase_options.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use the config file instead of hardcoded values
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Digital Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WalletHomePage(),
    );
  }
}

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  User? currentUser;
  List<TransactionModel> transactions = [];
  double totalBalance = 0;
  bool isLoading = true;
  late LocalDatabase localDatabase;
  String databaseType = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('📱 Initializing app...');
    
    try {
      // Initialize database
      localDatabase = DatabaseFactory.create();
      await localDatabase.init();
      setState(() {
        databaseType = localDatabase.databaseType;
      });
      print('✅ Database initialized: $databaseType');
      
      // Listen to auth changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        print('👤 Auth state changed: ${user?.uid ?? "null"}');
        setState(() {
          currentUser = user;
          errorMessage = '';
        });
        
        if (user != null) {
          await _loadTransactions();
        } else {
          setState(() {
            transactions = [];
            totalBalance = 0;
            isLoading = false;
          });
        }
      });
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('❌ Initialization error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    try {
      final loadedTransactions = await localDatabase.getTransactions();
      setState(() {
        transactions = loadedTransactions;
        totalBalance = 0;
        for (var t in transactions) {
          if (t.type == 'income') {
            totalBalance += t.amount;
          } else {
            totalBalance -= t.amount;
          }
        }
      });
      print('📊 Loaded ${transactions.length} transactions');
    } catch (e) {
      print('❌ Error loading transactions: $e');
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _anonymousLogin() async {
    print('🔐 Attempting anonymous login...');
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print('✅ Anonymous login successful: ${userCredential.user?.uid}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in! Using $databaseType')),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      setState(() {
        errorMessage = 'Auth Error: ${e.message}\nPlease enable Anonymous Authentication in Firebase Console.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _addTransaction(String type) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: type == 'income' ? 'Salary' : 'Groceries',
      amount: type == 'income' ? 5000 : 250,
      type: type,
      category: type == 'income' ? 'Salary' : 'Food',
      paymentMethod: 'Telebirr',
      refId: 'REF${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    
    await localDatabase.insertTransaction(transaction);
    await _loadTransactions();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${type == 'income' ? 'Income' : 'Expense'} added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Digital Wallet'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
                        const SizedBox(height: 24),
                        const Text(
                          'Mini Digital Wallet',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kIsWeb ? Colors.orange[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kIsWeb ? Colors.orange : Colors.green,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                kIsWeb ? Icons.web : Icons.storage,
                                size: 40,
                                color: kIsWeb ? Colors.orange : Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Database: $databaseType',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kIsWeb ? Colors.orange : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                kIsWeb 
                                    ? '⚠️ SQLite not supported on web\nUsing SharedPreferences\nRun on Android/Windows for SQLite'
                                    : '✓ SQLite active - meets internship requirement\nOffline-first storage\nSyncs with Firebase',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kIsWeb ? Colors.orange[700] : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _anonymousLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          ),
                          child: const Text('Continue as Guest'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ETB ${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${transactions.length} transactions • $databaseType',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addTransaction('income'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Income'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addTransaction('expense'),
                              icon: const Icon(Icons.remove),
                              label: const Text('Add Expense'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(
                              child: Text('No transactions yet.\nAdd your first transaction!'),
                            )
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final t = transactions[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: t.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      child: Icon(
                                        t.type == 'income'
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(t.title),
                                    subtitle: Text(t.category),
                                    trailing: Text(
                                      '${t.type == 'income' ? '+' : '-'} ETB ${t.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: t.type == 'income'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            kIsWeb ? Icons.web : Icons.storage,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kIsWeb 
                                ? 'Web mode • Using SharedPreferences • SQLite not supported'
                                : 'SQLite database • Offline-first • Syncs with Firebase',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}