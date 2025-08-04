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
    _initializeVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeVerification() {
    final authServices = context.read<AuthServices>();
    authServices.sendVerification();
    _timer = Timer(const Duration(seconds: 3), authServices.checkEmailVerification);
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context).localizations;

    return Scaffold(
      appBar: AppBar(
        title: appBarText(text: providerLocale.bodyVerifyEmail),
      ),
      body: Consumer<AuthServices>(
        builder: (context, authServices, child) {
          return StreamBuilder<UserModel?>(
            stream: GetDatabase().getMyUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return _buildVerificationContent(
                    snapshot.data!, providerLocale, authServices);
              } else {
                return _buildErrorContent(providerLocale);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildVerificationContent(
      UserModel user, providerLocale, AuthServices authServices) {
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
          child: titleText(text: providerLocale.bodyVerifyEmail, fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: "${providerLocale.bodyUploadBHello} ${user.name},",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextSpan(text: providerLocale.bodyUserNote),
                TextSpan(
                  text: " ${user.email} ",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextSpan(text: providerLocale.otherUserSentVerification),
              ],
            ),
          ),
        ),
        _buildActionButtons(providerLocale, authServices),
      ],
    );
  }

  Widget _buildActionButtons(providerLocale, AuthServices authServices) {
    return Column(
      children: [
        outLineButton(
          onPressed: () {
            try {
              authServices.checkEmailVerification();
            } catch (e) {
              log(e.toString());
            }
          },
          child: buttonText(text: providerLocale.bodyRefresh),
        ),
        outLineButton(
          onPressed: authServices.reSend ? authServices.sendVerification : null,
          child: authServices.reSend
              ? buttonText(text: providerLocale.bodySendVerification)
              : _getTimeLeft(providerLocale),
        ),
        outLineButton(
          onPressed: () async {
            await authServices.deleteUser();
          },
          child: buttonText(text: providerLocale.bodySignDelete),
        ),
      ],
    );
  }

  Widget _buildErrorContent(providerLocale) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.drop_triangle),
          bodyText(text: providerLocale.bodyErrorOccurred),
          IconButton(
            onPressed: () => context.read<AuthServices>().signOut(),
            icon: const Icon(CupertinoIcons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _getTimeLeft(providerLocale) {
    final authServices = context.read<AuthServices>();
    String formattedTime =
        '${(authServices.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(authServices.timeLeft % 60).toString().padLeft(2, '0')}';
    return bodyText(text: "${providerLocale.bodyWaitResend} $formattedTime");
  }
}
