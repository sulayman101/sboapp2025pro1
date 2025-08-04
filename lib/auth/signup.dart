import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/text_field_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/check_box_widget.dart';
import 'package:sboapp/constants/custom_phone/custom_phone.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_check.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onSignIn;

  const SignUp({super.key, required this.onSignIn});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _txtFullName = TextEditingController();
  final _txtEmail = TextEditingController();
  final _txtPhone = TextEditingController();
  final _txtPass = TextEditingController();
  final _txtConPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isChecked = true;
  bool? loading;
  String? colorStatus;

  @override
  Widget build(BuildContext context) {
    final providerLocal =
        Provider.of<AppLocalizationsNotifier>(context).localizations;

    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/regGif.gif"),
              _buildTitle(providerLocal),
              _buildTextFields(providerLocal),
              passCheckColor(),
              _buildAgreementCheckbox(providerLocal),
              _buildSignUpButton(providerLocal),
              _buildSignInButton(providerLocal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(providerLocal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: decTitleText(
        text: providerLocal.bodySignUpNow,
        fontSize: MediaQuery.of(context).textScaler.scale(28),
      ),
    );
  }

  Widget _buildTextFields(providerLocal) {
    return Column(
      children: [
        TextFieldWidget(
          preIcon: const Icon(CupertinoIcons.person),
          label: providerLocal.bodyLblName,
          hint: providerLocal.bodyHintName,
          controller: _txtFullName,
          validation: (value) =>
              value!.isEmpty ? providerLocal.bodyEmptyValid("Name") : null,
          isEnabled: loading,
        ),
        _phoneWidget(loading),
        TextFieldWidget(
          preIcon: const Icon(CupertinoIcons.mail),
          label: providerLocal.bodyLblEmail,
          hint: providerLocal.bodyHintEmail,
          controller: _txtEmail,
          validation: (value) {
            if (value!.isEmpty) return providerLocal.bodyEmptyValid("Email");
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return providerLocal.bodyEnterValid;
            }
            return null;
          },
          isEnabled: loading,
        ),
        TextFieldWidget(
          preIcon: const Icon(CupertinoIcons.lock),
          label: providerLocal.bodyLblPsd,
          hint: providerLocal.bodyHintPsd,
          controller: _txtPass,
          isPass: true,
          validation: (value) => _validatePassword(value!, providerLocal),
          onChange: (value) => _updatePasswordStrength(),
          isEnabled: loading,
        ),
        TextFieldWidget(
          preIcon: const Icon(CupertinoIcons.lock),
          label: providerLocal.bodyLblConfirmPsd,
          hint: providerLocal.bodyHintConfirmPsd,
          controller: _txtConPass,
          isPass: true,
          validation: (value) =>
              _validateConfirmPassword(value!, providerLocal),
          isEnabled: loading,
        ),
      ],
    );
  }

  Widget _phoneWidget(isEnabled) {
    final providerLocal =
        Provider.of<AppLocalizationsNotifier>(context).localizations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CustomPhoneField(
        languageCode: Provider.of<AppLocalizationsNotifier>(context)
            .selectedLocale
            .languageCode,
        enabled: isEnabled ?? true,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: providerLocal.bodyLblPhone,
          hintText: providerLocal.bodyHintPhone,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        onChanged: (phone) => _txtPhone.text = phone.completeNumber,
        validator: (value) => providerLocal.bodyCheckPhone,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget passCheckColor() {
    return Row(
      children: [
        _buildStrengthIndicator(
            colorStatus == "weak" ||
                colorStatus == "normal" ||
                colorStatus == "strong",
            Colors.red),
        _buildStrengthIndicator(
            colorStatus == "normal" || colorStatus == "strong", Colors.yellow),
        _buildStrengthIndicator(colorStatus == "strong", Colors.green),
      ],
    );
  }

  Widget _buildStrengthIndicator(bool isActive, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCheckbox(providerLocal) {
    return CheckBoxWidget(
      label: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse(
              "https://sboapp1.github.io/sboapp.github.io/PrivacyPolicy.html");
          if (!await launchUrl(url)) throw Exception('Could not launch $url');
        },
        child: Text(
          providerLocal.bodyAgreeOur,
          style: const TextStyle(
              decoration: TextDecoration.underline, color: Colors.blue),
        ),
      ),
      isChecked: isChecked,
      onChange: (value) {
        if (loading != true) {
          setState(() => isChecked = value ?? false);
        }
      },
    );
  }

  Widget _buildSignUpButton(providerLocal) {
    return Row(
      children: [
        Expanded(
          child: materialButton(
            loading: loading,
            color: Theme.of(context).colorScheme.primary,
            onPressed: loading == true ? null : _performSignup,
            text: providerLocal.bodySingUp,
            height: MediaQuery.of(context).size.height * 0.05,
            txtColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(providerLocal) {
    return outLineButton(
      onPressed: widget.onSignIn,
      child: buttonText(text: providerLocal.bodySingIn),
    );
  }

  String? _validatePassword(String value, providerLocal) {
    if (value.isEmpty) return providerLocal.bodyEmptyValid("Password");
    if (value.length < 6) return providerLocal.bodyMinPsdError;
    return null;
  }

  String? _validateConfirmPassword(String value, providerLocal) {
    if (value.isEmpty) return providerLocal.bodyCheckPsd;
    if (value != _txtPass.text) return providerLocal.bodyYourPsdIsNotMatch;
    return null;
  }

  void _updatePasswordStrength() {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(_txtPass.text);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(_txtPass.text);
    final hasNumber = RegExp(r'[0-9]').hasMatch(_txtPass.text);

    setState(() {
      if (_txtPass.text.isEmpty || _txtPass.text.length < 6) {
        colorStatus = null;
      } else if ((hasUppercase && !hasLowercase && !hasNumber) ||
          (hasLowercase && !hasUppercase && !hasNumber) ||
          (hasNumber && !hasUppercase && !hasLowercase)) {
        colorStatus = "weak";
      } else if ((hasUppercase && hasLowercase && !hasNumber) ||
          (hasUppercase && hasNumber && !hasLowercase) ||
          (hasLowercase && hasNumber && !hasUppercase)) {
        colorStatus = "normal";
      } else {
        colorStatus = "strong";
      }
    });
  }

  Future<void> _performSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      final authServices = Provider.of<AuthServices>(context, listen: false);
      final userModel = UserModel(
        name: _txtFullName.text,
        email: _txtEmail.text.trim(),
        role: "User",
        phone: _txtPhone.text.isEmpty ? null : int.parse(_txtPhone.text),
        uploader: false,
        author: false,
        isVerify: false,
      );
      await authServices.signUp(userModel, _txtPass.text).whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()),
              (Route<dynamic> route) => false, // remove all routes
        );
        if (authServices.errorMsg != null) {
          _showErrorDialog(authServices.errorMsg!);
        }
        setState(() => loading = null);
      });
    }
  }

  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: "Error"),
        content: Text(errorMsg),
      ),
    );
  }
}
