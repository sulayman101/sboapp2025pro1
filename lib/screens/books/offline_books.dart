
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/displayvideo/v2.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/Services/auth_services.dart';
import 'package:sboapp/app_model/offline_books_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/services/offline_books/offline_books_provider.dart';

import '../../Constants/shimmer_widgets/home_shimmer.dart';
import '../../Constants/text_style.dart';
import '../presentation/pdf_reader_page.dart';

class OfflineBooks extends StatefulWidget {
  const OfflineBooks({super.key});

  @override
  State<OfflineBooks> createState() => _OfflineBooksState();
}

class _OfflineBooksState extends State<OfflineBooks> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OfflineBooksProvider>(context);

    return ScaffoldWidget(
      appBar: AppBar(
        title: Text("Offline Books"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: titleText(text: "Clear Notifications"),
                      content: bodyText(
                          text: "Do you went to Clear all Offline Books?"),
                      actions: [
                        TextButton(
                            onPressed: (){
                              provider.deleteAllBook();
                              Navigator.pop(context);
                            },
                            child: const Text("Clear")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"))
                      ],
                    ));
              },
              icon: const Icon(Icons.cleaning_services))
        ],
      ),
      body: provider.offlineBooks.isNotEmpty ? ListView.builder(
              itemCount: provider.offlineBooks.length,
              itemBuilder: (context, index) {
                final List<OfflineBooksModel> offlineBooks = provider.offlineBooks;
                offlineBooks.sort((a, b) => b.bookDate.compareTo(a.bookDate));
                final File imageFile =File(offlineBooks[index].bookImg);
                return Card.filled(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                        child: Image.file(imageFile)),
                    title: lTitleText(text: offlineBooks[index].book),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        lSubTitleText(text: offlineBooks[index].author),
                        bodyText(text: offlineBooks[index].bookLang)
                      ],
                    ),
                    trailing: IconButton(onPressed:(){ showDialog(context: context, builder: (context)=> AlertDialog(title: titleText(
                        text: "Delete"),
                      content: bodyText(text: "Do you went to delete ${offlineBooks[index].book}"),
                      actions: [
                        MaterialButton(
                          color: Theme.of(context).colorScheme.error,
                            onPressed: (){ provider.deleteBook(offlineBooks[index].bookId);
                            Navigator.pop(context);
                            }, child: buttonText(text:"Delete")),
                        TextButton(onPressed: ()=> Navigator.pop(context), child: buttonText(text: "Cancel")),

                      ],
                    ),
                    );}, icon: Icon(Icons.delete)),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReadingPage(
                                bookLink: offlineBooks[index].bookPath,
                                title: offlineBooks[index].book,
                              )));
                    },
                  ),
                );

              },
            ): const Center(child: Text("No Books Offline"),));
  }
}
