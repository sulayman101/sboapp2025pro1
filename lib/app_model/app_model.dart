


class Agent {
  final String email;
  final String name;
  final String phone;
  final String status;
  final String sub;
  final String uid;

  Agent({
    required this.email,
    required this.name,
    required this.phone,
    required this.status,
    required this.sub,
    required this.uid,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      status: json['status'],
      sub: json['sub'],
      uid: json['uid'],
    );
  }
}

class Like {
  final bool like;
  final String name;
  final String uid;

  Like({
    required this.like,
    required this.name,
    required this.uid,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      like: json['like'],
      name: json['name'],
      uid: json['uid'],
    );
  }
}

class Book {
  final String author;
  final String book;
  final String bookId;
  final String category;
  final String date;
  final String img;
  final int like;
  final Map<String, Like> likes;
  final String link;
  final int price;
  final String user;
  final String username;

  Book({
    required this.author,
    required this.book,
    required this.bookId,
    required this.category,
    required this.date,
    required this.img,
    required this.like,
    required this.likes,
    required this.link,
    required this.price,
    required this.user,
    required this.username,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> likesJson = json['likes'];
    var likesMap = likesJson.map((key, value) => MapEntry(key, Like.fromJson(value)));

    return Book(
      author: json['author'],
      book: json['book'],
      bookId: json['bookId'],
      category: json['category'],
      date: json['date'],
      img: json['img'],
      like: json['like'],
      likes: Map<String, Like>.from(likesMap),
      link: json['link'],
      price: json['price'],
      user: json['user'],
      username: json['username'],
    );
  }
}

class SBO {
  final Map<String, Map<String, Agent>> agents;
  final Map<String, Map<String, Book>> books;

  SBO({
    required this.agents,
    required this.books,
  });

  factory SBO.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> agentsJson = json['Agents'];
    var agentsMap = agentsJson.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, Agent.fromJson(v)))));

    Map<String, dynamic> booksJson = json['Books'];
    var booksMap = booksJson.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, Book.fromJson(v)))));

    return SBO(
      agents: Map<String, Map<String, Agent>>.from(agentsMap),
      books: Map<String, Map<String, Book>>.from(booksMap),
    );
  }
}



//Entity


class BookEntity{
  String author;
  String book;
  String bookId;
  String category;
  String date;
  String img;
  String like;
  String likes;
  String link;
  String price;
  String user;
  String username;

  BookEntity({
    required this.author,
    required this.book,
    required this.bookId,
    required this.category,
    required this.date,
    required this.img,
    required this.like,
    required this.likes,
    required this.link,
    required this.price,
    required this.user,
    required this.username,
  });
}