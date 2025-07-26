

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/text_field_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/check_subs.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/Settings/settings_page.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _txtUpName = TextEditingController();
  final _txtUpPhone = TextEditingController();
  final _txtUpEmail = TextEditingController();

  final _txtNewPass = TextEditingController();
  final _txtConPass = TextEditingController();

  late AnimationController _controller;
  Animation<double>? _animation;

  String? colorStatus;

  String constProfile =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FuserProfile%5B1%5D.png?alt=media&token=234392a7-3cf7-47cd-a8ee-f375944718c1";

  void checkPassStatus() {
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(_txtNewPass.text);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(_txtNewPass.text);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(_txtNewPass.text);
    if (_txtNewPass.text.isNotEmpty && _txtNewPass.text.length >= 6) {
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

  String? checkPass(value, providerLocale) {
    if (value.isEmpty) {
      return providerLocale.bodyHintPsd;
    } else {
      if (value.length < 6) {
        return providerLocale.bodyCheckPsd;
      } else {
        return null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flip() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _updateUser(snapshot) {
    if (_txtUpName.text.isEmpty &&
        _txtUpEmail.text.isEmpty &&
        _txtUpPhone.text.isEmpty) {
      _flip();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nothing Updated")));
    } else {
      final fullName = _txtUpName.text.trim();
      final phone = _txtUpPhone.text.trim();
      GetDatabase().updateMyUser(fullName: fullName, phone: phone);
      _flip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final divSized = MediaQuery.of(context).size.width * 0.4;
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarProfile),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<UserModel>(
              stream: GetDatabase().getMyUser(),
              builder:
                  (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const ProfileShimmer(
                    isBannerProfile: false,
                  );
                }
                if (snapshot.hasData) {
                  if (_txtUpName.text.isEmpty &&
                      _txtUpPhone.text.isEmpty &&
                      _txtUpEmail.text.isEmpty) {
                    _txtUpName.text = snapshot.data!.name;
                    _txtUpPhone.text = snapshot.data!.phone.toString();
                    _txtUpEmail.text = snapshot.data!.email;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () => showProfile(snapshot),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          boxShadow: [
                                            // Glowing shadow effect
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(
                                                      0.4), // Glow color
                                              spreadRadius: 2,
                                              blurRadius: 1,
                                            ),
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(
                                                      0.2), // Additional layers of glow
                                              spreadRadius: 4,
                                              blurRadius: 2,
                                            ),
                                          ]),
                                      child: CircleAvatar(
                                        radius: 50,
                                        child: ClipOval(
                                            child: ImageNetCache(
                                                imageUrl:
                                                    snapshot.data!.profile ??
                                                        constProfile)),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      _animation!.value < 0.5 ? false : true,
                                  child: Positioned.directional(
                                    textDirection:
                                        providerLocale.language == "العربية"
                                            ? TextDirection.ltr
                                            : TextDirection.rtl,
                                    bottom: 0,
                                    start: 0,
                                    child: GestureDetector(
                                      onTap: () => ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: bodyText(
                                                  text:
                                                      "Only Agents can upload profile"))),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 20,
                                            ),
                                          )),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AnimatedBuilder(
                          animation: _animation!,
                          builder: (BuildContext context, Widget? child) {
                            final angle = _animation!.value *
                                3.14159; // Pi radians = 180 degrees
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // perspective
                                ..rotateY(angle),
                              child: _animation!.value < 0.5
                                  ? Card(
                                      child: userInfoWidget(
                                          snapshot, providerLocale))
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(-angle),
                                      child: Card.filled(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: titleText(
                                                  text: "Edit your Profile"),
                                            ),
                                            MyTextFromField(
                                                labelText:
                                                    providerLocale.bodyLblName,
                                                hintText: snapshot.data!.name,
                                                keyboardType:
                                                    TextInputType.name,
                                                textEditingController:
                                                    _txtUpName),
                                            MyTextFromField(
                                                labelText:
                                                    providerLocale.bodyLblEmail,
                                                hintText: snapshot.data!.email,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textEditingController:
                                                    _txtUpEmail,
                                                isReadOnly: true),
                                            MyTextFromField(
                                                labelText:
                                                    providerLocale.bodyLblPhone,
                                                hintText:
                                                    "${snapshot.data!.phone}",
                                                keyboardType:
                                                    TextInputType.phone,
                                                textEditingController:
                                                    _txtUpPhone),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: outLineButton(
                                                    child: buttonText(
                                                        text: providerLocale
                                                            .bodyChangePsd),
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  Column(
                                                                    children: [
                                                                      Divider(
                                                                        indent:
                                                                            divSized,
                                                                        endIndent:
                                                                            divSized,
                                                                        thickness:
                                                                            5,
                                                                      ),
                                                                      titleText(
                                                                          text:
                                                                              providerLocale.bodyChangePsd),
                                                                      TextFieldWidget(
                                                                        preIcon:
                                                                            const Icon(CupertinoIcons.lock),
                                                                        label: providerLocale
                                                                            .bodyLblPsd,
                                                                        hint: providerLocale
                                                                            .bodyHintPsd,
                                                                        controller:
                                                                            _txtNewPass,
                                                                        isPass:
                                                                            true,
                                                                        validation: (value) => checkPass(
                                                                            value,
                                                                            providerLocale),
                                                                        onChange:
                                                                            (value) =>
                                                                                checkPassStatus(),
                                                                      ),
                                                                      TextFieldWidget(
                                                                          preIcon: const Icon(CupertinoIcons
                                                                              .lock),
                                                                          label: providerLocale
                                                                              .bodyLblConfirmPsd,
                                                                          hint: providerLocale
                                                                              .bodyHintConfirmPsd,
                                                                          controller:
                                                                              _txtConPass,
                                                                          isPass:
                                                                              true,
                                                                          validation:
                                                                              (value) {
                                                                            if (value.isEmpty) {
                                                                              return providerLocale.bodyCheckPsd;
                                                                            } else {
                                                                              if (value != _txtNewPass.text && _txtConPass.text.isNotEmpty) {
                                                                                return providerLocale.bodyYourPsdIsNotMatch;
                                                                              }
                                                                            }
                                                                          }),
                                                                      passCheckColor(),
                                                                      materialButton(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .primary,
                                                                          txtColor: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          height: MediaQuery.of(context).size.height *
                                                                              0.04,
                                                                          onPressed:
                                                                              () {
                                                                            if (_txtNewPass.text.isNotEmpty &&
                                                                                _txtConPass.text.isNotEmpty) {
                                                                              AuthServices().fireAuth.currentUser!.updatePassword(_txtConPass.text);
                                                                            } else {
                                                                              Navigator.pop(context);
                                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(providerLocale.bodyHintOldPsd)));
                                                                            }
                                                                          },
                                                                          text:
                                                                              providerLocale.bodyContinue)
                                                                    ],
                                                                  ));
                                                    }),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: materialButton(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    txtColor: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                    onPressed: () =>
                                                        _updateUser(snapshot),
                                                    text: providerLocale
                                                        .bodyUpdate,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: MaterialButton(
                                                    onPressed: () => _flip(),
                                                    child: buttonText(
                                                        text: providerLocale
                                                            .bodyCancel),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: bodyText(text: providerLocale.bodyNoData),
                  );
                }
              },
            ),
            _animation!.value < 0.5
                ? Settings(providerLocale: providerLocale)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget rowList(title, value) {
    return Row(
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("$value"),
      ],
    );
  }

  Widget userInfoWidget(snapshot, providerLocale) {
    final provider =
        Provider.of<AppLocalizationsNotifier>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userProfileRow(
                customText(
                    text: "${providerLocale.bodyLblName}:",
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w300),
                bodyText(text: snapshot.data!.name),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              userProfileRow(
                  customText(
                      text: "${providerLocale.bodyLblEmail}:",
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w300),
                  bodyText(text: snapshot.data!.email)),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              userProfileRow(
                  customText(
                      text: "${providerLocale.bodyLblPhone}:",
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w300),
                  bodyText(
                      text: snapshot.data!.phone != null
                          ? snapshot.data!.phone.toString()
                          : "not provided")),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              userProfileRow(
                  customText(
                      text: "User ID:",
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w300),
                  bodyText(text: snapshot.data!.uid)),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              userProfileRow(
                  customText(
                      text: "${providerLocale.bodysubscribed}: ",
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w300),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: subChecker(
                          snapSubName: snapshot.data!.subscription?.subname,
                          snapSubActive:
                              snapshot.data!.subscription?.subscribe))
                  /*bodyText(
                    text: snapshot.data!.subscribed != null
                        ? snapshot.data!.subscribed!
                        : "false"),*/
                  ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
            ],
          ),
          Positioned.directional(
            textDirection: providerLocale.language == "العربية"
                ? TextDirection.ltr
                : TextDirection.rtl,
            bottom: 0,
            start: 0,
            child: GestureDetector(
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            titleText(text: providerLocale.bodyDeleteAccount),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bodyText(
                                text:
                                    "${providerLocale.bodyDeleteNote} ${snapshot.data!.name}"),
                            customText(
                                text: providerLocale.bodyDeleteRem,
                                color: Colors.red)
                          ],
                        ),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                      onTap: () {
                                        AuthServices()
                                            .deleteUser()
                                            .whenComplete(() {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: customText(
                                          text:
                                              providerLocale.bodyDeleteAccount,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error))),
                              Expanded(
                                  flex: 2,
                                  child: materialButton(
                                      onPressed: () => Navigator.pop(context),
                                      text: providerLocale.bodyCancel)),
                            ],
                          )
                        ],
                      );
                    }),
                child: customText(
                    text: providerLocale.bodyDeleteAccount,
                    color: Theme.of(context).colorScheme.outline)),
          ),
          Positioned.directional(
              textDirection: provider.localizations.language == "العربية"
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              top: 0,
              start: 0,
              child:
                  IconButton(onPressed: _flip, icon: const Icon(Icons.edit))),
        ],
      ),
    );
  }

  Future showProfile(snapshot) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                          imageUrl: snapshot.data?.profile ?? constProfile))),
            ));
  }

  userProfileRow(title, body) {
    return Row(
      children: [
        title,
        SizedBox(
          width: MediaQuery.of(context).size.height * 0.005,
        ),
        body
      ],
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
