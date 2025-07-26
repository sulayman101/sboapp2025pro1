import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Ads/navi_ads.dart';
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
  // ignore: prefer_final_fields
  Random _random = Random();
  bool wait = false;

  final double containerSize = 0.83;
  final double containerAdSize = 0.79;
  final double headerTitle = 0.17;

  String constProfile =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FuserProfile%5B1%5D.png?alt=media&token=234392a7-3cf7-47cd-a8ee-f375944718c1";

  Future showModelResult(result, providerLocale) async {
    showDialog(
        context: context,
        builder: (context) => PopScope(
              canPop: false,
              child: AlertDialog(
                title: titleText(text: providerLocale.bodyResult),
                content: bodyText(text: result),
                actions: [
                  //ElevatedButton(onPressed: (){} , child: buttonText(text: "Watch Ads")),
                  ElevatedButton(
                      onPressed: () {
                        if (Provider.of<GetDatabase>(context, listen: false)
                                .subscriber ==
                            false) {
                          Provider.of<NavigatePageAds>(context, listen: false)
                              .showInterstitialAd();
                        }
                        Navigator.pop(context);
                      },
                      child: buttonText(text: providerLocale.bodyOk)),
                ],
              ),
            ));
  }

  void _startLottery() {
    if (_timer != null) {
      _timer!.cancel();
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    Size size = MediaQuery.of(context).size;
    return ScaffoldWidget(
      body: Consumer<GetDatabase>(
          builder: (BuildContext context, GetDatabase value, Widget? child) {
        final provider = context.read<GetDatabase>();
        return StreamBuilder<UserModel>(
            stream: provider.getMyUser(),
            builder: (BuildContext context, AsyncSnapshot<UserModel> snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Image.asset(
                      "assets/images/gifLoading.gif",
                      scale: 4,
                    )),
                    bodyText(text: providerLocale.bodyWait)
                  ],
                );
              }
              if (snap.hasData) {
                return StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref("$dbName/luckyUser")
                        .onValue,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Image.asset(
                              "assets/images/gifLoading.gif",
                              scale: 4,
                            )),
                            bodyText(text: providerLocale.bodyWait)
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        final dataSnapshot = snapshot.data!.snapshot;
                        final data =
                            dataSnapshot.value as Map<dynamic, dynamic>;
                        final isOn = data["isOn"] as bool;
                        final weekWinner = data["weekWin"] as bool;
                        return CustomScrollView(slivers: [
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            expandedHeight: size.height * 0.5,
                            flexibleSpace: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                //double ads = isActiveAds ? 0.16 : 0.16;
                                return FlexibleSpaceBar(
                                    title:
                                        constraints.biggest.height <=
                                                size.height * headerTitle
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15.0),
                                                  child: SizedBox(
                                                    height: size.height * 0.075,
                                                    child: Card(
                                                      elevation: 7,
                                                      //color: Theme.of(context).colorScheme.secondaryContainer,
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional
                                                                          .centerStart,
                                                                  child: IconButton(
                                                                      onPressed: () => Navigator.pop(context),
                                                                      alignment: Alignment.center,
                                                                      icon: const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                8.0,
                                                                            top:
                                                                                4.0,
                                                                            bottom:
                                                                                4.0),
                                                                        child: Icon(
                                                                            Icons.arrow_back_ios),
                                                                      )),
                                                                ),
                                                                //backgroundColor: Theme.of(context).colorScheme.surface,
                                                                Center(
                                                                    child: titleText(
                                                                        text: providerLocale
                                                                            .appBarWinWeek,
                                                                        fontSize:
                                                                            24)),
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : null,
                                    stretchModes: const [
                                      StretchMode.fadeTitle,
                                    ],
                                    background: Hero(
                                      tag: data['gifImg'],
                                      transitionOnUserGestures: true,
                                      child: Image.network(
                                        data['gifImg'],
                                        fit: BoxFit.cover,
                                      ),
                                    ));
                              },
                            ),
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(50),
                              child: ShakeY(
                                from: 100,
                                duration: const Duration(milliseconds: 500),
                                child: Transform.translate(
                                  offset: const Offset(0, 1),
                                  child: Container(
                                    height: size.height * 0.03,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.2), // shadow color
                                          spreadRadius:
                                              0.2, // how wide the shadow spreads
                                          blurRadius: 10, // blur effect
                                          offset: const Offset(0,
                                              -1), // shadow offset upwards (top)
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: size.width * 0.2,
                                        height: size.height * 0.015,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade500,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                              delegate: SliverChildListDelegate([
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: isActiveAds
                                    ? size.height * containerAdSize
                                    : size.height * containerSize,
                                child: Column(
                                  children: [
// admin role
                                    Visibility(
                                      visible: snap.data!.role == "Admin" ||
                                          snap.data!.role == "Owner",
                                      child: Card.filled(
                                        elevation: 5,
                                        //color: Theme.of(context).colorScheme.secondaryContainer,
                                        child: Column(
                                          children: [
                                            SwitchListTile(
                                              value: isOn,
                                              onChanged: (value) {
                                                provider.updateLuckySwitch(
                                                    isOn: value);
                                              },
                                              title: lTitleText(
                                                  text: providerLocale
                                                      .bodyEnableWkGift),
                                            ),
                                            MyTextFromField(
                                                labelText: providerLocale
                                                    .bodyLuckyNumber,
                                                hintText: providerLocale
                                                    .bodyUpLuckyNum,
                                                textEditingController:
                                                    _txtLucky),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: materialButton(
                                                      onPressed: () {
                                                        provider
                                                            .updateLuckyNumber(
                                                                lucky: int.parse(
                                                                    _txtLucky
                                                                        .text));
                                                        _txtLucky.clear();
                                                      },
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      txtColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                      text: providerLocale
                                                          .bodyUpdate),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card.filled(
                                      elevation: 5,
                                      //color: Theme.of(context).colorScheme.secondaryContainer,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                                child: ClipOval(
                                              child: Image.asset(
                                                  "assets/images/win.gif"),
                                            )),
                                            title: Text(
                                              "${providerLocale.bodyWinUser} ${data["winUser"]}",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Card.filled(
                                      elevation: 5,
                                      //color: Theme.of(context).colorScheme.secondaryContainer,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                            radius: 30,
                                            child: snap.data!.profile == null
                                                ? ClipOval(
                                                    child: Image.network(
                                                        constProfile))
                                                : ClipOval(
                                                    child: Image.network(
                                                        snap.data!.profile!))),
                                        title: Text(snap.data!.name),
                                        subtitle: Text(
                                            "${providerLocale.bodyLastDateLucky} ${snap.data!.luckyDate != null ? snap.data!.luckyDate! : "--/--/----"}"),
                                        trailing: CircleAvatar(
                                          child: customText(
                                              text:
                                                  "${snap.data!.lucky != null ? snap.data!.lucky! : 0}"),
                                        ),
                                      ),
                                    ),
                                    Card.filled(
                                      elevation: 5,
                                      //color: Theme.of(context).colorScheme.secondaryContainer,
                                      child: isOn
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: titleText(
                                                    text:
                                                        '${providerLocale.bodyLuckyNum} ${data['lucky']}',
                                                    fontSize: 24,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                CircleAvatar(
                                                  radius: 50,
                                                  child: Text(
                                                    _currentNumber == 0
                                                        ? '${snap.data!.lucky ?? 0}'
                                                        : '$_currentNumber',
                                                    style: const TextStyle(
                                                        fontSize: 48,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(height: 40),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: materialButton(
                                                    onPressed: () {
                                                      if (Provider.of<GetDatabase>(
                                                                  context,
                                                                  listen: false)
                                                              .subscriber ==
                                                          false) {
                                                        Provider.of<NavigatePageAds>(
                                                                context,
                                                                listen: false)
                                                            .createInterstitialAd();
                                                      }
                                                      if (!weekWinner) {
                                                        DateTime today =
                                                            DateTime.now();
                                                        if (snap.data!
                                                                .luckyDate !=
                                                            null) {
                                                          DateTime date =
                                                              DateTime.parse(snap
                                                                  .data!
                                                                  .luckyDate!);
                                                          if (today
                                                                  .difference(
                                                                      date)
                                                                  .inDays >
                                                              7) {
                                                            _startLottery();
                                                            Future.delayed(
                                                                    const Duration(
                                                                        seconds:
                                                                            6))
                                                                .whenComplete(
                                                                    () {
                                                              provider
                                                                  .checkAndUpdateLuckyDate();
                                                              provider.updateLucky(
                                                                  lucky:
                                                                      _currentNumber);
                                                              if (_currentNumber ==
                                                                  data[
                                                                      'lucky']) {
                                                                provider.updateLuckyWinUser(
                                                                    winUser: snap
                                                                        .data!
                                                                        .name);
                                                                provider.updateLuckyWeekWinner(
                                                                    weekWinner:
                                                                        weekWinner);
                                                                showModelResult(
                                                                    "${providerLocale.bodyCongregateGift} ${data['item']}",
                                                                    providerLocale);
                                                              } else {
                                                                showModelResult(
                                                                    providerLocale
                                                                        .bodySorryGift(
                                                                            _currentNumber.toString()),
                                                                    providerLocale);
                                                              }
                                                            });
                                                          } else {
                                                            showModelResult(
                                                                providerLocale
                                                                    .bodyAlreadyGot(
                                                                        "${snap.data!.lucky}"),
                                                                providerLocale);
                                                          }
                                                        } else {
                                                          _startLottery();
                                                          Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          6))
                                                              .whenComplete(() {
                                                            provider
                                                                .checkAndUpdateLuckyDate();
                                                            provider.updateLucky(
                                                                lucky:
                                                                    _currentNumber);
                                                            if (_currentNumber ==
                                                                data['lucky']) {
                                                              provider.updateLuckyWinUser(
                                                                  winUser: snap
                                                                      .data!
                                                                      .name);
                                                              showModelResult(
                                                                  "${providerLocale.bodyCongregateGift} ${data['item']}",
                                                                  providerLocale);
                                                            } else {
                                                              showModelResult(
                                                                  providerLocale
                                                                      .bodySorryGift(
                                                                          _currentNumber
                                                                              .toString()),
                                                                  providerLocale);
                                                            }
                                                          });
                                                        }
                                                      } else {
                                                        // print("message");
                                                        showModelResult(
                                                            providerLocale
                                                                .bodyWeekWinner(
                                                                    data[
                                                                        'winUser']),
                                                            providerLocale);
                                                      }
                                                    },
                                                    text: providerLocale
                                                        .bodyLucky,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                    txtColor: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/gift.gif",
                                                  ),
                                                  titleText(
                                                      text: providerLocale
                                                          .bodyPreparingGift),
                                                ],
                                              ),
                                            ),
                                    ),
                                    /*const Divider(),
                                    Card.filled(
                                      child: ListTile(leading: const Icon(Icons.games_outlined), title: customText(text: "Memory Game"),subtitle: customText(text: "let's refresh your mind!"), trailing: const Icon(Icons.arrow_forward_ios),
                                        onTap: ()=> Navigator.pushNamed(context, "/game"),
                                      ),
                                    )*/
                                  ],
                                ),
                              ),
                            ),
                          ])),
                        ]);
                      } else {
                        return const CircularProgressIndicator();
                      }
                    });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      }),
    );
  }
}

