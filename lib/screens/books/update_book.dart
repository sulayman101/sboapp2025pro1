import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
//import 'package:file_previewer/file_previewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/dropdown_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/notify_hold_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class UpdateBook extends StatefulWidget {
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookLanguage;
  final String? bookLink;
  final String? bookCover;
  final bool? isTranslated;
  final String? bookCategory;
  final String? bookPrice;
  const UpdateBook(
      {super.key,
      this.bookTitle,
      this.bookAuthor,
      this.bookLanguage,
      this.bookLink,
      this.bookCover,
      this.isTranslated,
      this.bookCategory,
      this.bookPrice});

  @override
  State<UpdateBook> createState() => __UpdateBookStateState();
}

class __UpdateBookStateState extends State<UpdateBook> {
  final txtCrtBName = TextEditingController();
  final txtCrtBAuth = TextEditingController();
  final txtCrtPrice = TextEditingController();
  final txtNewCtgry = TextEditingController();

  bool isFree = false;
  bool _isTranslated = false;
  bool _uploading = false;
  double _uploadImgProgress = 0.0;
  double _uploadPdfProgress = 0.0;

  String? selectedValue;
  String? selectedLang;
  String? bookCover;
  String? bookLink;
  String _status = "Public";
  String? uploadDate;
  String? upBookId;

  File? _pdfFile;
  Widget? previewFile;
  CroppedFile? _croppedImage;

  static const langMenu = <String>['Somali', 'Arabic', 'English'];
  final List<DropdownMenuItem<String>> _langDrop = langMenu
      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
      .toList();

  @override
  void initState() {
    super.initState();
    _fetchBookInfo();
  }

  void _fetchBookInfo() {
    final bookInfo =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (bookInfo != null && txtCrtBName.text.isEmpty) {
      txtCrtBName.text = bookInfo["bookTitle"];
      txtCrtBAuth.text = bookInfo["bookAuthor"];
      txtCrtPrice.text = bookInfo["bookPrice"];
      selectedValue = bookInfo["bookCategory"];
      selectedLang = bookInfo["bookLanguage"];
      _isTranslated = bookInfo["isTranslated"] ?? false;
      bookCover = bookInfo["bookCover"];
      bookLink = bookInfo["bookLink"];
      _status = bookInfo["status"];
      uploadDate = bookInfo["date"];
      upBookId = bookInfo["bookId"];
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarEditBook),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    controller: txtCrtBName,
                    label: providerLocale.bodyLblBook,
                    hint: providerLocale.bodyBookHintBook,
                  ),
                  _buildAuthorField(providerLocale),
                  _buildLanguageDropdown(providerLocale),
                  _buildCategoryRow(providerLocale),
                  _buildPriceSwitch(providerLocale),
                  _buildImageAndPdfUpload(providerLocale),
                  _buildUpdateButton(providerLocale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return MyTextFromField(
      isReadOnly: _uploading,
      textEditingController: controller,
      labelText: label,
      hintText: hint,
    );
  }

  Widget _buildAuthorField(dynamic providerLocale) {
    return MyTextFromField(
      prefixIcon: Checkbox(
        value: _isTranslated,
        onChanged: _uploading
            ? null
            : (value) => setState(() => _isTranslated = !_isTranslated),
      ),
      isReadOnly: _uploading,
      textEditingController: txtCrtBAuth,
      labelText: _isTranslated
          ? providerLocale.bodyTranslated
          : providerLocale.bodyLblBooAuthor,
      hintText: _isTranslated
          ? providerLocale.bodyHintTrans
          : providerLocale.bodyHintBookAuthor,
    );
  }

