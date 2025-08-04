import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/components/text_field_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/check_box_widget.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_check.dart';

class SignIn extends StatefulWidget {
  final VoidCallback onSignUp;
  const SignIn({super.key, required this.onSignUp});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _txtEmail = TextEditingController();
  final _txtPass = TextEditingController();
  final _txtForgetPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isRem = false;
  bool isSend = false;
  bool? loading;
  bool timeLeft = false;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _txtEmail.text = prefs.getString('username') ?? '';
      _txtPass.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveCredentials() async {
    if (isRem) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _txtEmail.text.trim());
      await prefs.setString('password', _txtPass.text.trim());
    }
  }

  String? _validatePassword(String value, providerLocale) {
    if (value.isEmpty) return providerLocale.bodyEmptyValid("Password");
    if (value.length < 6) return providerLocale.bodyMinPsdError;
    return null;
  }

  void _handleSignIn(AuthServices authServices, providerLocale) {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      if (isRem) _saveCredentials();
      authServices.signIn(_txtEmail.text, _txtPass.text).whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()),
              (Route<dynamic> route) => false, // remove all routes
        );
        if (authServices.errorMsg != null) {
          _showSnackBar("Error", authServices.errorMsg!, ContentType.failure);
        }
        setState(() => loading = null);
      });
    }
  }

  void _showSnackBar(String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      customizedSnackBar(title: title, message: message, contentType: type),
    );
  }

  void _handleForgotPassword(providerLocale) {
    if (timeLeft) {
      _showSnackBar("Reset Password", providerLocale.bodyResendPsdWait,
          ContentType.warning);
      return;
    }
    _txtForgetPass.text = _txtEmail.text;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: providerLocale.bodyForgetPsd),
        content: MyTextFromField(
          labelText: providerLocale.bodyLblEmail,
          hintText: providerLocale.bodyHintEmail,
          textEditingController: _txtForgetPass,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: buttonText(text: providerLocale.bodyCancel),
          ),
          TextButton(
            onPressed: () {
              setState(() => timeLeft = true);
              Navigator.pop(context);
              Provider.of<AuthServices>(context, listen: false)
                  .resetPassword(_txtForgetPass.text);
              Future.delayed(const Duration(minutes: 5), () {
                setState(() => timeLeft = false);
              });
            },
            child: buttonText(text: providerLocale.bodySendResetLink),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context).localizations;
    final authServices = Provider.of<AuthServices>(context, listen: false);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(
              "assets/images/loginGift.gif",
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: decTitleText(
                text: providerLocale.bodyWelcomeBack,
                fontSize: MediaQuery.of(context).textScaler.scale(28),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            TextFieldWidget(
              preIcon: const Icon(CupertinoIcons.mail),
              label: providerLocale.bodyLblEmail,
              hint: providerLocale.bodyHintEmail,
              controller: _txtEmail,
              validation: (value) {
                if (value!.isEmpty) return providerLocale.bodyEmptyEmail;
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return providerLocale.bodyEnterValid;
                }
                return null;
              },
              isEnabled: loading,
            ),
            TextFieldWidget(
              preIcon: const Icon(CupertinoIcons.lock),
              label: providerLocale.bodyLblPsd,
              hint: providerLocale.bodyHintPsd,
              controller: _txtPass,
              isPass: true,
              validation: (value) => _validatePassword(value!, providerLocale),
              isEnabled: loading,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CheckBoxWidget(
                  label: buttonText(text: providerLocale.bodyRemember),
                  isChecked: isRem,
                  onChange: (value) {
                    if (loading != true) {
                      setState(() => isRem = value ?? false);
                    }
                  },
                ),
                outLineButton(
                  onPressed: () => _handleForgotPassword(providerLocale),
                  child: buttonText(text: providerLocale.bodyForgetPsd),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: materialButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: loading == true
                        ? null
                        : () => _handleSignIn(authServices, providerLocale),
                    text: providerLocale.bodySingIn,
                    loading: loading,
                    height: MediaQuery.of(context).size.height * 0.05,
                    txtColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            outLineButton(
              onPressed: widget.onSignUp,
              child: buttonText(text: providerLocale.bodyCreate),
            ),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: bodyText(text: providerLocale.bodyOr),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            GestureDetector(
              onTap: loading == true
                  ? null
                  : () {

                      setState(() => loading = true);
                      authServices.signInWithGoogle().whenComplete(() {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthCheck()),
                              (Route<dynamic> route) => false, // remove all routes
                        );
                        if (authServices.errorMsg != null) {
                          _showSnackBar("Error", authServices.errorMsg!,
                              ContentType.failure);
                        }
                        setState(() => loading = null);
                      }).catchError((_) {
                        _showSnackBar("Error", authServices.errorMsg!,
                            ContentType.failure);
                        setState(() => loading = null);
                      });
                    },
              child: _buildGoogleSignInButton(providerLocale),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthServices>(context, listen: false).signInAsGuest();
              },
              child: const Text("Continue as Guest"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(providerLocale) {
    return Container(
      padding: EdgeInsets.only(
        right: providerLocale.language == "العربية" ? 0.0 : 9.0,
        left: providerLocale.language == "العربية" ? 9.0 : 0.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: loading == true
                ? const CircularProgressIndicator()
                : Image.asset("assets/images/g_icon.png"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: buttonText(
              text: providerLocale.bodyContWitG,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
