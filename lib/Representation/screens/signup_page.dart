import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';
import 'package:sonique/core/services/routes/routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              context.go(Routes.home);
            } else if (state is AuthErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_outlined,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Start building your music library',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                label: 'First name',
                                hintText: 'First name',
                                controller: _firstNameController,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator:
                                    (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'Required'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextFormField(
                                label: 'Last name',
                                hintText: 'Last name',
                                controller: _lastNameController,
                                prefixIcon: const Icon(Icons.badge_outlined),
                                validator:
                                    (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'Required'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          label: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          controller: _emailController,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(email)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          label: 'Username',
                          hintText: 'Enter your username',
                          controller: _usernameController,
                          prefixIcon: const Icon(Icons.alternate_email),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Please enter your username'
                                      : null,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          label: 'Password',
                          hintText: 'Enter your password',
                          controller: _passwordController,
                          obscureText: obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(
                                  () => obscurePassword = !obscurePassword,
                                ),
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          label: 'Confirm password',
                          hintText: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(
                                  () =>
                                      obscureConfirmPassword =
                                          !obscureConfirmPassword,
                                ),
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        CustomElevatedButton(
                          backgroundColor: Colors.green,
                          onPressed: isLoading ? null : _signup,
                          child:
                              isLoading
                                  ? const SpinKitWave(
                                    color: Colors.white,
                                    size: 20,
                                  )
                                  : const Text('Sign Up'),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.go(Routes.login),
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      RegisterEvent(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
