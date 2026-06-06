import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../widgets/profile/info_card.dart';
import '../../widgets/profile/info_row.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _confirmLogout(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : isAnonymous
            ? 'Guest User'
            : user?.email?.split('@').first ?? 'User';

    final email = isAnonymous ? 'Anonymous session' : (user?.email ?? '—');

    final initials = () {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    }();

    final createdAt = user?.metadata.creationTime;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Profile',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.balanceGradientStart,
                    AppColors.balanceGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAnonymous ? 'Guest' : 'Registered User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InfoCard(
              title: 'Account Information',
              rows: [
                InfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: displayName,
                ),
                InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
                InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Account Type',
                  value: isAnonymous ? 'Guest (Anonymous)' : 'Email Account',
                ),
                if (createdAt != null)
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member Since',
                    value: FormatUtils.formatDate(createdAt),
                    isLast: true,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is! TransactionLoaded) return const SizedBox();
                return InfoCard(
                  title: 'Wallet Summary',
                  rows: [
                    InfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Total Transactions',
                      value: '${state.allTransactions.length}',
                    ),
                    InfoRow(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Total Income',
                      value: '${FormatUtils.formatAmount(state.totalIncome)} ETB',
                      valueColor: AppColors.income,
                    ),
                    InfoRow(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Total Expense',
                      value: '${FormatUtils.formatAmount(state.totalExpense)} ETB',
                      valueColor: AppColors.expense,
                    ),
                    InfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Net Balance',
                      value: '${FormatUtils.formatAmount(state.totalBalance)} ETB',
                      valueColor: state.totalBalance >= 0 ? AppColors.income : AppColors.expense,
                      isLast: true,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, color: AppColors.expense),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppColors.expense)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.expense),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (isAnonymous) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/'),
                  icon: const Icon(Icons.person_add_outlined, color: Colors.white),
                  label: const Text('Create an Account',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
