
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:sboapp/utils/global_strings.dart";

import "../app_model/book_model.dart";


Widget booksRating({BookModel? bookModel, required BuildContext context, bool? isInteractive}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      RatingBar.builder(
        initialRating: double.parse(
            bookModel?.rates?[myUid]?.rate ??
                "0.0"), //double.parse(bookModel?.averageRate ?? "0.0"),
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemSize: 40.0,
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (newRating) {
          /*
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
          );
           */
          //onChange
          /*onChange(() {
              rating = newRating;
            });*/
        },
      ),
    ],
  );
}