import '../../../core/constants/app_colors.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingLogin = true;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();

  bool _loginObscure = true;
  bool _regObscure = true;
  bool _regConfirmObscure = true;

  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showingLogin) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showingLogin = !_showingLogin);
  }

  void _submitLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _loginEmailCtrl.text.trim(),
            password: _loginPasswordCtrl.text,
          ));
    }
  }

  void _submitRegister() {
    if (_registerFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthSignUpRequested(
            name: _regNameCtrl.text.trim(),
            email: _regEmailCtrl.text.trim(),
            password: _regPasswordCtrl.text,
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
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final showFront = angle < pi / 2;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: showFront
                        ? _LoginCard(
                            formKey: _loginFormKey,
                            emailCtrl: _loginEmailCtrl,
                            passwordCtrl: _loginPasswordCtrl,
                            obscure: _loginObscure,
                            onToggleObscure: () =>
                                setState(() => _loginObscure = !_loginObscure),
                            onLogin: _submitLogin,
                            onFlip: _flip,
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _RegisterCard(
                              formKey: _registerFormKey,
                              nameCtrl: _regNameCtrl,
                              emailCtrl: _regEmailCtrl,
                              passwordCtrl: _regPasswordCtrl,
                              confirmCtrl: _regConfirmCtrl,
                              obscure: _regObscure,
                              confirmObscure: _regConfirmObscure,
                              onToggleObscure: () =>
                                  setState(() => _regObscure = !_regObscure),
                              onToggleConfirmObscure: () => setState(
                                  () => _regConfirmObscure = !_regConfirmObscure),
                              onRegister: _submitRegister,
                              onFlip: _flip,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onFlip;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'sign in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 28),
            _WhiteField(
              controller: emailCtrl,
              hint: 'email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(v.trim())) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _WhiteField(
              controller: passwordCtrl,
              hint: 'password',
              obscure: obscure,
              onToggleObscure: onToggleObscure,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password too short';
                return null;
              },
            ),
            const SizedBox(height: 28),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Text('sign in',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(AuthGoogleLoginRequested()),
                    icon: const Icon(Icons.g_mobiledata, size: 22,
                        color: Colors.white),
                    label: const Text('continue with Google',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: onFlip,
                child: const Text(
                  "don't have an account? sign up",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: state is AuthLoading
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(AuthAnonymousLoginRequested()),
                    child: const Text(
                      'continue as guest',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscure;
  final bool confirmObscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleConfirmObscure;
  final VoidCallback onRegister;
  final VoidCallback onFlip;

  const _RegisterCard({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscure,
    required this.confirmObscure,
    required this.onToggleObscure,
    required this.onToggleConfirmObscure,
    required this.onRegister,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'create account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            _WhiteField(
              controller: nameCtrl,
              hint: 'full name',
              capitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _WhiteField(
              controller: emailCtrl,
              hint: 'email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(v.trim())) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _WhiteField(
              controller: passwordCtrl,
              hint: 'password',
              obscure: obscure,
              onToggleObscure: onToggleObscure,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'At least 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add an uppercase letter';
                if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a number';
                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                  return 'Add a special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _WhiteField(
              controller: confirmCtrl,
              hint: 'confirm password',
              obscure: confirmObscure,
              onToggleObscure: onToggleConfirmObscure,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Text('sign up',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(AuthGoogleLoginRequested()),
                    icon: const Icon(Icons.g_mobiledata, size: 22,
                        color: Colors.white),
                    label: const Text('sign up with Google',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: onFlip,
                child: const Text(
                  'already have an account? sign in',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final String? Function(String?)? validator;

  const _WhiteField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.white, fontSize: 11),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
      validator: validator,
    );
  }
}





