import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/animated_fade_in.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../data/auth_service.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
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
      await auth.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = AppLocalizations.of(context).t('registrationFailed');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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
                title: AppLocalizations.of(context).t('createAccountTitle'),
                subtitle: AppLocalizations.of(
                  context,
                ).t('createAccountSubtitle'),
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
                      label: AppLocalizations.of(context).t('fullName'),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).t('nameRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
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
                        if (value == null || value.length < 6) {
                          return AppLocalizations.of(context).t('useAtLeast6');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    PrimaryButton(
                      label: _loading
                          ? AppLocalizations.of(context).t('creatingAccount')
                          : AppLocalizations.of(context).t('createAccount'),
                      onPressed: _loading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
