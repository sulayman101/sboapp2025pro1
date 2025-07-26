import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/top_banner_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

class NotifyList extends StatefulWidget {
  const NotifyList({super.key});

  @override
  State<NotifyList> createState() => _NotifyListState();
}

class _NotifyListState extends State<NotifyList> {
  final _txtTitle = TextEditingController();
  final _txtLink = TextEditingController();
  bool status = true;
  bool _uploading = false;

  double _uploadImgProgress = 0.0;
  Widget? previewFile;

  CroppedFile? _croppedImage;
  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Crop the selected image
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(
              ratioX: 2.9, ratioY: 1.1), // Set the desired aspect ratio
          compressQuality: 100, // Adjust the compress quality as needed
          maxHeight: 767, // Adjust the maximum height of the cropped image
          maxWidth: 1536, // Adjust the maximum width of the cropped image
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: "providerLocale.appBarCropImg",
                toolbarColor: Theme.of(context).colorScheme.primary,
                toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
                activeControlsWidgetColor:
                    Theme.of(context).colorScheme.primary,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true),
          ]);

      // Update the UI with the cropped image
      if (croppedImage != null) {
        setState(() {
          _croppedImage = croppedImage;
        });
      }
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    // Ensure the file exists before uploading
    if (!imageFile.existsSync()) {
      log("File does not exist: ${imageFile.path}");
      return null;
    }

    try {
      // Create a reference to Firebase Storage
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('Topbanner/')
          .child(DateTime.now().toString());

      // Start the upload task
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      // Track the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progressImg =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _uploadImgProgress = progressImg;
        });
        log("Upload progress for Image: $progressImg%");
      });

      // Await the task to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL once upload is complete
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e, stackTrace) {
      log("Failed to generate thumbnail: $e");
      log("Stack trace: $stackTrace");
    }
    return null;
  }

  void _saveTopBanner() async {
    _uploading = true;
    final String? imageDownloadUrl =
        await uploadImageToStorage(File(_croppedImage!.path));

    if (_txtTitle.value.text.isNotEmpty) {
      Provider.of<GetDatabase>(context, listen: false).addNewBanner(
          title: _txtTitle.text,
          imgLink: imageDownloadUrl!,
          actionLink: _txtLink.text,
          status: status);
      Navigator.pop(context);
    }
  }

  _openBottomSheet() {
    return showDialog(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () => Navigator.pop(context),
            builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleText(text: "Add New Header"),
                    MyTextFromField(
                      labelText: "Title",
                      hintText: "Enter title",
                      textEditingController: _txtTitle,
                      maxLength: 30,
                    ),
                    MyTextFromField(
                      labelText: "body",
                      hintText: "Enter body",
                      textEditingController: _txtLink,
                    ),
                    SwitchListTile(
                        title: lTitleText(text: "Status"),
                        value: status,
                        onChanged: _uploading
                            ? null
                            : (value) => setState(() {
                                  status = value;
                                })),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 3.1,
                        child: InkWell(
                          onTap: () => _pickAndCropImage(),
                          child: _croppedImage != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.file(
                                            File(_croppedImage!.path))),
                                    _uploadImgProgress > 0.0
                                        ? _uploadImgProgress >= 100.0
                                            ? const Icon(Icons.check_circle)
                                            : SizedBox(
                                                child: CircularProgressIndicator(
                                                    value: _uploadImgProgress
                                                            .roundToDouble() /
                                                        100),
                                              )
                                        : const SizedBox.shrink(),
                                    _uploadImgProgress > 0.0
                                        ? _uploadImgProgress >= 100.0
                                            ? const SizedBox.shrink()
                                            : Align(
                                                alignment: Alignment.center,
                                                child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Colors.black54,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0),
                                                      child: Text(
                                                          "${_uploadImgProgress.toInt()}%"),
                                                    )))
                                        : const SizedBox.shrink(),
                                  ],
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: kDefaultFontSize * 4,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    materialButton(
                        text: "Publish",
                        color: Theme.of(context).colorScheme.primary,
                        txtColor: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _uploading ? null : _saveTopBanner),
                  ],
                )));
  }

  static const menuItems = <String>[
    'Update',
    'Hide',
    'Delete',
  ];
  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(providerLocale.appBarManageHeader),
        actions: [
          IconButton(onPressed: _openBottomSheet, icon: const Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<List<TopBannerModel>>(
        stream: GetDatabase().getBanners(),
        builder: (BuildContext context,
            AsyncSnapshot<List<TopBannerModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const ListBannerShimmer();
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No: $index Image Clicked"))),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: ImageNetCache(
                            imageUrl: snapshot.data![index].imgLink,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: PopupMenuButton<String>(
                            onSelected: (String newValue) {
                              switch (newValue) {
                                case "Delete":
                                  Provider.of<GetDatabase>(context,
                                          listen: false)
                                      .deleteBanner(
                                          snapshot.data![index].title);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(newValue),
                                    ),
                                  );
                                default:
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(newValue)));
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                _popUpMenuItems,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors
                                        .transparent, // Transparent at the top
                                    Theme.of(context)
                                        .colorScheme
                                        .surface, // Change this color to your desired bottom color
                                  ],
                                  stops: const [
                                    0.0,
                                    0.5
                                  ], // 0.5 represents the bottom 50%
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: titleText(
                                    text: snapshot.data![index].title,
                                    fontSize: 18),
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No data"),
            );
          }
        },
      ),
    );
  }
}
