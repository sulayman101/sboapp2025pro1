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
  String dialCode = '252';

  bool? loading;

  String? colorStatus;

  void checkPassStatus() {
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(_txtPass.text);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(_txtPass.text);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(_txtPass.text);
    if (_txtPass.text.isNotEmpty && _txtPass.text.length >= 6) {
      //start
      if (hasUppercase && !hasNumber && !hasLowercase) {
        setState(() {});
        colorStatus = "weak";
      } else if (hasLowercase && !hasNumber && !hasUppercase) {
        setState(() {});
        colorStatus = "weak";
      } else if (hasNumber && !hasUppercase && !hasLowercase) {
        setState(() {});
        colorStatus = "weak";
      } else {
        if (hasUppercase && hasLowercase && !hasNumber) {
          setState(() {});
          colorStatus = "normal";
        } else if (hasUppercase && hasNumber && !hasLowercase) {
          setState(() {});
          colorStatus = "normal";
        } else if (hasLowercase && hasNumber && !hasUppercase) {
          setState(() {});
          colorStatus = "normal";
        } else {
          setState(() {});
          colorStatus = "strong";
        }
      }
    } else {
      setState(() {});
      colorStatus = null;
    }
  }

  String? checkPass(value, providerLocal) {
    if (value.isEmpty) {
      return providerLocal.bodyEmptyValid("Password");
    } else {
      if (value.length < 6) {
        return providerLocal.bodyMinPsdError;
      } else {
        return null;
      }
    }
  }

  // ignore: unused_field
  String _clientState = "NOT INITIALIZED";
  // ignore: prefer_final_fields, unused_field
  String _token = "NO TOKEN";

  void initClient() async {
    // ignore: unused_local_variable
    String siteKey = "6LegPykqAAAAAKj5PkgAbQv6_u7VJePSZD1dL9iV";

    var result = false;
    var errorMessage = "failure";

    try {
      //result = await RecaptchaEnterprise.initClient(siteKey, timeout: 10000);
    } on PlatformException catch (err) {
      debugPrint('Caught platform exception on init: $err');
      errorMessage = 'Code: ${err.code} Message ${err.message}';
    } catch (err) {
      debugPrint('Caught exception on init: $err');
      errorMessage = err.toString();
    }

    setState(() {
      // ignore: dead_code
      _clientState = result ? "ok" : errorMessage;
    });
  }

  /*void executeRecaptcha() async {
    String result;

    try {
      result = await RecaptchaEnterprise.execute(RecaptchaAction.SIGNUP());
    } on PlatformException catch (err) {
      debugPrint('Caught platform exception on execute: $err');
      result = 'Code: ${err.code} Message ${err.message}';
    } catch (err) {
      debugPrint('Caught exception on execute: $err');
      result = err.toString();
    }

    setState(() {
      _token = result;
    });

    if (_token != "NO TOKEN") {
      await performSignup();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('reCAPTCHA verification failed')),
      );
    }
  }*/

  performSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = false;
      });
      final singUpPro = Provider.of<AuthServices>(context, listen: false);
      final userModel = UserModel(
        name: _txtFullName.text,
        email: _txtEmail.text.trim(),
        role: "User",
        phone: _txtPhone.text.isEmpty ? null : int.parse(_txtPhone.text),
        uploader: false,
        author: false,
        isVerify: false,
      );
      await singUpPro.signUp(userModel, _txtPass.text).whenComplete(() {
        if (singUpPro.errorMsg != null) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: titleText(text: "Error"),
                    content: Text(singUpPro.errorMsg!),
                  ));
          setState(() {
            loading = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLocal =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/regGif.gif"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: decTitleText(
                    text: providerLocal.bodySignUpNow,
                    fontSize: MediaQuery.of(context).textScaler.scale(28)),
              ),
              TextFieldWidget(
                preIcon: const Icon(CupertinoIcons.person),
                label: providerLocal.bodyLblName,
                hint: providerLocal.bodyHintName,
                controller: _txtFullName,
                validation: (value) {
                  if (value.isEmpty) {
                    return providerLocal.bodyEmptyValid("Name");
                  } else {
                    return null;
                  }
                },
                isEnabled: loading,
              ),
              _phoneWidget(loading),
              TextFieldWidget(
                preIcon: const Icon(CupertinoIcons.mail),
                label: providerLocal.bodyLblEmail,
                hint: providerLocal.bodyHintEmail,
                controller: _txtEmail,
                validation: (value) {
                  if (value.isEmpty) {
                    return providerLocal.bodyEmptyValid("Email");
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return providerLocal.bodyEnterValid;
                  } else {
                    return null;
                  }
                },
                isEnabled: loading,
              ),
              TextFieldWidget(
                preIcon: const Icon(CupertinoIcons.lock),
                label: providerLocal.bodyLblPsd,
                hint: providerLocal.bodyHintPsd,
                controller: _txtPass,
                isPass: true,
                validation: (value) => checkPass(value, providerLocal),
                onChange: (value) => checkPassStatus(),
                isEnabled: loading,
              ),
              TextFieldWidget(
                  preIcon: const Icon(CupertinoIcons.lock),
                  label: providerLocal.bodyLblConfirmPsd,
                  hint: providerLocal.bodyHintConfirmPsd,
                  controller: _txtConPass,
                  isPass: true,
                  isEnabled: loading,
                  validation: (value) {
                    if (value.isEmpty) {
                      return providerLocal.bodyCheckPsd;
                    } else {
                      if (value != _txtPass.text && _txtPass.text.isNotEmpty) {
                        return providerLocal.bodyYourPsdIsNotMatch;
                      }
                    }
                  }),
              passCheckColor(),
              CheckBoxWidget(
                  label: GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(
                            "https://sboapp1.github.io/sboapp.github.io/PrivacyPolicy.html");
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: Text(
                        providerLocal.bodyAgreeOur,
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      )),
                  isChecked: isChecked,
                  onChange: loading != null && loading == true
                      ? null
                      : (value) {
                          setState(() {});
                          isChecked = !isChecked;
                        }),
              Row(
                children: [
                  Expanded(
                    child: materialButton(
                      loading: loading,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: loading != null && loading == false
                          ? null
                          : performSignup,
                      text: providerLocal.bodySingUp,
                      height: MediaQuery.of(context).size.height * 0.05,
                      txtColor: Theme.of(context)
                          .colorScheme
                          .onPrimary, /*child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white),)*/
                    ),
                  ),
                ],
              ),
              outLineButton(
                  onPressed: widget.onSignIn,
                  child: buttonText(text: providerLocal.bodySingIn)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneWidget(isEnabled) {
    final providerLocal =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: CustomPhoneField(
        languageCode:
            Provider.of<AppLocalizationsNotifier>(context, listen: true)
                .selectedLocal
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
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary))),
        onChanged: (phone) {
          _txtPhone.text = phone.completeNumber;
        },
        validator: (value) {
          return providerLocal.bodyCheckPhone;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget passCheckColor() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding:
              const EdgeInsets.only(right: 4.0, top: 8.0, bottom: 8.0, left: 8),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
                color: colorStatus == "weak" ||
                        colorStatus == "normal" ||
                        colorStatus == "strong"
                    ? Colors.red
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(40)),
          ),
        )),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
                color: colorStatus == "normal" || colorStatus == "strong"
                    ? Colors.yellow
                    : Colors.yellow[100],
                borderRadius: BorderRadius.circular(40)),
          ),
        )),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(
              right: 8.0, top: 8.0, bottom: 8.0, left: 4.0),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
                color:
                    colorStatus == "strong" ? Colors.green : Colors.green[100],
                borderRadius: BorderRadius.circular(40)),
          ),
        )),
      ],
    );
  }
}
