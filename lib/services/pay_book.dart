import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class PayBook extends StatefulWidget {
  final String bookTitle;
  final String bookId;
  final int bookPrice;
  const PayBook(
      {super.key,
      required this.bookTitle,
      required this.bookId,
      required this.bookPrice});

  @override
  State<PayBook> createState() => _PayBookState();
}

class _PayBookState extends State<PayBook> {
  // ignore: unused_field
  final _phone = TextEditingController();
  int isProcessing = 0;
  String? selected;

  List<Map<String, String>> ussIdCode = [
    {'Golis': '883'},
    {'Hormuud': '779'},
    {'Telesom': '880'},
  ];

  String acc = '';
  void _getPrice() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    dbRef.child("SBO/Fees").onValue.listen((event) {
      final fees = event.snapshot.value as Map;
      acc = fees['acc'].toString();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _getPrice();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBar(
        title: const Text("pay Book"),
      ),
      body: Column(
        children: [
          titleText(text: "Book Price Info", fontSize: 20),
          customText(text: "* this Works only for Somalia", color: Colors.red),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 5,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: bodyText(
                                          text: "Name: ${widget.bookTitle}")),
                                  GestureDetector(
                                      onTap: () => copyInfo(widget.bookTitle),
                                      child: Text(
                                        "Copy",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: bodyText(
                                          text: "Book Id: ${widget.bookId}")),
                                  GestureDetector(
                                    onTap: () => copyInfo(widget.bookId),
                                    child: Text("Copy",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                  )
                                ],
                              ),
                              Text("Price: ${widget.bookPrice}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isProcessing == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: materialButton(
                            onPressed: () => setState(() => isProcessing = 1),
                            text: "Start Process"),
                      ),
                    if (isProcessing == 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: materialButton(
                            onPressed: () {
                              setState(() => isProcessing = 0);
                            },
                            text: "Cancel"),
                      ),
                    if (isProcessing == 2) const Text("Contact Us"),
                    if (isProcessing == 2)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                            onPressed: () {},
                            child: ListTile(
                              onTap: () => openWhatsApp(),
                              leading: const Icon(Icons.quick_contacts_mail),
                              title: const Text(
                                "whatsApp",
                                style: TextStyle(color: Colors.blue),
                              ),
                              subtitle: const Text("send Us Your"),
                              trailing: IconButton(
                                  onPressed: () =>
                                      setState(() => isProcessing = 1),
                                  icon: const Icon(Icons.undo)),
                            )),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          isProcessing == 1 ? Expanded(child: _processing()) : Container(),
        ],
      ),
    );
  }

  Widget _processing() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField(
              value: selected,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: "Telecom Name",
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
              ),
              hint: const Text("Select Telecome Name"),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => selected = newValue);
                }
              },
              items: ussIdCode
                  .map<DropdownMenuItem<String>>((Map<String, String> entry) {
                String key = entry.keys.first;
                String value = entry.values.first;
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(key),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            //MyTextFromField(labelText: "Phone Number", hintText: "Enter your phone number", textEditingController: _phone),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selected == null ? null : sendMoney,
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMoney() async {
    String phone = "*$selected*$acc*${widget.bookPrice}#";
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    await launchUrl(launchUri);
    setState(() => isProcessing = 2);
  }

  Future<void> openWhatsApp() async {
    String text =
        "I have bought book: ${widget.bookTitle} ID: ${widget.bookId} please confirm and check!";
    final info = Uri.encodeComponent(text);
    String link = "https://wa.me/252702032244?text=$info";
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void copyInfo(textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy));
  }
}
