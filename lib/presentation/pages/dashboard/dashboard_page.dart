import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';

import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/balance_header.dart';
import '../../widgets/category_spending_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/transaction_tile.dart';
import '../details/transaction_detail_screen.dart';
import '../profile/profile_page.dart';
import '../transactions/transactions_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  void _showAdd({String type = 'expense'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: AddTransactionSheet(initialType: type),
      ),
    );
  }

  Future<void> _startTopUp() async {
    // Show a dialog to enter top-up amount
    final amountController = TextEditingController();

    final confirmed = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Top Up Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount to top up (ETB):'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: 'ETB ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(ctx, amount);
              }
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (confirmed == null) return;

    // Start Chapa payment
    try {
      final txRef = TxRefRandomGenerator.generate(prefix: 'wallet-topup');
      
      String? paymentUrl = await Chapa.getInstance.startPayment(
        context: context,
        amount: confirmed.toString(),
        currency: 'ETB',
        txRef: txRef,
        firstName: _user?.displayName?.split(' ').firstOrNull,
        lastName: _user?.displayName?.split(' ').lastOrNull,
        email: _user?.email,
        onInAppPaymentSuccess: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Payment successful!'),
              backgroundColor: AppColors.income,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onInAppPaymentError: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Payment failed: $msg'),
              backgroundColor: AppColors.expense,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  String get _displayName {
    if (_user == null) return 'Guest';
    if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    if (_user!.email != null) return _user!.email!.split('@').first;
    return 'Guest';
  }

  String get _initials {
    final parts = _displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
              ));
            }
            if (state is TransactionSyncSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✓ Synced successfully'),
                backgroundColor: AppColors.income,
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
          builder: (context, state) {
            if (state is TransactionInitial || state is TransactionLoading) {
              return const DashboardShimmer();
            }
            if (state is TransactionLoaded) return _buildBody(state);
            if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 52, color: AppColors.expense),
                    const SizedBox(height: 12),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<TransactionBloc>().add(LoadTransactions()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const DashboardShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildBody(TransactionLoaded state) {
    final recent = state.filteredTransactions.take(5).toList();

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TransactionBloc>().add(LoadTransactions()),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.balanceGradientEnd,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text('Dashboard',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TransactionBloc>(),
                      child: const ProfilePage(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.sync, color: Colors.white),
                onPressed: () =>
                    context.read<TransactionBloc>().add(SyncTransactions()),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _confirmLogout,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: BalanceHeader(
                initials: _initials,
                displayName: _displayName,
                totalBalance: state.totalBalance,
                totalIncome: state.totalIncome,
                totalExpense: state.totalExpense,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Income',
                          iconColor: AppColors.income,
                          bgColor: AppColors.incomeBg,
                          onTap: () => _showAdd(type: 'income'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.remove_circle_outline_rounded,
                          label: 'Expense',
                          iconColor: AppColors.expense,
                          bgColor: AppColors.expenseBg,
                          onTap: () => _showAdd(type: 'expense'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.sync_rounded,
                          label: 'Sync',
                          iconColor: AppColors.primary,
                          bgColor: AppColors.primaryLight,
                          onTap: () =>
                              context.read<TransactionBloc>().add(SyncTransactions()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.credit_card_outlined,
                          label: 'Top Up',
                          iconColor: AppColors.primary,
                          bgColor: AppColors.primaryLight,
                          onTap: _startTopUp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.categorySpending.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategorySpendingCard(
                      spending: state.categorySpending,
                      totalExpense: state.totalExpense,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Transactions',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TransactionBloc>(),
                              child: const TransactionsScreen(),
                            ),
                          ),
                        ),
                        child: const Text('See all',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('No transactions yet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('Tap + to add your first one',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      children: recent
                          .map((tx) => TransactionTile(
                                transaction: tx,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TransactionDetailScreen(transaction: tx),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
