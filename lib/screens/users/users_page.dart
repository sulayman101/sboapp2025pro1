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

  // ignore: unused_field
  late String _selectedRole;
  static const menuItems = <String>[
    'Admin',
    'User',
    'Banned',
    'Agent',
    'Delete',
  ];
  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) =>
        PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
  )
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _tabView() {
    final role = ModalRoute
        .of(context)
        ?.settings
        .arguments as List;
    return TabBarView(
      controller: _tabController,
      children: [
        role[0] == "Agent" ? manAgentsUsers(tabName: "Active") : usersAndAgents(
            tabName: "Users"),
        role[0] == "Agent" ? manAgentsUsers(tabName: "Inactive") : usersAndAgents(
            tabName: "Agents"),
        role[0] == "Agent" ? manAgentsUsers(tabName: "Reject") : usersAndAgents(
            tabName: "Admins")
      ],
    );
  }

  Widget _tabBar() {
    final providerLocale =
        Provider
            .of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final role = ModalRoute
        .of(context)
        ?.settings
        .arguments as List;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TabBar(
          unselectedLabelColor: Theme
              .of(context)
              .colorScheme
              .primary,
          labelColor: Theme
              .of(context)
              .colorScheme
              .onPrimary,
          tabAlignment: TabAlignment.fill,
          indicatorWeight: 2,
          indicatorPadding: EdgeInsets.zero,
          splashBorderRadius: const BorderRadius.only(
              topRight: Radius.circular(10), topLeft: Radius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Theme
              .of(context)
              .colorScheme
              .primary,
          dividerHeight: 2,
          indicator: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          isScrollable: false,
          controller: _tabController,
          tabs: [
            role[0] == "Agent"
                ? Tab(text: providerLocale.bodyActive)
                : Tab(text: providerLocale.bodyAllUsers),
            role[0] == "Agent"
                ? Tab(text: providerLocale.bodyRequests)
                : Tab(text: providerLocale.bodyAllAgents),
            role[0] == "Agent"
                ? Tab(
              text: providerLocale.bodyRejects,
            )
                : Tab(text: providerLocale.bodyAllAdmins),
          ]),
    );
  }

  _rowUserInfo({required String title, String? textValue, Widget? value}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              customText(text: "$title: ", fontWeight: FontWeight.bold),
            ],
          ),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              value ?? customText(text: textValue!,
                maxLines: 3,
              ),
            ],
          ))
        ],),
    );
  }

  Widget usersAndAgents({tabName}) {
    return Consumer<GetDatabase>(
      builder: (BuildContext context, GetDatabase value, Widget? child) {
        final provider = context.watch<GetDatabase>();
        return StreamBuilder<List<UserModel>>(
          stream: provider.usersController.stream,
          builder:
              (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              if (tabName == "Admins") {

              }
              if (tabName == "Agents") {
                return agents(snapshot);
              } else {
                return users(snapshot, provider);
              }
            } else {
              return const Center(child: Text("No Data"),);
            }
          },
        );
      },
    );
  }

  Widget users(snapshot, provider) {
    final providerLocale =
        Provider
            .of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return Card.filled(
            child: ListTile(
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: (context) =>
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.01,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius
                                      .circular(30)
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: titleText(
                                text: "User Info", fontSize: 20),
                          ),
                          Center(child:
                          CircleAvatar(
                              radius: 50,
                              child: snapshot.data![index]
                                  .profile == null
                                  ? Icon(Icons.person, size: 20,)
                                  : ClipRRect(
                                  borderRadius: BorderRadius
                                      .circular(50),
                                  child: CachedNetworkImage(
                                      imageUrl: snapshot
                                          .data![index]
                                          .profile!))),
                          ),
                          _rowUserInfo(title: "UID",
                              textValue: snapshot.data![index].uid
                                  .toString()),
                          _rowUserInfo(title: "Name",
                              textValue: snapshot.data![index]
                                  .name),
                          _rowUserInfo(title: "Email",
                              textValue: snapshot.data![index]
                                  .email),
                          _rowUserInfo(title: "Phone",
                              textValue: snapshot.data![index]
                                  .phone.toString()),
                          _rowUserInfo(title: "is Verified",
                              value: snapshot.data![index]
                                  .isVerify ? Icon(Icons.verified,
                                color: Colors.blue,) : Icon(
                                Icons.verified,
                                color: Colors.grey,)),
                          _rowUserInfo(title: "Role",
                              textValue: snapshot.data![index]
                                  .role),
                          _rowUserInfo(title: "is Author",
                              textValue: snapshot.data![index]
                                  .author.toString()),
                          _rowUserInfo(title: "Subscriber",
                              value: snapshot.data![index]
                                  .subscription == null
                                  ? const Icon(
                                  Icons.remove_circle_outlined)
                                  : snapshot.data![index]
                                  .subscription!.subscribe!
                                  ? Icon(Icons.check_circle)
                                  : Icon(
                                  Icons.remove_circle_outlined)),
                          _rowUserInfo(title: "is Uploader",
                              value: snapshot.data![index]
                                  .uploader == null ||
                                  snapshot.data![index].uploader!
                                  ? Icon(Icons.close)
                                  : Icon(Icons.check)),
                          _rowUserInfo(title: "FCM Token",
                              textValue: snapshot.data![index]
                                  .token.toString()),
                          const Divider(),
                          materialButton(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                              onPressed: () =>
                                  Navigator.pop(context),
                              text: "Done"),
                        ],),
                    ));
              },
              leading: snapshot.data![index].profile == null
                  ? const CircleAvatar(
                  child: Icon(CupertinoIcons.person_alt))
                  : CircleAvatar(
                  child: ClipOval(
                      child: Image.network(
                          snapshot.data![index].profile!))),
              title: Text(snapshot.data![index].name),
              subtitle: Text(snapshot.data![index].email),
              trailing: PopupMenuButton<String>(
                onSelected: (String newValue) {
                  _selectedRole = newValue;
                  switch (newValue) {
                    case "Delete":
                      showDialog(
                          context: context,
                          builder: (context) =>
                              _alert(
                                bodyText(
                                    text:
                                    "${providerLocale
                                        .bodyDoWentDelete} ${snapshot
                                        .data![index].name}"),
                                    () {
                                  provider.userPrevilage(
                                      snapshot.data![index].uid,
                                      newValue);
                                  Navigator.pop(context);
                                },
                              ));
                    default:
                      showDialog(
                          context: context,
                          builder: (context) =>
                              _alert(
                                snapshot.data![index].role ==
                                    "Admin"
                                    ? bodyText(
                                    text: providerLocale
                                        .bodyNotChangeAdmins)
                                    : bodyText(
                                    text: providerLocale
                                        .bodyRoleActions(
                                        snapshot
                                            .data![index].role,
                                        newValue,
                                        snapshot.data![index]
                                            .name)),
                                    () {
                                  provider.userPrevilage(
                                      snapshot.data![index].uid,
                                      newValue);
                                  Navigator.pop(context);
                                },
                              ));
                  }
                },
                itemBuilder: (BuildContext context) => _popUpMenuItems,
              ),
            ),
          );
        });
  }

  Widget agents(snapshot) {
    List<UserModel> agents = [];
    for (var element in snapshot.data!) {
      if (element.role == "Agent") {
        agents.add(element);
      }
    }
    if (agents.isNotEmpty) {
      return ListView.builder(
          itemCount: agents.length,
          itemBuilder: (context, index) {
            return Card.filled(
              child: ListTile(
                leading: agents[index].profile == null
                    ? const CircleAvatar(
                    child: Icon(CupertinoIcons.person_alt))
                    : CircleAvatar(
                    child: ClipOval(
                        child:
                        Image.network(agents[index].profile!))),
                title: Text(agents[index].name),
                subtitle: Text(agents[index].email),
              ),
            );
          });
    } else {
      return const Center(child: Text("No Agents"),);
    }
  }


  Widget admins(snapshot) {
    List<UserModel> admins = [];
    for (var element in snapshot.data!) {
      if (element.role == "Admin") {
        admins.add(element);
      }
    }
    if (admins.isNotEmpty) {
      return ListView.builder(
          itemCount: admins.length,
          itemBuilder: (context, index) {
            return Card.filled(
              child: ListTile(
                leading: admins[index].profile == null
                    ? const CircleAvatar(
                    child: Icon(CupertinoIcons.person_alt))
                    : CircleAvatar(
                    child: ClipOval(
                        child:
                        Image.network(admins[index].profile!))),
                title: Text(admins[index].name),
                subtitle: Text(admins[index].email),
              ),
            );
          });
    } else {
      return const Center(child: Text("No Admins"));
    }
  }

  Widget manAgentsUsers({tabName}){
    return Consumer<GetDatabase>(
        builder: (BuildContext context, GetDatabase value, Widget? child) {
      final provider = context.read<GetDatabase>();
      return StreamBuilder<List<UserReqModel>>(
          stream: provider.userReqController.stream,
          builder: (BuildContext context,
          AsyncSnapshot<List<UserReqModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              if(tabName == "Active"){
                return agentUsers(tabName, snapshot, provider);
              }
              if(tabName == "Inactive"){
                return agentUsers(tabName, snapshot, provider);
              }else{
                return agentUsers(tabName, snapshot, provider);
              }
            } else {
              return Center(child: Text("No Data"),);
            }
            });
          });
  }

  Widget agentUsers(String condition, snapshot, provider) {
    final providerLocale =
        Provider
            .of<AppLocalizationsNotifier>(context, listen: false)
            .localizations;
    return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return snapshot.data![index].status == condition
              ? ListTile(
            /*leading: snapshot.data![index].profile == null
                            ? const CircleAvatar(
                            child: Icon(CupertinoIcons.person_alt))
                            : CircleAvatar(child: ClipOval(child: Image.network(
                            snapshot.data![index].profile!))),*/
            title: Text(snapshot.data![index].name),
            subtitle: Text(snapshot.data![index].email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                snapshot.data![index].status == "Active" ||
                    condition == "Reject"
                    ? IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              backgroundColor:
                              Colors.redAccent,
                              title: const Text(
                                  "Remove Agent"),
                              content: Text(providerLocale
                                  .bodyUserManActions(
                                  snapshot
                                      .data![index]
                                      .name)),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      provider.deleteMember(
                                          snapshot
                                              .data![
                                          index]
                                              .uid);
                                      Navigator.pop(
                                          context);
                                    },
                                    child: Text(
                                        providerLocale
                                            .bodyRemove)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child: Text(
                                        providerLocale
                                            .bodyCancel))
                              ],
                            ));
                  },
                  icon: const Icon(
                      CupertinoIcons.minus_circle),
                )
                    : const SizedBox(),
                snapshot.data![index].status == "Inactive"
                    ? IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              backgroundColor:
                              Colors.orangeAccent,
                              title: const Text(
                                  "Reject Member"),
                              content: Text(
                                  "Do you want to reject ${snapshot
                                      .data![index]
                                      .name} from your agent."),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      provider.opMembers(
                                          snapshot
                                              .data![
                                          index]
                                              .uid,
                                          "Reject");
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        "Reject")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        "Cancel"))
                              ],
                            ));
                  },
                  icon: const Icon(CupertinoIcons.xmark),
                )
                    : const SizedBox(),
                snapshot.data![index].status == "Inactive" ||
                    condition == "Reject"
                    ? IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              backgroundColor:
                              Colors.greenAccent,
                              title: const Text(
                                  "Accept member"),
                              content: Text(
                                  "Do you want to accept ${snapshot
                                      .data![index]
                                      .name} from your agent."),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      provider.opMembers(
                                          snapshot
                                              .data![
                                          index]
                                              .uid,
                                          "Active");
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        "Accept")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        "Cancel"))
                              ],
                            ));
                  },
                  icon: const Icon(
                      CupertinoIcons.checkmark_alt),
                )
                    : const SizedBox(),
              ],
            ),
          )
              : const SizedBox();
        });
  }

  Widget _alert(Widget content, VoidCallback onPressed) {
        final providerLocale =
            Provider
                .of<AppLocalizationsNotifier>(context, listen: true)
                .localizations;
        return AlertDialog(
          title: bodyText(text: providerLocale.bodyPriChange),
          content: content,
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: bodyText(text: providerLocale.bodyCancel)),
            ElevatedButton(
                onPressed: onPressed,
                child: bodyText(text: providerLocale.bodySure))
          ],
        );
      }

      @override
      Widget build(BuildContext context) {
        final role = ModalRoute
            .of(context)
            ?.settings
            .arguments as List;
        // ignore: unused_local_variable
        final providerLocale =
            Provider
                .of<AppLocalizationsNotifier>(context, listen: false)
                .localizations;
        return ScaffoldWidget(
            appBar: AppBar(
              title: role[0] == "Agent"
                  ? const Text("Agent Members")
                  : const Text("Users"),
            ),
            body: Column(
              children: [
                _tabBar(),
                Expanded(child: _tabView()),
              ],
            ));
      }
  }
