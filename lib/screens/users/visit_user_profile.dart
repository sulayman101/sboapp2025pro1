import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/dropdown_widget.dart';
import 'package:sboapp/constants/book_card.dart';
import 'package:sboapp/constants/check_subs.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/services/book_searching.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

class UserProfileBooks extends StatefulWidget {
  final String uid;
  const UserProfileBooks({super.key, required this.uid});

  @override
  State<UserProfileBooks> createState() => _UserProfileBooksState();
}

class _UserProfileBooksState extends State<UserProfileBooks> {
  List<BookModel> searchBooks = [];
  int checked = 0;
  int checkedLan = 0;
  final ScrollController _scrollController = ScrollController();
  String? category;
  bool visible = false;
  bool isDone = false;

  static const String constProfile =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FwoOUuLKoJbdlZSxyaVFNQYPl7fX2?alt=media&token=082a9782-5a9f-4be9-9591-3175d104cbe3";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDatabase>(context, listen: true);
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return StreamBuilder<UserModel?>(
      stream: provider.userProfile(uid: widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SafeArea(
            child: ScaffoldWidget(
              body: Column(
                children: [
                  ProfileShimmer(isBannerProfile: false),
                  Expanded(child: BookShimmer(indexLength: 10)),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          isDone = true;
          return _buildUserProfile(snapshot.data!, providerLocale, provider);
        }
        return const Center(
            child: Text("This User is not found or restricted"));
      },
    );
  }

  Widget _buildUserProfile(
      UserModel user, dynamic providerLocale, GetDatabase provider) {
    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (visible)
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(listOfBooks: searchBooks),
                );
              },
              icon: const Icon(Icons.search),
            ),
        ],
      ),
      body: Column(
        children: [
          Card.filled(child: _buildUserInfo(user, providerLocale)),
          _buildCategoryDropdown(provider, providerLocale),
          if (visible) _buildFilterChips(providerLocale),
          Expanded(child: _buildBooksList(provider)),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UserModel user, dynamic providerLocale) {
    return ListTile(
      leading: ClipOval(
        child: ImageNetCache(imageUrl: user.profile ?? constProfile),
      ),
      title: bodyText(text: user.name),
      subtitle: bodyText(text: user.email),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.1,
        child: subChecker(
          snapSubName: user.subscription?.subname,
          snapSubActive: user.subscription?.subscribe,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(GetDatabase provider, dynamic providerLocale) {
    return StreamBuilder<List<MyCategories>>(
      stream: provider.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const DropShimmer();
        }
        if (snapshot.hasData) {
          return Row(
            children: [
              Expanded(
                child: DropDownWidget(
                  providerLocale: providerLocale,
                  hintText: providerLocale.bodySelectCategory,
                  selectedValue: category,
                  onChange: (value) {
                    setState(() {
                      provider.getBooks(category: value!);
                      category = value;
                    });
                  },
                  items: snapshot.data!,
                ),
              ),
              if (category != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      provider.getAllAgentBooks();
                      category = null;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                ),
            ],
          );
        }
        return Card(child: Text(providerLocale.bodyNotFound));
      },
    );
  }

  Widget _buildFilterChips(dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChoiceChip(
                    label: providerLocale.bodyAll,
                    selected: checkedLan == 0,
                    onSelected: () => setState(() => checkedLan = 0),
                  ),
                  _buildChoiceChip(
                    label: providerLocale.bodySomali,
                    selected: checkedLan == 1,
                    onSelected: () => setState(() => checkedLan = 1),
                  ),
                  _buildChoiceChip(
                    label: providerLocale.bodyArabic,
                    selected: checkedLan == 2,
                    onSelected: () => setState(() => checkedLan = 2),
                  ),
                  _buildChoiceChip(
                    label: providerLocale.bodyEnglish,
                    selected: checkedLan == 3,
                    onSelected: () => setState(() => checkedLan = 3),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => checked = value),
            itemBuilder: (context) => [
              _buildPopupMenuItem(0, providerLocale.bodyAll),
              _buildPopupMenuItem(1, providerLocale.bodyFree),
              _buildPopupMenuItem(2, providerLocale.bodyPaid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(int value, String text) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          if (checked == value)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check),
            ),
          buttonText(text: text),
        ],
      ),
    );
  }

  Widget _buildBooksList(GetDatabase provider) {
    return StreamBuilder<List<BookModel>>(
      stream: category != null
          ? provider.bookController.stream
          : provider.allBookAgentController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          category != null
              ? provider.getBooks(category: category!)
              : provider.getAllAgentBooks();
          return const BookShimmer(indexLength: 10);
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.hasData) {
          visible = true;
          if (searchBooks.isEmpty) {
            searchBooks.addAll(snapshot.data!);
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              if (book.user == widget.uid) {
                return BookCard(
                  bookModel: book,
                  isModify: false,
                  isFree: checked,
                  lang: checkedLan,
                );
              }
              return const SizedBox();
            },
          );
        }
        return const Center(child: Text("No Data"));
      },
    );
  }
}
