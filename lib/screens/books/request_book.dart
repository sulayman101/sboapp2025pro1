import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/auth/verify_number.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestUpload extends StatefulWidget {
  const RequestUpload({super.key});

  @override
  State<RequestUpload> createState() => _RequestUploadState();
}

class _RequestUploadState extends State<RequestUpload> {
  bool isRequested = false;
  final _ctrUsername = TextEditingController();
  final _ctrEmail = TextEditingController();
  final _ctrPhone = TextEditingController();
  String? _selectedLeader;
  bool _checkAgree = false;
  static final Map<String, String> menuItems = {};
  String? number;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPhoneIfNull();
      _fetchAgents();
    });
  }

  void _fetchAgents() {
    final reference = FirebaseDatabase.instance.ref("SBO/Users");
    reference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final leaders = event.snapshot.value as Map;
        leaders.forEach((key, value) {
          final agent = value as Map<dynamic, dynamic>;
          if (agent['role'].toString() == 'Agent') {
            menuItems[agent['uid'].toString()] = agent['name'].toString();
            setState(() {});
          }
        });
      }
    });
  }

  void _showPhoneIfNull() {
    final userPhone = AuthServices().fireAuth.currentUser?.phoneNumber ?? "";
    if (userPhone.isEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => PopScope(
          canPop: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VerifyNum(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _launchTermsUrl() async {
    final Uri url =
        Uri.parse('https://dallosoftdev.github.io/UploadBooksTerms.html');
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch")),
      );
    }
  }

  Widget _buildDropdown(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          hint: bodyText(text: providerLocale.bodySelectAgentName),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedLeader = newValue);
            }
          },
          items: menuItems.entries
              .map<DropdownMenuItem<String>>(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRequestForm(dynamic providerLocale, UserModel user) {
    _ctrUsername.text = user.name;
    _ctrEmail.text = user.email;
    _ctrPhone.text = user.phone.toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleText(
            text: providerLocale.bodyUploadBWelcomeSBO,
            fontSize: MediaQuery.of(context).textScaler.scale(30),
          ),
          customText(
            text: providerLocale.bodyUploadBRequestNow,
            color: Theme.of(context).colorScheme.primary,
            fontSize: MediaQuery.of(context).textScaler.scale(18),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              "assets/images/bookRequest.png",
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          MyTextFromField(
            labelText: providerLocale.bodyUploadBLblRealName,
            hintText: providerLocale.bodyHintName,
            textEditingController: _ctrUsername,
          ),
          MyTextFromField(
            labelText: providerLocale.bodyUploadBLblContactEmail,
            hintText: providerLocale.bodyUploadBHintContactEmail,
            textEditingController: _ctrEmail,
          ),
          MyTextFromField(
            labelText: providerLocale.bodyUploadBLblContactPhone,
            hintText: providerLocale.bodyUploadBHintContactPhone,
            textEditingController: _ctrPhone,
          ),
          _buildDropdown(providerLocale),
          ListTile(
            leading: Checkbox(
              value: _checkAgree,
              onChanged: (value) => setState(() => _checkAgree = value!),
            ),
            title: GestureDetector(
              onTap: _launchTermsUrl,
              child: Text(
                "Read terms Book Uploader Agreement",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          materialButton(
            onPressed: !_checkAgree || _selectedLeader == null
                ? null
                : () {
                    final name = _ctrUsername.text;
                    final email = _ctrEmail.text;
                    final phone = _ctrPhone.text;
                    final leader = _selectedLeader;

                    if (name.isNotEmpty &&
                        email.isNotEmpty &&
                        phone.isNotEmpty) {
                      Provider.of<GetDatabase>(context, listen: false)
                          .sendRequest(
                        name: name,
                        email: email,
                        phone: phone,
                        ldrName: leader!,
                        selectedAgent: _selectedLeader!,
                        isRequested: isRequested,
                      );
                    }
                  },
            text: providerLocale.bodyUploadBSendRequest,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen(dynamic providerLocale, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Icon(
            Icons.access_time,
            size: MediaQuery.of(context).size.width * 0.3,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text.rich(
              TextSpan(
                text: "${providerLocale.bodyUploadBHello} ${user.name} ",
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  TextSpan(
                    text: providerLocale.bodyUploadBWaitingText,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarRequest),
      ),
      body: Consumer<GetDatabase>(
        builder: (context, provider, child) {
          return StreamBuilder<UserModel?>(
            stream: provider.getMyUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                final user = snapshot.data!;
                return isRequested
                    ? _buildWaitingScreen(providerLocale, user)
                    : _buildRequestForm(providerLocale, user);
              }
              return Center(child: bodyText(text: "Error Occurred"));
            },
          );
        },
      ),
    );
  }
}
