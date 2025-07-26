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

  void saveData(bool isRem, String email, String pass) async {
    if (isRem == true) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', email);
      prefs.setString('password', pass);
    }
  }

  String? storedEmail;
  String? storedPass;
  void getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    storedEmail = prefs.get('username').toString();
    storedPass = prefs.get('password').toString();
    if (prefs.get("username") != null && prefs.get("password") != null) {
      _txtEmail.text = storedEmail!;
      _txtPass.text = storedPass!;
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  String? checkPassStatus(value, providerLocale) {
    if (value.isEmpty) {
      return providerLocale.bodyEmptyValid("Password");
    } else {
      if (value.length < 6) {
        return providerLocale.bodyMinPsdError;
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
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
                  fontSize: MediaQuery.of(context).textScaler.scale(28)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextFieldWidget(
              preIcon: const Icon(CupertinoIcons.mail),
              label: providerLocale.bodyLblEmail,
              hint: providerLocale.bodyHintEmail,
              controller: _txtEmail,
              validation: (value) {
                if (value.isEmpty) {
                  return providerLocale.bodyEmptyEmail;
                } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return providerLocale.bodyEnterValid;
                } else {
                  return null;
                }
              },
              isEnabled: loading,
            ),
            TextFieldWidget(
              preIcon: const Icon(CupertinoIcons.lock),
              label: providerLocale.bodyLblPsd,
              hint: providerLocale.bodyHintPsd,
              controller: _txtPass,
              isPass: true,
              validation: (value) => checkPassStatus(value, providerLocale),
              isEnabled: loading,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CheckBoxWidget(
                    label: buttonText(text: providerLocale.bodyRemember),
                    isChecked: isRem,
                    onChange: loading != null && loading == false
                        ? null
                        : (value) {
                            setState(() {
                              isRem = !isRem;
                            });
                          }),
                outLineButton(
                    //SnackBar(content: Text(providerLocale.bodyResendPsdWait))
                    onPressed: timeLeft
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                            customizedSnackBar(
                                title: "Reset Password",
                                message: providerLocale.bodyResendPsdWait,
                                contentType: ContentType.warning))
                        : () {
                            Future.delayed(const Duration(minutes: 5))
                                .whenComplete(() => setState(() {
                                      timeLeft = false;
                                    }));
                            showDialog(
                                context: context,
                                builder: (context) {
                                  _txtForgetPass.text = _txtEmail.value.text;
                                  return AlertDialog(
                                    title: titleText(
                                        text: providerLocale.bodyForgetPsd),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MyTextFromField(
                                            labelText:
                                                providerLocale.bodyLblEmail,
                                            hintText:
                                                providerLocale.bodyHintEmail,
                                            textEditingController:
                                                _txtForgetPass)
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: buttonText(
                                              text: providerLocale.bodyCancel)),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              timeLeft = true;
                                            });
                                            Navigator.pop(context);
                                            final singInPro =
                                                Provider.of<AuthServices>(
                                                    context,
                                                    listen: false);
                                            singInPro.forgetPsd(
                                                _txtForgetPass.value.text);
                                          },
                                          child: buttonText(
                                              text: providerLocale
                                                  .bodySendResetLink))
                                    ],
                                  );
                                });
                          },
                    child: buttonText(text: providerLocale.bodyForgetPsd)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: materialButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: loading != null && loading == false
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = false;
                              });
                              if (isRem == true) {
                                saveData(isRem, _txtEmail.text.trim(),
                                    _txtPass.text.trim());
                              }
                              final singInPro = Provider.of<AuthServices>(
                                  context,
                                  listen: false);
                              singInPro
                                  .signIn(_txtEmail.text, _txtPass.text)
                                  .whenComplete(() {
                                if (singInPro.errorMsg != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      customizedSnackBar(
                                          title: "Error",
                                          message: singInPro.errorMsg!,
                                          contentType: ContentType.failure));
                                  //showDialog(context: context, builder:(context)=> AlertDialog(title: titleText(text: "Error"),content: Text(singInPro.errorMsg!),));
                                  setState(() {
                                    loading = null;
                                  });
                                }
                                setState(() {
                                  loading = null;
                                });
                              });
                            }
                          },
                    text: providerLocale.bodySingIn,
                    loading: loading,
                    height: MediaQuery.of(context).size.height * 0.05,
                    txtColor: Theme.of(context).colorScheme.onPrimary,
                    /*child: const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                )*/
                  ),
                ),
              ],
            ),
            outLineButton(
                onPressed: widget.onSignUp,
                child: buttonText(text: providerLocale.bodyCreate)),

            ///*
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  onPressed: loading != null && loading == false ? null : () {
                    setState(() {
                      loading = true;
                    });
                    final singInPro =
                    Provider.of<AuthServices>(context, listen: false);
                    singInPro.signInWithGoogle().whenComplete(() {
                      if (singInPro.errorMsg != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            customizedSnackBar(
                                title: "Error",
                                message: singInPro.errorMsg!,
                                contentType: ContentType.failure));
                        //errorAlert(context: context, msg: singInPro.errorMsg!);
                        setState(() {
                          loading = null;
                        });
                      }
                    }).catchError((er) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          customizedSnackBar(
                              title: "Error",
                              message: singInPro.errorMsg!,
                              contentType: ContentType.failure));
                      //errorAlert(context: context, msg: singInPro.errorMsg!);
                      setState(() {
                        loading = null;
                      });
                    });
                    // Your Google sign-in logic
                  },
                  icon: Image.asset("assets/images/g_icon.png", height: 24),
                  label: Text(loading != null && loading == true ? "Connecting..." : providerLocale.bodyContWitG),
                ),
              ),
            ),
            //*/
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
}
