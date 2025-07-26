

String convertLang(String language, providerLocale) {
  String somali = providerLocale.bodySomali;
  String arabic = providerLocale.bodyArabic;
  String english = providerLocale.bodyEnglish;
  switch (language) {
    case "Somali":
      return somali;
    case "Arabic":
      return arabic;
    case "English":
      return english;
    default:
      return "Unkown";
  }
}
