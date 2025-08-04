import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/user_model.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/get_database.dart';

import '../../constants/button_style.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedRole;

  static const menuItems = <String>[
    'Admin',
    'User',
    'Banned',
    'Agent',
    'Delete',
  ];

  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map((String value) => PopupMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as List;
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(role[0] == "Agent" ? "Agent Members" : "Users"),
      ),
      body: Column(
        children: [
          _buildTabBar(providerLocale, role),
          Expanded(child: _buildTabView(role)),
        ],
      ),
    );
  }

  Widget _buildTabBar(dynamic providerLocale, List role) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabBar(
        controller: _tabController,
        unselectedLabelColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        tabs: [
          Tab(
              text: role[0] == "Agent"
                  ? providerLocale.bodyActive
                  : providerLocale.bodyAllUsers),
          Tab(
              text: role[0] == "Agent"
                  ? providerLocale.bodyRequests
                  : providerLocale.bodyAllAgents),
          Tab(
              text: role[0] == "Agent"
                  ? providerLocale.bodyRejects
                  : providerLocale.bodyAllAdmins),
        ],
      ),
    );
  }

  Widget _buildTabView(List role) {
    return TabBarView(
      controller: _tabController,
      children: [
        role[0] == "Agent"
            ? _buildAgentUsersTab("Active")
            : _buildUsersAndAgentsTab("Users"),
        role[0] == "Agent"
            ? _buildAgentUsersTab("Inactive")
            : _buildUsersAndAgentsTab("Agents"),
        role[0] == "Agent"
            ? _buildAgentUsersTab("Reject")
            : _buildUsersAndAgentsTab("Admins"),
      ],
    );
  }

  Widget _buildUsersAndAgentsTab(String tabName) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        return StreamBuilder<List<UserModel>>(
          stream: provider.usersController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return tabName == "Admins"
                  ? _buildAdminsList(snapshot.data!)
                  : _buildUsersList(snapshot.data!, provider);
            }
            return const Center(child: Text("No Data"));
          },
        );
      },
    );
  }

  Widget _buildUsersList(List<UserModel> users, GetDatabase provider) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card.filled(
          child: ListTile(
            onTap: () => _showUserDetails(user),
            leading: CircleAvatar(
              child: user.profile == null
                  ? const Icon(CupertinoIcons.person_alt)
                  : ClipOval(
                      child: CachedNetworkImage(imageUrl: user.profile!)),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user, provider),
              itemBuilder: (context) => _popUpMenuItems,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminsList(List<UserModel> admins) {
    final adminUsers = admins.where((user) => user.role == "Admin").toList();
    if (adminUsers.isEmpty) {
      return const Center(child: Text("No Admins"));
    }
    return ListView.builder(
      itemCount: adminUsers.length,
      itemBuilder: (context, index) {
        final admin = adminUsers[index];
        return Card.filled(
          child: ListTile(
            leading: CircleAvatar(
              child: admin.profile == null
                  ? const Icon(CupertinoIcons.person_alt)
                  : ClipOval(
                      child: CachedNetworkImage(imageUrl: admin.profile!)),
            ),
            title: Text(admin.name),
            subtitle: Text(admin.email),
          ),
        );
      },
    );
  }

  Widget _buildAgentUsersTab(String condition) {
    return Consumer<GetDatabase>(
      builder: (context, provider, child) {
        return StreamBuilder<List<UserReqModel>>(
          stream: provider.userReqController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return _buildAgentUsersList(condition, snapshot.data!, provider);
            }
            return const Center(child: Text("No Data"));
          },
        );
      },
    );
  }

  Widget _buildAgentUsersList(
      String condition, List<UserReqModel> users, GetDatabase provider) {
    final filteredUsers =
        users.where((user) => user.status == condition).toList();
    if (filteredUsers.isEmpty) {
      return const Center(child: Text("No Data"));
    }
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: _buildAgentActions(user, condition, provider),
        );
      },
    );
  }

  Widget _buildAgentActions(
      UserReqModel user, String condition, GetDatabase provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (condition == "Active" || condition == "Reject")
          IconButton(
            onPressed: () => _showRemoveAgentDialog(user, provider),
            icon: const Icon(CupertinoIcons.minus_circle),
          ),
        if (condition == "Inactive")
          IconButton(
            onPressed: () => _showRejectAgentDialog(user, provider),
            icon: const Icon(CupertinoIcons.xmark),
          ),
        if (condition == "Inactive" || condition == "Reject")
          IconButton(
            onPressed: () => _showAcceptAgentDialog(user, provider),
            icon: const Icon(CupertinoIcons.checkmark_alt),
          ),
      ],
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            child: user.profile == null
                ? const Icon(Icons.person, size: 20)
                : ClipOval(child: CachedNetworkImage(imageUrl: user.profile!)),
          ),
          _buildUserInfoRow("UID", user.uid!),
          _buildUserInfoRow("Name", user.name),
          _buildUserInfoRow("Email", user.email),
          _buildUserInfoRow("Phone", user.phone.toString()),
          _buildUserInfoRow("Role", user.role),
          materialButton(
            text: "Done",
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleUserAction(String action, UserModel user, GetDatabase provider) {
    switch (action) {
      case "Delete":
        _showDeleteUserDialog(user, provider);
        break;
      default:
        _showChangeRoleDialog(action, user, provider);
    }
  }

  void _showDeleteUserDialog(UserModel? user, GetDatabase provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Do you want to delete ${user!.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.userPrevilage(user.uid!, "Delete");
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(
      String newRole, UserModel user, GetDatabase provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Role"),
        content: Text("Do you want to change ${user.name}'s role to $newRole?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.userPrevilage(user.uid!, newRole);
              Navigator.pop(context);
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  void _showRemoveAgentDialog(UserReqModel user, GetDatabase provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Agent"),
        content: Text("Do you want to remove ${user.name} as an agent?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteMember(user.uid);
              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  void _showRejectAgentDialog(UserReqModel user, GetDatabase provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Agent"),
        content: Text("Do you want to reject ${user.name}'s request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.opMembers(user.uid, "Reject");
              Navigator.pop(context);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  void _showAcceptAgentDialog(UserReqModel user, GetDatabase provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accept Agent"),
        content: Text("Do you want to accept ${user.name}'s request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.opMembers(user.uid, "Active");
              Navigator.pop(context);
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }
}
