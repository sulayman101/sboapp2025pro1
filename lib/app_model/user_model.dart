class Subscription {
  final String? subname;
  final bool? subscribe;
  final String? expireDate; // e.g., "2024/12/1"

  Subscription({this.subname, this.subscribe, this.expireDate});

  // Convert SubscriptionModel to Map
  Map<String, dynamic> toJson() {
    return {
      'subname': subname,
      'subscribe': subscribe,
      'expireDate': expireDate,
    };
  }

  // Factory method to create SubscriptionModel from Map
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subname: json['subname'] ?? "",
      subscribe: json['subscribed'] ?? false,
      expireDate: json['expireDate'] ?? "",
    );
  }
}

class UserModel {
  final String name;
  final String email;
  final String role;
  final int? phone;
  final String? uid;
  final String? token;
  final String? profile;
  final bool? uploader;
  final bool? author;
  final String? device;
  final String? agentId;
  final bool isVerify;
  final int? lucky;
  final String? luckyDate;
  final Subscription? subscription; // Add Subscription model here

  UserModel({
    required this.name,
    required this.email,
    required this.isVerify,
    required this.role,
    this.phone,
    this.uid,
    this.token,
    this.profile,
    this.uploader,
    this.author,
    this.device,
    this.agentId,
    this.lucky,
    this.luckyDate,
    this.subscription,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'uid': uid,
      'profile': profile,
      'uploader': uploader,
      'author': author,
      'device': device,
      'agentId': agentId,
      'isVerify': isVerify,
      'lucky': lucky,
      'luckyDate': luckyDate,
      'subscription': subscription?.toJson(), // Nested Subscription to JSON
    };
  }

  // Factory method to create a UserModel from a Map
  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      uid: json['uid'],
      token: json['token'],
      profile: json['profile'],
      uploader: json['uploader'],
      author: json['author'],
      device: json['device'],
      agentId: json['agentId'],
      isVerify: json['isVerify'] ?? false,
      lucky: json['lucky'],
      luckyDate: json['luckyDate'],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(
              Map<String, dynamic>.from(json['subscription'])) // Cast here
          : null,
    );
  }
}

//============================= Request Users =======================

class UserReqModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String sub;
  final String status;

  UserReqModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.sub,
    required this.status,
  });

  // Convert UserModel to a Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'sub': sub,
      'status': status,
    };
  }

  // Factory method to create a UserModel from a Map
  factory UserReqModel.fromJson(Map<dynamic, dynamic> json) {
    return UserReqModel(
        uid: json['uid'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        sub: json['sub'],
        status: json['status']);
  }
}

class UserModelAsJson {
  final String name;
  final String email;
  final String role;
  final int? phone;
  final String? uid;
  final String? token;
  final String? profile;
  final bool? uploader;
  final bool? author;
  final String? device;
  final String? agentId;
  final bool isVerify;
  final int? lucky;
  final String? luckyDate;

  UserModelAsJson({
    required this.name,
    required this.email,
    required this.isVerify,
    required this.role,
    this.phone,
    this.uid,
    this.token,
    this.profile,
    this.uploader,
    this.author,
    this.agentId,
    this.device,
    this.lucky,
    this.luckyDate,
  });

  // Convert UserModel to a Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'uid': uid,
      'profile': profile,
      'uploader': uploader,
      'author': author,
      'device': device,
      'agentId': agentId,
      'isVerify': isVerify,
      'lucky': lucky,
      'luckyDate': luckyDate
    };
  }

  // Factory method to create a UserModel from a Map
  factory UserModelAsJson.fromJson(Map<dynamic, dynamic> json) {
    return UserModelAsJson(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? 0,
      uid: json['uid'] ?? '',
      token: json['token'] ?? '',
      profile: json['profile'] ?? '',
      uploader: json['uploader'] ?? false,
      author: json['author'] ?? false,
      device: json['device'] ?? '',
      agentId: json['agentId'] ?? '',
      isVerify: json['isVerify'] ?? false,
      lucky: json['lucky'] ?? 0,
      luckyDate: json['luckyDate'] ?? '',
    );
  }
}
