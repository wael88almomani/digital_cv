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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.sendPasswordReset(_emailController.text.trim());
      setState(() {
        _message = AppLocalizations.of(context).t('resetLinkSent');
      });
    } catch (_) {
      setState(() {
        _message = AppLocalizations.of(context).t('resetFailed');
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
                title: AppLocalizations.of(context).t('resetPasswordTitle'),
                subtitle: AppLocalizations.of(
                  context,
                ).t('resetPasswordSubtitle'),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              if (_message != null) ...[
                Text(_message!, style: Theme.of(context).textTheme.bodySmall),
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
                    PrimaryButton(
                      label: _loading
                          ? AppLocalizations.of(context).t('sending')
                          : AppLocalizations.of(context).t('sendResetLink'),
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
