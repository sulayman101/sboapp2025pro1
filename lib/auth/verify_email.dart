import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    context.read<AuthServices>().sendVerification();
    _timer = Timer(const Duration(seconds: 3), () {
      context.read<AuthServices>().checkEmailVerify();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Scaffold(
        appBar: AppBar(
          title: appBarText(text: providerLocale.bodyVerifyEmail),
        ),
        body: Consumer<AuthServices>(
          builder: (BuildContext context, AuthServices value, Widget? child) {
            final provider = context.read<AuthServices>();
            return StreamBuilder<UserModel>(
                stream: GetDatabase().getMyUser(),
                builder:
                    (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/verifyGif.gif"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: titleText(
                              text: providerLocale.bodyVerifyEmail,
                              fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(children: [
                                TextSpan(
                                    text:
                                        "${providerLocale.bodyUploadBHello} ${snapshot.data!.name},",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                TextSpan(text: providerLocale.bodyUserNote),
                                TextSpan(
                                    text: " ${snapshot.data!.email} ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                TextSpan(
                                  text:
                                      providerLocale.otherUserSentVerification,
                                ),
                              ])),
                        ),
                        outLineButton(
                            onPressed: () {
                              try {
                                provider.checkEmailVerify();
                              } catch (e) {
                                log(e.toString());
                              }
                            },
                            child:
                                buttonText(text: providerLocale.bodyRefresh)),

                        outLineButton(
                            onPressed: provider.reSend
                                ? provider.sendVerification
                                : null,
                            child: provider.reSend
                                ? buttonText(
                                    text: providerLocale.bodySendVerification)
                                : _getTimeLeft(providerLocale)),
                        // buttonText(text: AllConstText().otherTexts.resend)),
                        outLineButton(
                            onPressed: () async {
                              await Provider.of<AuthServices>(context,
                                      listen: false)
                                  .deleteUser();
                            },
                            child: buttonText(
                                text: providerLocale.bodySignDelete)),
                        /*Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: bodyText(
                      text: _otherTexts.reDictText,
                    //textAlign: TextAlign.center,
                  )),
              ElevatedButton(
                  onPressed: provider.checkEmailVerify,
                  child: buttonsText(
                      text: _otherTexts.vContinue, context: context)),
              TextButton(
                  onPressed: provider.reSend ? provider.sendVerification : null,
                  child: provider.reSend
                      ? buttonsText(
                      text: _otherTexts.sendVerification, context: context)
                      : _getTimeLeft()),
              TextButton(
                  child: buttonsText(text: _otherTexts.cancel, context: context),
                  onPressed: () {
                    final provider = context.read<UserAuthProvider>();
                    provider.signOut();
                    _timer?.cancel();
                  }),*/
                      ],
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.drop_triangle),
                          bodyText(text: providerLocale.bodyErrorOccurred),
                          IconButton(
                              onPressed: () => Provider.of<AuthServices>(
                                      context,
                                      listen: false)
                                  .singOut(),
                              icon: const Icon(CupertinoIcons.refresh))
                        ],
                      ),
                    );
                  }
                });
          },
        )
        /*Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/verifyGif.gif"),
        Text("data"),
    ],),*/
        );
  }

  Widget _getTimeLeft(providerLocale) {
    final provider = context.read<AuthServices>();
    String formattedTime =
        '${(provider.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(provider.timeLeft % 60).toString().padLeft(2, '0')}';
    return bodyText(text: "${providerLocale.bodyWaitResend} $formattedTime");
  }
}
