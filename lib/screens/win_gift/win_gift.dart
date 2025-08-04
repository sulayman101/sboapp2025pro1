import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';
import '../../services/navigate_page_ads.dart';

class WinGift extends StatefulWidget {
  const WinGift({super.key});

  @override
  State<WinGift> createState() => _WinGiftState();
}

class _WinGiftState extends State<WinGift> {
  final _txtLucky = TextEditingController();
  int _currentNumber = 0;
  Timer? _timer;
  final Random _random = Random();
  bool isWaiting = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLottery() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentNumber = _random.nextInt(500) + 1;
      });
    });
    Future.delayed(const Duration(seconds: 5), () {
      _timer?.cancel();
      setState(() {
        _currentNumber = _random.nextInt(500) + 1;
      });
    });
  }

  Future<void> _showResultDialog(String result, dynamic providerLocale) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: providerLocale.bodyResult),
        content: bodyText(text: result),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (!Provider.of<GetDatabase>(context, listen: false)
                  .subscriber) {
                Provider.of<NavigatePageAds>(context, listen: false)
                    .showInterstitialAd();
              }
              Navigator.pop(context);
            },
            child: buttonText(text: providerLocale.bodyOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      body: Consumer<GetDatabase>(
        builder: (context, provider, child) {
          return StreamBuilder<UserModel?>(
            stream: provider.getMyUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting &&
                  !userSnapshot.hasData) {
                return _buildLoading(providerLocale);
              }
              if (userSnapshot.hasData) {
                return _buildGiftContent(userSnapshot.data!, providerLocale);
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  Widget _buildLoading(dynamic providerLocale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Image.asset("assets/images/gifLoading.gif", scale: 4)),
        bodyText(text: providerLocale.bodyWait),
      ],
    );
  }

  Widget _buildGiftContent(UserModel user, dynamic providerLocale) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("$dbName/luckyUser").onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoading(providerLocale);
        }
        if (snapshot.hasData) {
          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          return _buildGiftUI(user, data, providerLocale);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildGiftUI(
      UserModel user, Map<String, dynamic> data, dynamic providerLocale) {
    final bool isOn = data["isOn"] as bool;
    final bool weekWinner = data["weekWin"] as bool;

    return CustomScrollView(
      slivers: [
        _buildAppBar(data),
        SliverList(
          delegate: SliverChildListDelegate([
            _buildAdminControls(user, isOn, providerLocale),
            _buildWinnerInfo(data, providerLocale),
            _buildUserInfo(user, providerLocale),
            _buildLotterySection(user, data, isOn, weekWinner, providerLocale),
          ]),
        ),
      ],
    );
  }

  Widget _buildAppBar(Map<String, dynamic> data) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: data['gifImg'],
          child: Image.network(data['gifImg'], fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildAdminControls(
      UserModel user, bool isOn, dynamic providerLocale) {
    if (user.role != "Admin" && user.role != "Owner") return const SizedBox();

    return Card.filled(
      child: Column(
        children: [
          SwitchListTile(
            value: isOn,
            onChanged: (value) {
              Provider.of<GetDatabase>(context, listen: false)
                  .updateLuckySwitch(isOn: value);
            },
            title: lTitleText(text: providerLocale.bodyEnableWkGift),
          ),
          MyTextFromField(
            labelText: providerLocale.bodyLuckyNumber,
            hintText: providerLocale.bodyUpLuckyNum,
            textEditingController: _txtLucky,
          ),
          materialButton(
            onPressed: () {
              Provider.of<GetDatabase>(context, listen: false)
                  .updateLuckyNumber(lucky: int.parse(_txtLucky.text));
              _txtLucky.clear();
            },
            text: providerLocale.bodyUpdate,
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerInfo(Map<String, dynamic> data, dynamic providerLocale) {
    return Card.filled(
      child: ListTile(
        leading: CircleAvatar(child: Image.asset("assets/images/win.gif")),
        title: Text(
          "${providerLocale.bodyWinUser} ${data["winUser"]}",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel user, dynamic providerLocale) {
    return Card.filled(
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: user.profile == null
              ? const Icon(Icons.person)
              : ClipOval(child: Image.network(user.profile!)),
        ),
        title: Text(user.name),
        subtitle: Text(
          "${providerLocale.bodyLastDateLucky} ${user.luckyDate ?? "--/--/----"}",
        ),
        trailing: CircleAvatar(
          child: customText(text: "${user.lucky ?? 0}"),
        ),
      ),
    );
  }

  Widget _buildLotterySection(UserModel user, Map<String, dynamic> data,
      bool isOn, bool weekWinner, dynamic providerLocale) {
    if (!isOn) {
      return _buildPreparingGift(providerLocale);
    }

    return Card.filled(
      child: Column(
        children: [
          titleText(
            text: '${providerLocale.bodyLuckyNum} ${data['lucky']}',
            fontSize: 24,
          ),
          CircleAvatar(
            radius: 50,
            child: Text(
              _currentNumber == 0 ? '${user.lucky ?? 0}' : '$_currentNumber',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          materialButton(
            onPressed: () =>
                _handleLottery(user, data, weekWinner, providerLocale),
            text: providerLocale.bodyLucky,
          ),
        ],
      ),
    );
  }

  Widget _buildPreparingGift(dynamic providerLocale) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/gift.gif"),
          titleText(text: providerLocale.bodyPreparingGift),
        ],
      ),
    );
  }

  void _handleLottery(UserModel user, Map<String, dynamic> data,
      bool weekWinner, dynamic providerLocale) {
    if (!weekWinner) {
      final provider = Provider.of<GetDatabase>(context, listen: false);
      final today = DateTime.now();

      if (user.luckyDate != null) {
        final lastLuckyDate = DateTime.parse(user.luckyDate!);
        if (today.difference(lastLuckyDate).inDays > 7) {
          _startLottery();
          Future.delayed(const Duration(seconds: 6)).whenComplete(() {
            provider.checkAndUpdateLuckyDate();
            provider.updateLucky(lucky: _currentNumber);

            if (_currentNumber == data['lucky']) {
              provider.updateLuckyWinUser(winUser: user.name);
              _showResultDialog(
                "${providerLocale.bodyCongregateGift} ${data['item']}",
                providerLocale,
              );
            } else {
              _showResultDialog(
                providerLocale.bodySorryGift(_currentNumber.toString()),
                providerLocale,
              );
            }
          });
        } else {
          _showResultDialog(
            providerLocale.bodyAlreadyGot("${user.lucky}"),
            providerLocale,
          );
        }
      } else {
        _startLottery();
        Future.delayed(const Duration(seconds: 6)).whenComplete(() {
          provider.checkAndUpdateLuckyDate();
          provider.updateLucky(lucky: _currentNumber);

          if (_currentNumber == data['lucky']) {
            provider.updateLuckyWinUser(winUser: user.name);
            _showResultDialog(
              "${providerLocale.bodyCongregateGift} ${data['item']}",
              providerLocale,
            );
          } else {
            _showResultDialog(
              providerLocale.bodySorryGift(_currentNumber.toString()),
              providerLocale,
            );
          }
        });
      }
    } else {
      _showResultDialog(
        providerLocale.bodyWeekWinner(data['winUser']),
        providerLocale,
      );
    }
  }
}
