import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/book_model.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';

Widget booksRating(

    {required BuildContext context, double? rating, double? starSize, BookModel? bookModel}) {
  final isGuest = Provider.of<AuthServices>(context).isGuest;
  final provider = Provider.of<GetDatabase>(context, listen: false);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      RatingBar.builder(
        initialRating: double.parse(isGuest ? "0.0" :
            bookModel?.rates?[AuthServices().fireAuth.currentUser!.uid]?.rate ??
                "0.0"), //double.parse(bookModel?.averageRate ?? "0.0"),
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemSize: starSize ?? 40.0,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (newRating) {
          if(isGuest){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("you can't rate as Guest")));
          }else{
          provider.ratingActions(
            isRated: bookModel
                    ?.rates?[AuthServices().fireAuth.currentUser!.uid]?.rate !=
                null,
            totalRates: int.parse(bookModel!.totalRates!.toString()),
            averageRate: double.parse(bookModel.averageRate!.toString()),
            rate: newRating,
            category: bookModel.category, // Book category
            bookId: bookModel.bookId, // Book ID
            uid: AuthServices().fireAuth.currentUser!.uid, // Current user's UID
            username: AuthServices()
                .fireAuth
                .currentUser!
                .displayName, // Current user's display name
          );}
          //onChange
          /*onChange(() {
              rating = newRating;
            });*/
        },
      ),
    ],
  );
}