/**
import 'dart:developer';
import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/AppModel/user_model.dart';
import 'package:sboapp/Components/ads_and_net.dart';
import 'package:sboapp/Constants/button_style.dart';
import 'package:sboapp/Constants/text_form_field.dart';
import 'package:sboapp/Services/appDatabase.dart';
import 'package:sboapp/Services/winServices.dart';

import '../../Ads/navi_ads.dart';
import '../../Constants/text_style.dart';
import '../../Services/lanServices/language_provider.dart';
class WinGift extends StatefulWidget {
  const WinGift({super.key});

  @override
  State<WinGift> createState() => _WinGiftState();
}

class _WinGiftState extends State<WinGift> {

  final _txtLucky = TextEditingController();

  int _currentNumber = 0;
  Timer? _timer;
  Random _random = Random();
  bool wait = false;

  Future showModelResult(result, providerLocale)async{
    showDialog(context: context, builder: (context)=> PopScope(
      canPop: false,
      child: AlertDialog(
        title: titleText(text: providerLocale.bodyResult),
        content: bodyText(text: result),
        actions: [
          //ElevatedButton(onPressed: (){} , child: buttonText(text: "Watch Ads")),
          ElevatedButton(onPressed: (){
            if(Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
              Provider.of<NativeAdsState>(context, listen: false)
                  .showInterstitialAd();
            }
            Navigator.pop(context);}, child: buttonText(text: providerLocale.bodyOk)),
        ],
      ),
    ));
  }

  void _startLottery() {
    if (_timer != null) {
      _timer!.cancel();
    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
      Provider.of<NativeAdsState>(context, listen: false).showInterstitialAd();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale = Provider.of<AppLocalizationsNotifier>(context, listen: true).localizations;
    return ScaffoldWidget(
      appBar: AppBar(title: appBarText(text: providerLocale.bodyWinGift),),
        body: Consumer<GetDatabase>(builder: (BuildContext context, GetDatabase value, Widget? child) {
          final provider = context.read<GetDatabase>();
          return SingleChildScrollView(
            child: StreamBuilder<UserModel>(stream: provider.getMyUser(), builder: (BuildContext context, AsyncSnapshot<UserModel> snap) {
              if(snap.connectionState == ConnectionState.waiting && !snap.hasData){
                return const Center(child: CircularProgressIndicator());
              }
              if(snap.hasData){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Card(child: SizedBox(width: double.infinity,child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: titleText(text: providerLocale.bodyWinGift, fontSize: 24)),
                      )),),
                      StreamBuilder(
                        stream: FirebaseDatabase.instance.ref("$dbName/luckyUser").onValue,
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData){
                          return const Center(child: CircularProgressIndicator());
                        }
                        if(snapshot.hasData){
                          final dataSnapshot = snapshot.data!.snapshot;
                          final data = dataSnapshot.value as Map<dynamic, dynamic>;
                          final isOn = data["isOn"] as bool;
                          final weekWinner = data["weekWin"] as bool;
                          return Column(children: [
                            Visibility(visible: snap.data!.role == "Admin" || snap.data!.role == "Owner",child:
                            Card(
                              child: Column(
                                children: [
                                  SwitchListTile(value: isOn, onChanged: (value){
                                    provider.updateLuckySwitch(isOn: value);
                                  }, title: lTitleText(text: providerLocale.bodyEnableWkGift),),
                                  MyTextFromField(labelText: providerLocale.bodyLuckyNumber, hintText: providerLocale.bodyUpLuckyNum, textEditingController: _txtLucky),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: materialButton(onPressed: (){
                                          provider.updateLuckyNumber(lucky: int.parse(_txtLucky.text));
                                          _txtLucky.clear();
                                        },
                                          height: MediaQuery.of(context).size.height * 0.05,
                                            color: Theme.of(context).colorScheme.primary,
                                          txtColor: Theme.of(context).colorScheme.onPrimary,
                                          text: providerLocale.bodyUpdate),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                            Card(
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${providerLocale.bodyWinUser} ${data["winUser"]}", style: const TextStyle(fontSize: 18),),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: CircleAvatar(radius: 30,child: snap.data!.profile == null ?
                              Icon(CupertinoIcons.person) : ClipOval(child: Image.network(snap.data!.profile!))),
                              title: Text(snap.data!.name),
                              subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${providerLocale.bodyLastLuckyNum} ${snap.data!.lucky != null ? snap.data!.lucky! : 0}"),
                                  Text("${providerLocale.bodyLastDateLucky} ${snap.data!.luckyDate != null ? snap.data!.luckyDate! : "--/--/----"}"),
                                ],
                              ),
                              trailing: ElevatedButton(onPressed: !isOn ? null : (){
                                showDialog(context: context, builder: (context)=> AlertDialog(title:
                                titleText(text: providerLocale.bodyWinThisGift),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(borderRadius: BorderRadius.circular(20) , child: AspectRatio(aspectRatio: 1/1 ,child: Image.network(data['gifImg'])),),
                                      Text(data['item'])
                                    ],
                                  ),
                                ));
                              }, child: Text(providerLocale.bodyShowGift),),
                            ),
                            Card(
                              child: isOn ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: titleText(text:
                                      '${providerLocale.bodyLuckyNum} ${data['lucky']}',
                                      fontSize: 24,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  CircleAvatar(
                                    radius: 50,
                                    child: Text(
                                      _currentNumber == 0 ? '${snap.data!.lucky ?? 0}'
                                                  : '$_currentNumber',
                                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    child: materialButton(
                                      onPressed: (){
                                        if(Provider.of<GetDatabase>(context, listen: false).subscriber == false) {
                                          Provider.of<NativeAdsState>(context, listen: false).createInterstitialAd();
                                        }
                                        if(!weekWinner){
                                        DateTime today = DateTime.now();
                                        if(snap.data!.luckyDate != null) {
                                          DateTime date = DateTime.parse(
                                              snap.data!.luckyDate!);
                                          if (today
                                              .difference(date)
                                              .inDays > 7) {
                                            _startLottery();
                                            Future.delayed(const Duration(seconds: 6)).whenComplete((){
                                                provider.checkAndUpdateLuckyDate();
                                                provider.updateLucky(lucky: _currentNumber);
                                                if(_currentNumber == data['lucky']) {
                                                  provider.updateLuckyWinUser(winUser: snap.data!.name);
                                                  provider.updateLuckyWeekWinner(weekWinner: weekWinner);
                                                  showModelResult("${providerLocale.bodyCongregateGift} ${data['item']}", providerLocale);
                                                }else{
                                                  showModelResult(providerLocale.bodySorryGift(_currentNumber.toString()), providerLocale);
                                                }});
                                          }else{
                                            showModelResult(providerLocale.bodyAlreadyGot("${snap.data!.lucky}"), providerLocale);
                                          }
                                        }
                                        else{
                                          _startLottery();
                                          Future.delayed(const Duration(seconds: 6)).whenComplete((){
                                            provider.checkAndUpdateLuckyDate();
                                            provider.updateLucky(lucky: _currentNumber);
                                          if(_currentNumber == data['lucky']) {
                                            provider.updateLuckyWinUser(winUser: snap.data!.name);
                                            showModelResult("${providerLocale.bodyCongregateGift} ${data['item']}", providerLocale);
                                          }else{
                                            showModelResult(providerLocale.bodySorryGift(_currentNumber.toString()), providerLocale);
                                          }});
                                        }}else{
                                          print("message");
                                          showModelResult(providerLocale.bodyWeekWinner(data['winUser']), providerLocale);
                                        }
                                        /*Provider.of<NativeAdsState>(context, listen: false).createInterstitialAd();
                                        if (snap.data!.lucky == 0 || snap.data!.lucky == null) {
                                          // Wait until it's not Friday
                                          while (DateTime.now().day == DateTime.sunday) {
                                          _startLottery();
                                          Future.delayed(const Duration(seconds: 6)).whenComplete((){
                                            Provider.of<GetDatabase>(context, listen: false).updateLucky(lucky: _currentNumber);
                                            if(_currentNumber == data['lucky']){
                                              showModelResult("${providerLocale.bodyCongregateGift} ${data['item']}", providerLocale);
                                            }else{
                                              showModelResult(providerLocale.bodySorryGift(_currentNumber.toString()), providerLocale);
                                            }
                                          });
                                          }
                                          }else{
                                          showModelResult(providerLocale.bodyAlreadyGot("${snap.data!.lucky}"), providerLocale);
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: bodyText(text: providerLocale.bodyAlreadyDone)));
                                        }
                                        */
                                        },
                                      text: providerLocale.bodyLucky,
                                      color: Theme.of(context).colorScheme.primary,
                                      height: MediaQuery.of(context).size.height * 0.05,
                                      txtColor: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ) :
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.3,
                                width: MediaQuery.of(context).size.width * 1,
                                child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  Image.asset("assets/images/gift.gif",),
                                  titleText(text: providerLocale.bodyPreparingGift),
                                ],),
                              ),
                            ),
            
            
                          ],);
                        }else{
                          return Text(providerLocale.bodyNoData);
                        }
                      },)
                    ],),
                );
              }else{
                return Center(child: Text(providerLocale.bodyNoData),);
              }
            },),
          );
        },
        ));
  }
}
*/