  Widget _buildLanguageDropdown(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: DropdownButtonFormField<String>(
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          value: selectedLang,
          hint: Text(providerLocale.bodySelectLang),
          onChanged: _uploading
              ? null
              : (value) => setState(() => selectedLang = value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: providerLocale.bodyLblLanguage,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          ),
          items: _langDrop,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(dynamic providerLocale) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<MyCategories>>(
            stream: GetDatabase().getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const DropShimmer();
              }
              if (snapshot.hasData) {
                return DropDownWidget(
                  providerLocale: providerLocale,
                  selectedValue: selectedValue,
                  onChange: (value) {
                    if (!_uploading) {
                      setState(() => selectedValue = value);
                    }
                  },
                  items: snapshot.data!,
                );
              }
              return Center(child: Text(providerLocale.bodyNotFound));
            },
          ),
        ),
        IconButton(
          onPressed: _uploading
              ? null
              : () => _showAddCategoryBottomSheet(providerLocale),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildPriceSwitch(dynamic providerLocale) {
    return Column(
      children: [
        SwitchListTile(
          title:
              Text(isFree ? providerLocale.bodyPaid : providerLocale.bodyFree),
          value: isFree,
          onChanged:
              _uploading ? null : (value) => setState(() => isFree = value),
        ),
        if (isFree)
          _buildTextField(
            controller: txtCrtPrice,
            label: providerLocale.bodyLblBookPrice,
            hint: providerLocale.bodyHintBookPrice,
          ),
      ],
    );
  }

  Widget _buildImageAndPdfUpload(dynamic providerLocale) {
    return Row(
      children: [
        Expanded(child: _buildImageUpload(providerLocale)),
        const SizedBox(width: 10),
        Expanded(child: _buildPdfUpload(providerLocale)),
      ],
    );
  }

  Widget _buildImageUpload(dynamic providerLocale) {
    return GestureDetector(
      onTap: _uploading ? null : () => _pickAndCropImage(providerLocale),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.3,
        child: _croppedImage != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.file(File(_croppedImage!.path)),
                  ),
                  if (_uploadImgProgress > 0.0)
                    CircularProgressIndicator(
                      value: _uploadImgProgress / 100,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(bookCover ?? ""),
              ),
      ),
    );
  }

  Widget _buildPdfUpload(dynamic providerLocale) {
    return GestureDetector(
      onTap: _uploading ? null : _pickPDF,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.3,
        child: _pdfFile != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  if (previewFile != null) previewFile!,
                  if (_uploadPdfProgress > 0.0)
                    CircularProgressIndicator(
                      value: _uploadPdfProgress / 100,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                ],
              )
            : const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 50),
      ),
    );
  }

  Widget _buildUpdateButton(dynamic providerLocale) {
    return Row(
      children: [
        Expanded(
          child: materialButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _uploading ? null : _updateBook,
            text: providerLocale.bodyUpdate,
            height: MediaQuery.of(context).size.height * 0.06,
            fontSize: MediaQuery.of(context).textScaler.scale(20),
            txtColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndCropImage(dynamic providerLocale) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Crop the selected image
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(
              ratioX: 3.0, ratioY: 5.0), // Set the desired aspect ratio
          compressQuality: 100, // Adjust the compress quality as needed
          maxHeight: 512, // Adjust the maximum height of the cropped image
          maxWidth: 512, // Adjust the maximum width of the cropped image
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: providerLocale.appBarCropImg,
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

  // Future<void> _pickPDF() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf'],
  //     );
  //
  //     if (result != null && result.files.isNotEmpty) {
  //       final thumbnail = await FilePreview.getThumbnail(
  //         result.files.first.path!,
  //         width: MediaQuery.of(context).size.width * 0.4,
  //         height: MediaQuery.of(context).size.height * 0.3,
  //       );
  //
  //       setState(() {
  //         previewFile = thumbnail;
  //         _pdfFile = File(result.files.single.path!);
  //       });
  //     } else {
  //       log("No file selected or user canceled file picker.");
  //     }
  //   } catch (e, stackTrace) {
  //     log("Failed to generate thumbnail: $e");
  //     log("Stack trace: $stackTrace");
  //   }
  // }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path!;

        // Create a PDF thumbnail widget instead of using OpenFilex
        final thumbnail = Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: kDefaultFontSize * 3,
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  result.files.first.name,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

        setState(() {
          previewFile = thumbnail;  // Now it's a Widget!
          _pdfFile = File(filePath);
          log("File path for PDF: $filePath");
        });

      } else {
        log("No file selected or user canceled file picker.");
      }
    } catch (e, stackTrace) {
      log("Failed to pick PDF: $e");
      log("Stack trace: $stackTrace");
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    // Ensure the file exists before uploading
    if (!imageFile.existsSync()) {
      log("File does not exist: ${imageFile.path}");
      return null;
    }

    // Check if selectedValue is not null
    if (selectedValue == null) {
      log("Error: selectedValue is null");
      return null;
    }

    try {
      // Create a reference to Firebase Storage
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('coverImages')
          .child(selectedValue!)
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

  Future<String?> uploadPDFToStorage(File pdfFile) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('pdfBooks')
        .child(selectedValue!)
        .child(DateTime.now().toString());
    final UploadTask uploadTask = storageReference.putFile(pdfFile);

    // Track the upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      setState(() {
        _uploadPdfProgress = progress;
      });
      log('Loading $progress');
      //print('Upload progress: $progress%');
    });

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void _updateBook() async {
    try {
      bool isEmpPr = isFree == false && txtCrtPrice.text.isEmpty;
      if (selectedValue == null ||
          txtCrtBName.text.isEmpty ||
          txtCrtBAuth.text.isEmpty ||
          isEmpPr == false) {
        _uploading = false;
        return; // Check if both files are selected
      }

      _uploading = true;
      final String? imageDownloadUrl =
          await uploadImageToStorage(File(_croppedImage!.path));

      final String? pdfDownloadUrl =
          await uploadPDFToStorage(File(_pdfFile!.path));

      final DatabaseReference dbRef = FirebaseDatabase.instance
          .ref()
          .child("$dbName/Books/${selectedValue!}/${upBookId!}");

      final String bookName = txtCrtBName.value.text;
      final String bookAuth = txtCrtBAuth.value.text;
      final String bookPrice = txtCrtPrice.value.text;
      //final String bookPhone =txtCrtPhnNum.value.text;
      final bookGenId = upBookId ??
          const Uuid().v4(); // Use existing ID or generate a new one
      final bookDate = uploadDate;

      final book = BookModel(
              bookId: bookGenId,
              author: bookAuth,
              translated: _isTranslated ? _isTranslated : null,
              book: bookName,
              status: _status,
              category: selectedValue!,
              date: "$bookDate",
              img: imageDownloadUrl ?? bookCover!,
              like: 0,
              link: pdfDownloadUrl ?? bookLink!,
              language: selectedLang!,
              price: isFree ? int.parse(bookPrice) : 0,
              user: AuthServices().fireAuth.currentUser!.uid,
              username:
                  AuthServices().fireAuth.currentUser!.displayName.toString())
          .toJson();
      log(book.toString());

      dbRef.update(book).whenComplete(() => Navigator.pop(context));

      /*NotificationProvider().notifyAllUsers(
          title: bookName,
          body: bookAuth,
          bookLink: bookLink,
          imgLink: bookCover);*/
    } catch (e) {
      log("error");
    }
  }

  void _showAddCategoryBottomSheet(dynamic providerLocale) {
    showBottomSheet(
        context: context,
        builder: (context) => Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Add New Category"),
                    MyTextFromField(
                      isReadOnly: _uploading,
                      textEditingController: txtNewCtgry,
                      labelText: providerLocale.bodyLblBook,
                      hintText: providerLocale.bodyBookHintBook,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: materialButton(
                              onPressed: () {},
                              color: Theme.of(context).colorScheme.primary,
                              txtColor: Theme.of(context).colorScheme.onPrimary,
                              height: MediaQuery.of(context).size.height * 0.05,
                              text: "Add Category"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }
}
