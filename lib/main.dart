import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'firebase_options.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/pages/auth/auth_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configure Chapa SDK
  // Replace with your own Chapa private key from https://dashboard.chapa.co/
  Chapa.configure(privateKey: 'YOUR_CHAPA_PRIVATE_KEY_HERE');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckStatus())),
        BlocProvider(create: (_) => TransactionBloc()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        initialRoute: AppRoutes.root,
        routes: {
          AppRoutes.root: (_) => const _AuthWrapper(),
        },
      ),
    );
  }
}

// ── Central navigation controller ───────────────────────────────────────────
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final done = await hasSeenOnboarding();
    if (mounted) setState(() => _onboardingDone = done);
  }

  @override
  Widget build(BuildContext context) {
    // Phase 0: reading SharedPreferences
    if (_onboardingDone == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    // Phase 1: first launch → onboarding
    if (!_onboardingDone!) {
      return OnboardingPage(
        onDone: () => setState(() => _onboardingDone = true),
      );
    }

    // Phase 2: onboarding done → auth decides
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return const DashboardPage();
        if (state is Unauthenticated) return const AuthPage();
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.expense),
                    const SizedBox(height: 12),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(AuthCheckStatus()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
