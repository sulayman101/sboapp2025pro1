
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/text_field_widget.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/check_subs.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
import 'package:sboapp/screens/Settings/settings_page.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {

  // Text controllers
  final _txtUpName = TextEditingController();
  final _txtUpPhone = TextEditingController();
  final _txtUpEmail = TextEditingController();
  final _txtNewPass = TextEditingController();
  final _txtConPass = TextEditingController();

  // Animation controller
  late AnimationController _controller;
  Animation<double>? _animation;

  // Stream subscription to prevent memory leaks
  StreamSubscription<UserModel?>? _userStreamSubscription;

  // Database instance - reuse instead of creating new instances
  late GetDatabase _database;

  // Flag to prevent multiple simultaneous updates
  bool _isUpdating = false;

  String? colorStatus;
  static const String defaultProfileImage =
      "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FuserProfile%5B1%5D.png?alt=media&token=234392a7-3cf7-47cd-a8ee-f375944718c1";

  @override
  void initState() {
    super.initState();

    // Initialize database instance once
    _database = GetDatabase();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers and subscriptions to prevent memory leaks
    _txtUpName.dispose();
    _txtUpPhone.dispose();
    _txtUpEmail.dispose();
    _txtNewPass.dispose();
    _txtConPass.dispose();

    _controller.dispose();

    // Cancel stream subscription if it exists
    _userStreamSubscription?.cancel();

    super.dispose();
  }

  void _flipCard() {
    if (!mounted) return; // Check if widget is still mounted

    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Future<void> _updateUser(UserModel user) async {
    if (_isUpdating) return; // Prevent multiple simultaneous updates

    if (_txtUpName.text.trim().isEmpty && _txtUpPhone.text.trim().isEmpty) {
      _flipCard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nothing Updated")),
        );
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _database.updateMyUser(
        fullName: _txtUpName.text.trim(),
        phone: _txtUpPhone.text.trim(),
      );

      if (mounted) {
        _flipCard();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale = context.watch<AppLocalizationsNotifier>().localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarProfile),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserProfile(providerLocale),
            AnimatedBuilder(
              animation: _animation!,
              builder: (context, child) {
                return _animation!.value < 0.5
                    ? Settings(providerLocale: providerLocale)
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(dynamic providerLocale) {
    return StreamBuilder<UserModel?>(
      stream: _database.getMyUser(),
      builder: (context, snapshot) {
        // Handle different connection states properly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ProfileShimmer(isBannerProfile: false);
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                bodyText(text: "Error loading profile: ${snapshot.error}"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {}); // Trigger rebuild
                    }
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          _initializeTextFields(user);
          return _buildProfileContent(user, providerLocale);
        }

        // Handle case where user is not authenticated (guest user)
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 48),
              const SizedBox(height: 16),
              bodyText(text: providerLocale.bodyNoData ?? "No profile data available"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login or show login dialog
                  // You can implement your login navigation here
                },
                child: const Text("Login Required"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initializeTextFields(UserModel user) {
    // Only initialize if controllers are empty to prevent overwriting user input
    if (_txtUpName.text.isEmpty) {
      _txtUpName.text = user.name ?? '';
    }
    if (_txtUpPhone.text.isEmpty) {
      _txtUpPhone.text = user.phone?.toString() ?? '';
    }
    if (_txtUpEmail.text.isEmpty) {
      _txtUpEmail.text = user.email ?? '';
    }
  }

  Widget _buildProfileContent(UserModel user, dynamic providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildProfilePicture(user),
          const SizedBox(height: 10),
          _buildAnimatedCard(user, providerLocale),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(UserModel user) {
    return GestureDetector(
      onTap: () => _showProfileImage(user.profile),
      child: Hero(
        tag: 'profile_image', // Add Hero animation for better UX
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.profile ?? defaultProfileImage,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(UserModel user, dynamic providerLocale) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        final angle = _animation!.value * 3.14159;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: _animation!.value < 0.5
              ? _buildUserInfoCard(user, providerLocale)
              : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: _buildEditProfileCard(user, providerLocale),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(UserModel user, dynamic providerLocale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleText(text: "Profile Information"),
                IconButton(
                  onPressed: _flipCard,
                  icon: const Icon(Icons.edit),
                  tooltip: "Edit Profile",
                ),
              ],
            ),
            const Divider(),
            _buildUserInfoRow(providerLocale.bodyLblName, user.name ?? 'N/A'),
            _buildUserInfoRow(providerLocale.bodyLblEmail, user.email ?? 'N/A'),
            _buildUserInfoRow(
              providerLocale.bodyLblPhone,
              user.phone?.toString() ?? "Not provided",
            ),
            _buildUserInfoRow("User ID", user.uid ?? 'N/A'),
            _buildUserInfoRow(
              providerLocale.bodysubscribed,
              subChecker(
                snapSubName: user.subscription?.subname,
                snapSubActive: user.subscription?.subscribe,
              ),
            ),
            const Divider(),
            _buildDeleteAccountButton(providerLocale, user),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: customText(
              text: "$label:",
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: value is Widget
                ? value
                : bodyText(text: value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(dynamic providerLocale, UserModel user) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(providerLocale, user),
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        label: customText(
          text: providerLocale.bodyDeleteAccount,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildEditProfileCard(UserModel user, dynamic providerLocale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleText(text: "Edit Profile"),
                IconButton(
                  onPressed: _flipCard,
                  icon: const Icon(Icons.close),
                  tooltip: "Cancel",
                ),
              ],
            ),
            const Divider(),
            MyTextFromField(
              labelText: providerLocale.bodyLblName,
              hintText: user.name ?? '',
              textEditingController: _txtUpName,
              enabled: !_isUpdating,
            ),
            MyTextFromField(
              labelText: providerLocale.bodyLblEmail,
              hintText: user.email ?? '',
              textEditingController: _txtUpEmail,
              isReadOnly: true,
            ),
            MyTextFromField(
              labelText: providerLocale.bodyLblPhone,
              hintText: user.phone?.toString() ?? '',
              textEditingController: _txtUpPhone,
              enabled: !_isUpdating,
            ),
            const SizedBox(height: 16),
            _buildEditProfileActions(user, providerLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileActions(UserModel user, dynamic providerLocale) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : () => _updateUser(user),
            child: _isUpdating
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text("Updating..."),
              ],
            )
                : buttonText(text: providerLocale.bodyUpdate),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: _isUpdating ? null : _flipCard,
          child: buttonText(text: providerLocale.bodyCancel),
        ),
      ],
    );
  }

  Future<void> _showProfileImage(String? profileUrl) async {
    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'profile_image',
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: profileUrl ?? defaultProfileImage,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error_outline, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
      dynamic providerLocale, UserModel user) async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            titleText(text: providerLocale.bodyDeleteAccount),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bodyText(
              text: "${providerLocale.bodyDeleteNote} ${user.name ?? 'User'}",
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: customText(
                text: providerLocale.bodyDeleteRem,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: buttonText(text: providerLocale.bodyCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthServices().deleteUser();
                if (mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Delete failed: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: customText(
              text: providerLocale.bodyDeleteAccount,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sboapp/app_model/user_model.dart';
// import 'package:sboapp/components/ads_and_net.dart';
// import 'package:sboapp/components/text_field_widget.dart';
// import 'package:sboapp/constants/button_style.dart';
// import 'package:sboapp/constants/check_subs.dart';
// import 'package:sboapp/constants/text_form_field.dart';
// import 'package:sboapp/constants/text_style.dart';
// import 'package:sboapp/constants/shimmer_widgets/home_shimmer.dart';
// import 'package:sboapp/screens/Settings/settings_page.dart';
// import 'package:sboapp/services/auth_services.dart';
// import 'package:sboapp/services/get_database.dart';
// import 'package:sboapp/services/lan_services/language_provider.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   final _txtUpName = TextEditingController();
//   final _txtUpPhone = TextEditingController();
//   final _txtUpEmail = TextEditingController();
//   final _txtNewPass = TextEditingController();
//   final _txtConPass = TextEditingController();
//
//   late AnimationController _controller;
//   Animation<double>? _animation;
//
//   String? colorStatus;
//   static const String defaultProfileImage =
//       "https://firebasestorage.googleapis.com/v0/b/sboapp-2a2be.appspot.com/o/profile_images%2FuserProfile%5B1%5D.png?alt=media&token=234392a7-3cf7-47cd-a8ee-f375944718c1";
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _flipCard() {
//     if (_controller.isCompleted) {
//       _controller.reverse();
//     } else {
//       _controller.forward();
//     }
//   }
//
//   void _updateUser(UserModel user) {
//     if (_txtUpName.text.isEmpty && _txtUpPhone.text.isEmpty) {
//       _flipCard();
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Nothing Updated")));
//     } else {
//       GetDatabase().updateMyUser(
//         fullName: _txtUpName.text.trim(),
//         phone: _txtUpPhone.text.trim(),
//       );
//       _flipCard();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final providerLocale =
//         Provider.of<AppLocalizationsNotifier>(context, listen: true)
//             .localizations;
//
//     return ScaffoldWidget(
//       appBar: AppBar(
//         title: appBarText(text: providerLocale.appBarProfile),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildUserProfile(providerLocale),
//             _animation!.value < 0.5
//                 ? Settings(providerLocale: providerLocale)
//                 : const SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserProfile(dynamic providerLocale) {
//     return StreamBuilder<UserModel?>(
//       stream: GetDatabase().getMyUser(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting &&
//             !snapshot.hasData) {
//           return const ProfileShimmer(isBannerProfile: false);
//         }
//         if (snapshot.hasData) {
//           final user = snapshot.data!;
//           _initializeTextFields(user);
//           return _buildProfileContent(user, providerLocale);
//         }
//         return Center(child: bodyText(text: providerLocale.bodyNoData));
//       },
//     );
//   }
//
//   void _initializeTextFields(UserModel user) {
//     if (_txtUpName.text.isEmpty) _txtUpName.text = user.name;
//     if (_txtUpPhone.text.isEmpty) _txtUpPhone.text = user.phone.toString();
//     if (_txtUpEmail.text.isEmpty) _txtUpEmail.text = user.email;
//   }
//
//   Widget _buildProfileContent(UserModel user, dynamic providerLocale) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           _buildProfilePicture(user),
//           const SizedBox(height: 10),
//           _buildAnimatedCard(user, providerLocale),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfilePicture(UserModel user) {
//     return GestureDetector(
//       onTap: () => _showProfileImage(user.profile),
//       child: CircleAvatar(
//         radius: 50,
//         backgroundImage: CachedNetworkImageProvider(
//           user.profile ?? defaultProfileImage,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedCard(UserModel user, dynamic providerLocale) {
//     return AnimatedBuilder(
//       animation: _animation!,
//       builder: (context, child) {
//         final angle = _animation!.value * 3.14159;
//         return Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, 0.001)
//             ..rotateY(angle),
//           child: _animation!.value < 0.5
//               ? _buildUserInfoCard(user, providerLocale)
//               : _buildEditProfileCard(user, providerLocale),
//         );
//       },
//     );
//   }
//
//   Widget _buildUserInfoCard(UserModel user, dynamic providerLocale) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildUserInfoRow(providerLocale.bodyLblName, user.name),
//             _buildUserInfoRow(providerLocale.bodyLblEmail, user.email),
//             _buildUserInfoRow(providerLocale.bodyLblPhone,
//                 user.phone?.toString() ?? "Not provided"),
//             _buildUserInfoRow("User ID", user.uid),
//             _buildUserInfoRow(
//               providerLocale.bodysubscribed,
//               subChecker(
//                 snapSubName: user.subscription?.subname,
//                 snapSubActive: user.subscription?.subscribe,
//               ),
//             ),
//             _buildDeleteAccountButton(providerLocale, user),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserInfoRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           customText(
//             text: "$label:",
//             fontWeight: FontWeight.bold,
//           ),
//           const SizedBox(width: 8),
//           value is Widget ? value : bodyText(text: value.toString()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeleteAccountButton(dynamic providerLocale, UserModel user) {
//     return GestureDetector(
//       onTap: () => _showDeleteAccountDialog(providerLocale, user),
//       child: customText(
//         text: providerLocale.bodyDeleteAccount,
//         color: Theme.of(context).colorScheme.error,
//       ),
//     );
//   }
//
//   Widget _buildEditProfileCard(UserModel user, dynamic providerLocale) {
//     return Card(
//       child: Column(
//         children: [
//           titleText(text: "Edit your Profile"),
//           MyTextFromField(
//             labelText: providerLocale.bodyLblName,
//             hintText: user.name,
//             textEditingController: _txtUpName,
//           ),
//           MyTextFromField(
//             labelText: providerLocale.bodyLblEmail,
//             hintText: user.email,
//             textEditingController: _txtUpEmail,
//             isReadOnly: true,
//           ),
//           MyTextFromField(
//             labelText: providerLocale.bodyLblPhone,
//             hintText: user.phone.toString(),
//             textEditingController: _txtUpPhone,
//           ),
//           _buildEditProfileActions(user, providerLocale),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEditProfileActions(UserModel user, dynamic providerLocale) {
//     return Row(
//       children: [
//         Expanded(
//           child: materialButton(
//             text: providerLocale.bodyUpdate,
//             onPressed: () => _updateUser(user),
//           ),
//         ),
//         MaterialButton(
//           onPressed: _flipCard,
//           child: buttonText(text: providerLocale.bodyCancel),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _showProfileImage(String? profileUrl) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: CachedNetworkImage(
//           imageUrl: profileUrl ?? defaultProfileImage,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showDeleteAccountDialog(
//       dynamic providerLocale, UserModel user) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: titleText(text: providerLocale.bodyDeleteAccount),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             bodyText(
//               text: "${providerLocale.bodyDeleteNote} ${user.name}",
//             ),
//             customText(
//               text: providerLocale.bodyDeleteRem,
//               color: Colors.red,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               AuthServices().deleteUser().then((_) {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               });
//             },
//             child: customText(
//               text: providerLocale.bodyDeleteAccount,
//               color: Theme.of(context).colorScheme.error,
//             ),
//           ),
//           materialButton(
//             text: providerLocale.bodyCancel,
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
// }
