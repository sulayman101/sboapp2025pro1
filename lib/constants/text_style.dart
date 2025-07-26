import 'package:flutter/material.dart';

const agbalumo = "Agbalumo-Regular";
const playfairDisplay = "PlayfairDisplay-Regular";
const nunitoSans = "NunitoSans-VariableFont";
const firaSansM = "FiraSans-Medium";
const firaSansL = "FiraSans-Light";
const firaSansB = "FiraSans-Bold";
const latoReg = "Lato-Regular";

Text appBarText({required String text, Color? color}) {
  return Text(
    text,
    style: TextStyle(
      color: color,
    ),
  );
}

Text decTitleText(
    {required String text, required double fontSize, Color? color}) {
  return Text(
    text,
    style: TextStyle(
        color: color,
        fontFamily: agbalumo,
        fontSize: fontSize,
        fontWeight: FontWeight.bold),
  );
}

Text titleText({required String text, double? fontSize, Color? color}) {
  return Text(
    text,
    style: TextStyle(
        color: color,
        fontFamily: firaSansB,
        fontSize: fontSize ?? kDefaultFontSize,
        fontWeight: FontWeight.bold),

  );
}

Text lTitleText({required String text}) {
  return Text(
    text.toUpperCase(),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontFamily: playfairDisplay,
      fontWeight: FontWeight.bold,
      //fontSize: kDefaultFontSize,
    ),
  );
}

Text lSubTitleText({required String text}) {
  return Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontFamily: latoReg,
      //fontSize: kDefaultFontSize,
    ),
  );
}

Text bodyText({required String text}) {
  return Text(
    text,
    style: const TextStyle(
      fontFamily: firaSansM,
        fontSize: kDefaultFontSize,
    ),
  );
}

Text buttonText({required String text, Color? color, double? fontSize}) {
  return Text(
    text,
    style: TextStyle(
        fontSize: fontSize ?? kDefaultFontSize,
        color: color,
        fontFamily: latoReg,
        fontWeight: FontWeight.bold,),
  );
}

Text labelText({required String text}) {
  return Text(
    text,
    style: const TextStyle(
      fontFamily: playfairDisplay,
    ),
  );
}

Text customText(
    {required String text,
    double? fontSize,
    Color? color,
    fontFamily,
    TextAlign? textAlign,
    FontWeight? fontWeight,
      int? maxLines
    }) {
  return Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    softWrap: true,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,

    ),
  );
}

Text rowTitleText({required String text}) {
  return Text(
    text,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: const TextStyle(
      fontFamily: playfairDisplay,
      fontWeight: FontWeight.bold,
      fontSize: kDefaultFontSize
    ),
  );
}

Text rowSubTitleText({required String text}) {
  return Text(
    text,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: const TextStyle(
      fontFamily: latoReg,
        fontSize: kDefaultFontSize
    ),
  );
}
