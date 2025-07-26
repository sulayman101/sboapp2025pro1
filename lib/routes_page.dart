import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sboapp/auth/verify_email.dart';
import 'package:sboapp/components/loading_widget.dart';
import 'package:sboapp/notifies/man_banner_list.dart';
import 'package:sboapp/notifies/notify_page.dart';
import 'package:sboapp/notifies/notify_settings.dart';
import 'package:sboapp/notifies/push_notifications.dart';
import 'package:sboapp/quiz_game/quiz.dart';
import 'package:sboapp/screens/books/add_book.dart';
import 'package:sboapp/screens/books/add_category.dart';
import 'package:sboapp/screens/books/book_settings.dart';
import 'package:sboapp/screens/books/books_page.dart';
import 'package:sboapp/screens/books/fav_paid_page.dart';
import 'package:sboapp/screens/books/offline_books.dart';
import 'package:sboapp/screens/books/request_book.dart';
import 'package:sboapp/screens/books/manage_all_books.dart';
import 'package:sboapp/screens/books/update_book.dart';
import 'package:sboapp/screens/presentation/home_page.dart';
import 'package:sboapp/screens/settings/about_us.dart';
import 'package:sboapp/screens/settings/report_screen.dart';
import 'package:sboapp/screens/users/user_profile.dart';
import 'package:sboapp/screens/users/users_page.dart';
import 'package:sboapp/screens/win_gift/win_gift.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/themes/theme_provider.dart';
import 'package:sboapp/welcome_screen/land_page.dart';
import 'package:sboapp/welcome_screen/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Provider.of<ThemeProvider>(context, listen: true);
    final proLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true);
    proLocale.getLocale();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(useMaterial3: true, colorScheme: colorScheme.getLightTheme),
      darkTheme:
          ThemeData(useMaterial3: true, colorScheme: colorScheme.getDarkTheme),
      themeMode: colorScheme.getMode,
      //debugShowCheckedModeBanner: false,

      /*localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],*/
      navigatorKey: navigatorKey,
      locale: proLocale.selectedLocal,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      //home: OnboardingView(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/addBook': (context) => const AddBook(),
        '/editBook': (context) => const UpdateBook(),
        '/addCate': (context) => const AddCategory(),
        '/manAllBooks': (context) => const MangeAllBooks(),
        '/favBook': (context) => const FavoritePage(),
        '/book': (context) => const BookSettings(),
        '/profile': (context) => const ProfilePage(),
        '/users': (context) => const UsersPage(),
        '/winGift': (context) => const WinGift(),
        '/notify': (context) => const NotifySettings(),
        '/addNotify': (context) => const AddNotify(),
        '/manNotify': (context) => const NotifyList(),
        '/reqUpBook': (context) => const RequestUpload(),
        '/notifyList': (context) => const NotifyPage(),
        '/booksPage': (context) => const BooksPage(),
        '/help': (context) => const SupportUsers(),
        '/offline': (context) => const OfflineBooks(),
        '/aboutUs': (context) => const AboutUs(),
        '/game': (context) => const MemoryGame(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthServices>(context);

    showAlert() {
      bannedAlert(context: context);
    }

    void checkUser() async {
      var isBanned =
          Provider.of<GetDatabase>(context, listen: false).checkUser();
      if (await isBanned) {
        showAlert();
        /*Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) => BannedUser(roleAction: roleAction)));*/
      }
    }

    // Check for guest view
    if (auth.isGuest) {
      return const HomePage();
    }

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          checkUser();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return Consumer<AuthServices>(
              builder:
                  (BuildContext context, AuthServices value, Widget? child) {
                final provider = context.watch<AuthServices>();
                provider.saveDeviceId();
                if (provider.fireAuth.currentUser!.emailVerified) {
                  Provider.of<AuthServices>(context, listen: false).getVerify();
                  return const HomePage();
                } else {
                  return const VerifyAccount();
                }
              },
            );
          } else {
            return const OnboardingView();
          }
        });
  }
}
