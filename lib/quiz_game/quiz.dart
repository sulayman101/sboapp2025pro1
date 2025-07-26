

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Components/ads_and_net.dart';

import '../services/navigate_page_ads.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<Widget> widgetList = <Widget>[];
  List<Key> keyList = <Key>[];
  List<Key?> matchedKeys = <Key?>[];
  String? selectedText;
  Key? selectedKey;

  int numberOfGame = 18;
  int totalItems = 8;
  int numOfRows = 4;

  List<Widget> _createListOfCards() {
    // adding the text that to be shown
    final List<int> textInput = <int>[];

    for (int i = 1; i <= totalItems; i++) {
        textInput.add(i);
        textInput.add(i);
    }

    //Randomly picking up the text and creating the card
    final Random random = Random();
    for (int i = 1; i <= numOfRows; i++) {
      for (int j = 1; j <= numOfRows; j++) {
        final UniqueKey key = UniqueKey();
        keyList.add(key);
        final int inputVal = textInput[random.nextInt(textInput.length)];
        widgetList.add(FlipCard(
          txt: inputVal.toString(),
          key: key,
          onFlipChange: (Key? val, String? txt) {
            if (selectedKey != key) {
              if (selectedText == null) {
                selectedText = txt;
                selectedKey = val;
              } else if (selectedText == txt) {
                matchedKeys.add(val);
                matchedKeys.add(selectedKey);
                selectedText = null;
                selectedKey = null;
                _flipTheOtherOpenCards();
              } else {
                selectedText = null;
                selectedKey = null;
                _flipTheOtherOpenCards();
              }
            } else {
              selectedText = null;
              selectedKey = null;
            }
          },
        ));

        textInput.removeAt(textInput.lastIndexOf(inputVal));
      }
    }

    return widgetList;
  }

  void _flipTheOtherOpenCards() {
    if (matchedKeys.length == numberOfGame) {
      _showSuccessDialog();
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        for (final Widget element in widgetList) {
          if (matchedKeys.contains(element.key)) {
            (element as FlipCard).cardObject!.disableAnimation();
          } else if (selectedKey == element.key) {
          } else {
            (element as FlipCard).cardObject!.flipTheOpenCards();
          }
        }
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Awesome'),
          content: const Text('Completed the game successfully'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Provider.of<NavigatePageAds>(context,
                    listen: false)
                    .createInterstitialAd();
                Future.delayed(const Duration(seconds: 1));
                Provider.of<NavigatePageAds>(context,
                    listen: false)
                    .showInterstitialAd();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lists = _createListOfCards();
    if(lists.length > numberOfGame) {
      lists.clear();
      lists = _createListOfCards();
    }
    return ScaffoldWidget(
        appBar: AppBar(title: const Text("Memory Game"),
          actions: [
            IconButton(onPressed: (){
              showModalBottomSheet(context: context, builder: (context)=> SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Container( height: MediaQuery.of(context).size.height * 0.01, width: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap:(){
                                  _createListOfCards().clear();
                                  setState(() {
                                    numberOfGame = 9;
                                    totalItems = 5;
                                    numOfRows = 3;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_createListOfCards().length}")));
                                  Navigator.pop(context);
                                },
                                child: Card.filled(
                                  color: numberOfGame == 9 ? Theme.of(context).colorScheme.primary : null,
                                  child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("3 : 9", style: TextStyle(color: numberOfGame == 9 ? Theme.of(context).colorScheme.onPrimary : null),),
                                  ),
                                ),),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap:(){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_createListOfCards().length}")));
                                  _createListOfCards().clear();
                                  setState(() {
                                    numberOfGame = 18;
                                    numOfRows = 4;
                                    totalItems = 8;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Card.filled(
                                  color: numberOfGame == 18 ? Theme.of(context).colorScheme.primary : null,
                                  child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("4 : 16",style: TextStyle(color: numberOfGame == 18 ? Theme.of(context).colorScheme.onPrimary : null)),
                                  ),
                                ),),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap:(){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_createListOfCards().length}")));
                                  _createListOfCards().clear();
                                  setState(() {
                                    numberOfGame = 25;
                                    numOfRows = 5;
                                    totalItems = 14;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Card.filled(
                                  color: numberOfGame == 25 ? Theme.of(context).colorScheme.primary : null,
                                  child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("5 : 25", style: TextStyle(color: numberOfGame == 25 ? Theme.of(context).colorScheme.onPrimary : null)),
                                  ),
                                ),),
                              ),
                            ),
                        ],),
                      ),
                    ),
                  ],
                ),
              ));
            }, icon: const Icon(Icons.settings))
          ],
        ),
        body: GridView.count(

            crossAxisCount: numOfRows, children: lists));
  }
}

// ignore: must_be_immutable
class FlipCard extends StatefulWidget {
  final String? txt;
  final Function(Key?, String?)? onFlipChange;

  FlipCard({super.key, this.txt, this.onFlipChange});

  _FlipCardState? cardObject;

  _FlipCardState? getObject() {
    cardObject = _FlipCardState(txt);
    return cardObject;
  }

  @override
  _FlipCardState createState() => getObject()!;
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  final String? txt;
  bool clickDisabled = false;

  _FlipCardState(this.txt);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(end: 0.0, begin: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        _animationStatus = status;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void flipTheOpenCards() {
    if (_animationStatus != AnimationStatus.dismissed) {
      _animationController.reverse();
    }
  }

  void disableAnimation() {
    clickDisabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..rotateY(pi * double.parse(_animation.value.toString())),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (!clickDisabled) {
                if (_animationStatus == AnimationStatus.dismissed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
                widget.onFlipChange!(widget.key, widget.txt);
              }
            },
            child: _animation.value > 0.5
                ? Card(
              elevation: 12,
              shadowColor: Colors.indigoAccent,
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                color: Colors.indigoAccent,
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                  child: Image.asset("assets/images/logo.png", )),
                /*const Icon(
                  Icons.ac_unit_sharp,
                  color: Colors.white70,
                  size: 50,
                ),*/
              ),
            )
                : Card(
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.primaryContainer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                  color: Theme.of(context).colorScheme.primaryFixed,
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.width / 5,
                  child: Center(
                    child: Text(
                      widget.txt!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                          fontSize: 32),
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
