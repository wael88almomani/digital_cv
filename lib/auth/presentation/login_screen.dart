import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/animated_fade_in.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../data/auth_service.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _rememberMeLoaded = false;
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_rememberMeLoaded) {
      final prefs = context.read<SharedPreferences>();
      _rememberMe = prefs.getBool(AppStrings.rememberMeKey) ?? true;
      _rememberMeLoaded = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _storeRememberMe();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = _mapEmailPasswordError(error);
      });
    } catch (error) {
      setState(() {
        _error = AppLocalizations.of(context).t('loginFailed');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      final result = await auth.signInWithGoogle();
      if (result == null && mounted) {
        setState(() {
          _error = AppLocalizations.of(context).t('googleCanceled');
        });
        return;
      }
      await _storeRememberMe();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = _mapGoogleError(error);
      });
    } catch (_) {
      setState(() {
        _error = AppLocalizations.of(context).t('googleFailed');
      });
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  String _mapGoogleError(FirebaseAuthException error) {
    final l = AppLocalizations.of(context);
    switch (error.code) {
      case 'sign_in_failed':
      case 'invalid-credential':
        return l.t('googleShaHint');
      case 'network-request-failed':
        return l.t('networkError');
      default:
        return l.t('googleFailed');
    }
  }

  String _mapEmailPasswordError(FirebaseAuthException error) {
    final l = AppLocalizations.of(context);
    switch (error.code) {
      case 'invalid-email':
        return l.t('invalidEmail');
      case 'user-not-found':
        return l.t('userNotFound');
      case 'wrong-password':
      case 'invalid-credential':
        return l.t('wrongPassword');
      case 'user-disabled':
        return l.t('userDisabled');
      case 'operation-not-allowed':
        return l.t('operationNotAllowed');
      case 'too-many-requests':
        return l.t('tooManyRequests');
      default:
        return l.t('loginFailed');
    }
  }

  Future<void> _storeRememberMe() async {
    final prefs = context.read<SharedPreferences>();
    await prefs.setBool(AppStrings.rememberMeKey, _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AnimatedFadeIn(
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: AppLocalizations.of(context).t('welcomeBack'),
                subtitle: AppLocalizations.of(context).t('signInSubtitle'),
                showLogo: true,
              ),
              const SizedBox(height: AppSizes.spacingLg),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: AppLocalizations.of(context).t('email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          ).t('emailRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: AppLocalizations.of(context).t('password'),
                      controller: _passwordController,
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          ).t('passwordRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? true);
                              },
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).t('rememberMe'),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Text(
                            AppLocalizations.of(context).t('rememberMeHint'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).t('forgotPassword'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    PrimaryButton(
                      label: _loading
                          ? AppLocalizations.of(context).t('signingIn')
                          : AppLocalizations.of(context).t('signIn'),
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _googleLoading ? null : _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata_outlined, size: 20),
                        label: Text(
                          _googleLoading
                              ? AppLocalizations.of(
                                  context,
                                ).t('googleConnecting')
                              : AppLocalizations.of(
                                  context,
                                ).t('continueWithGoogle'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).t('newToDigitalCv')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).t('createAccount'),
                    ),
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
