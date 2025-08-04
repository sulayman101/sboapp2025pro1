String convertLang(String language, dynamic providerLocale) {
  final languageMap = {
    "Somali": providerLocale.bodySomali,
    "Arabic": providerLocale.bodyArabic,
    "English": providerLocale.bodyEnglish,
  };

  return languageMap[language] ?? "Unknown";
}
