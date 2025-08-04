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

  const PayBook({
    super.key,
    required this.bookTitle,
    required this.bookId,
    required this.bookPrice,
  });

  @override
  State<PayBook> createState() => _PayBookState();
}

class _PayBookState extends State<PayBook> {
  int _processStep = 0;
  String? _selectedTelecom;
  String _accountNumber = '';
  final List<Map<String, String>> _telecomOptions = [
    {'Golis': '883'},
    {'Hormuud': '779'},
    {'Telesom': '880'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAccountNumber();
  }

  Future<void> _fetchAccountNumber() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child("SBO/Fees").get();
    if (snapshot.value != null) {
      final fees = snapshot.value as Map;
      setState(() {
        _accountNumber = fees['acc'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBar(title: const Text("Pay Book")),
      body: Column(
        children: [
          _buildBookInfo(),
          const SizedBox(height: 16),
          if (_processStep == 0) _buildStartProcessButton(),
          if (_processStep == 1) _buildTelecomSelection(),
          if (_processStep == 2) _buildContactSupport(),
        ],
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Name", widget.bookTitle),
              _buildInfoRow("Book ID", widget.bookId),
              Text("Price: ${widget.bookPrice}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: bodyText(text: "$label: $value")),
        GestureDetector(
          onTap: () => _copyToClipboard(value),
          child: Text(
            "Copy",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStartProcessButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: materialButton(
        onPressed: () => setState(() => _processStep = 1),
        text: "Start Process",
      ),
    );
  }

  Widget _buildTelecomSelection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTelecom,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: "Telecom Name",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
              ),
              hint: const Text("Select Telecom Name"),
              onChanged: (value) => setState(() => _selectedTelecom = value),
              items: _telecomOptions.map((entry) {
                final key = entry.keys.first;
                final value = entry.values.first;
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(key),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            materialButton(
              onPressed: _selectedTelecom == null ? null : _sendPayment,
              text: "Next",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    return Column(
      children: [
        const Text("Contact Us"),
        ListTile(
          onTap: _openWhatsApp,
          leading: const Icon(Icons.quick_contacts_mail),
          title: const Text("WhatsApp", style: TextStyle(color: Colors.blue)),
          subtitle: const Text("Send us your payment details"),
          trailing: IconButton(
            onPressed: () => setState(() => _processStep = 1),
            icon: const Icon(Icons.undo),
          ),
        ),
      ],
    );
  }

  Future<void> _sendPayment() async {
    final ussdCode = "*$_selectedTelecom*$_accountNumber*${widget.bookPrice}#";
    final Uri launchUri = Uri(scheme: 'tel', path: ussdCode);
    await launchUrl(launchUri);
    setState(() => _processStep = 2);
  }

  Future<void> _openWhatsApp() async {
    final message =
        "I have bought the book: ${widget.bookTitle} (ID: ${widget.bookId}). Please confirm and check!";
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse("https://wa.me/252702032244?text=$encodedMessage");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$text copied to clipboard")),
    );
  }
}
