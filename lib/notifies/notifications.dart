import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:url_launcher/url_launcher.dart';

class UsersNotify extends StatefulWidget {
  const UsersNotify({super.key});

  @override
  State<UsersNotify> createState() => _UsersNotifyState();
}

class _UsersNotifyState extends State<UsersNotify> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance.ref("$dbName/Notify").onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final content = snapshot.data!.snapshot.value as Map;
            return content['status'] == true
                ? GestureDetector(
                    onTap: () async {
                      Uri url = Uri.parse(content['link']);
                      if (!await launchUrl(url)) {
                        throw Exception("Couldn't not launch $url");
                      }
                      Uri.parse(content['link']);
                    },
                    child: Column(
                      children: [
                        content['imageLink'] != null
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                    child: Image.network(
                                      content['imageLink'].toString(),
                                      fit: BoxFit.fitWidth,
                                    )))
                            : const SizedBox(),
                        AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              content['content'].toString(),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              //speed: const Duration(milliseconds: 1000),
                            ),
                          ],
                          isRepeatingAnimation: true,
                          //totalRepeatCount: 4,
                          //pause: const Duration(milliseconds: 500),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                      ],
                    ),
                  )
                : Container();
          } else {
            return Container();
          }
        });
  }
}
