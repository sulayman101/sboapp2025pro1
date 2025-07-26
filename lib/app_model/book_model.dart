class BookModel {
  final String bookId;
  final String author;
  final bool? translated;
  final String book;
  final String status;
  final String category;
  final String? arcategory;
  final String? averageRate;
  final String? totalRates;
  final String date;
  final String img;
  final int like;
  final Map<String, LikesModel>? likes;
  final Map<String, RatesModel>? rates;
  final String link;
  final int price;
  final String language;
  final Map<String, PaidUsersModel>? paidUsers;
  final String user;
  final String username;

  BookModel({
    required this.bookId,
    required this.author,
    this.translated,
    required this.book,
    required this.status,
    required this.category,
    this.arcategory,
    this.averageRate,
    this.totalRates,
    required this.date,
    required this.img,
    required this.like,
    this.likes,
    this.rates,
    required this.link,
    required this.price,
    required this.language,
    this.paidUsers,
    required this.user,
    required this.username,
  });

  factory BookModel.fromJson(Map<dynamic, dynamic> json) {
    final likes = <String, LikesModel>{};

    (json['likes'] as Map<dynamic, dynamic>?)?.forEach((likeId, likeData) {
      likes[likeId] = LikesModel.fromJson(likeData);
    });

    final rates = <String, RatesModel>{};

    (json['rates'] as Map<dynamic, dynamic>?)?.forEach((rateId, rateData) {
      rates[rateId] = RatesModel.fromJson(rateData);
    });

    final paid = <String, PaidUsersModel>{};

    (json['paidUsers'] as Map<dynamic, dynamic>?)?.forEach((paidId, paidData) {
      paid[paidId] = PaidUsersModel.fromJson(paidData);
    });
    return BookModel(
      bookId: json['bookId'] ?? "",
      author: json['author'] ?? "",
      translated: json['translated'],
      book: json['book'] ?? "",
      status: json['status'] ?? "panding",
      category: json['category'] ?? "",
      arcategory: json['arcategory'] ?? "",
      averageRate: json['averageRate'] ?? "0.0",
      totalRates: json['totalRates'] ?? "0",
      date: json['date'] ?? "",
      img: json['img'] ?? "",
      likes: likes,
      rates: rates,
      link: json['link'] ?? "",
      price: json['price'] ?? "",
      language: json['language'] ?? "",
      paidUsers: paid,
      user: json['user'] ?? "",
      like: json['like'] ?? "",
      username: json['username'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'author': author,
      'translated': translated,
      'book': book,
      'status': status,
      'category': category,
      'arcategory': arcategory,
      'averageRate': averageRate,
      'totalRates': totalRates,
      'date': date,
      'img': img,
      'like': like,
      'link': link,
      'price': price,
      'language': language,
      'user': user,
      'username': username,
    };
  }
}

class LikesModel {
  final String? uid;
  final String? name;
  final bool? like;

  LikesModel({
    this.uid,
    this.name,
    this.like,
  });

  factory LikesModel.fromJson(Map<dynamic, dynamic> json) {
    return LikesModel(
      uid: json['uid'] ?? "",
      name: json['name'] ?? "",
      like: json['like'] ?? "",
    );
  }
}

class RatesModel {
  final String? uid;
  final String? name;
  final String? rate;

  RatesModel({
    this.uid,
    this.name,
    this.rate,
  });

  factory RatesModel.fromJson(Map<dynamic, dynamic> json) {
    return RatesModel(
      uid: json['uid'] ?? "",
      name: json['name'] ?? "",
      rate: json['rate'] ?? "0",
    );
  }
}

class PaidUsersModel {
  final bool? paid;
  final String? uid;
  final String? name;

  PaidUsersModel({
    this.paid,
    this.uid,
    this.name,
  });

  factory PaidUsersModel.fromJson(Map<dynamic, dynamic> json) {
    return PaidUsersModel(
      paid: json['paid'] ?? "",
      uid: json['uid'] ?? "",
      name: json['name'] ?? "",
    );
  }
}

class MyCategories {
  final String category;
  final String cover;
  final String arcategory;
  MyCategories(
      {required this.cover, required this.category, required this.arcategory});

  factory MyCategories.fromJson(Map<dynamic, dynamic> json) {
    return MyCategories(
        cover: json["cover"],
        category: json["category"],
        arcategory: json["arcategory"]);
  }
}
