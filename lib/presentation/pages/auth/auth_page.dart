import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/auth/login_card.dart';
import '../../widgets/auth/register_card.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showLogin = true;

  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();

  bool _loginObscure = true;
  bool _regObscure = true;
  bool _regConfirmObscure = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showLogin) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
    setState(() => _showLogin = !_showLogin);
  }

  void _submitLogin() {
    if (_loginKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _loginEmailCtrl.text.trim(),
            password: _loginPassCtrl.text,
          ));
    }
  }

  void _submitRegister() {
    if (_registerKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthSignUpRequested(
            name: _regNameCtrl.text.trim(),
            email: _regEmailCtrl.text.trim(),
            password: _regPassCtrl.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1A73E8),
                Color(0xFF42A5F5),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mini Digital Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your money, your control',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) {
                      final angle = _anim.value * pi;
                      final isFront = angle < pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? LoginCard(
                                formKey: _loginKey,
                                emailCtrl: _loginEmailCtrl,
                                passCtrl: _loginPassCtrl,
                                obscure: _loginObscure,
                                onToggle: () => setState(
                                    () => _loginObscure = !_loginObscure),
                                onSubmit: _submitLogin,
                                onFlip: _flip,
                              )
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: RegisterCard(
                                  formKey: _registerKey,
                                  nameCtrl: _regNameCtrl,
                                  emailCtrl: _regEmailCtrl,
                                  passCtrl: _regPassCtrl,
                                  confirmCtrl: _regConfirmCtrl,
                                  obscure: _regObscure,
                                  confirmObscure: _regConfirmObscure,
                                  onToggle: () => setState(
                                      () => _regObscure = !_regObscure),
                                  onToggleConfirm: () => setState(() =>
                                      _regConfirmObscure = !_regConfirmObscure),
                                  onSubmit: _submitRegister,
                                  onFlip: _flip,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
