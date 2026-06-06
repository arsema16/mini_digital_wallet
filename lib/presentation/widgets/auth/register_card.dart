import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'auth_field.dart';
import 'auth_divider.dart';

class RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscure;
  final bool confirmObscure;
  final VoidCallback onToggle;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;
  final VoidCallback onFlip;

  const RegisterCard({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscure,
    required this.confirmObscure,
    required this.onToggle,
    required this.onToggleConfirm,
    required this.onSubmit,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Fill in your details to get started',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              AuthField(
                ctrl: nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                capitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AuthField(
                ctrl: emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v.trim())) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AuthField(
                ctrl: passCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: obscure,
                onToggle: onToggle,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'At least 8 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(v)) {
                    return 'Add an uppercase letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a number';
                  if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                    return 'Add a special character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AuthField(
                ctrl: confirmCtrl,
                label: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                obscure: confirmObscure,
                onToggle: onToggleConfirm,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != passCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white))
                              : const Text('Create Account',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AuthDivider(),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: loading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(AuthGoogleLoginRequested()),
                          icon: const Icon(Icons.g_mobiledata,
                              size: 24, color: AppColors.primary),
                          label: const Text('Sign up with Google',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?  ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: onFlip,
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
