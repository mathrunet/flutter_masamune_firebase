part of masamune.firebase;

/// Metadata list for Firestore.
class FirestoreMeta {
  /// The key to carry out the translation.
  static const String translateKeys = "@keys";

  /// A key that indicates whether it is searchable.
  static const String searchable = "@searchable";

  /// Key for language.
  static const String localeKey = "@locale";

  /// Key for ignore update.
  static const String ignoreKey = "@ignore";

  /// Describes the metadata and processing at the time of getting.
  static final Map<String, FirestoreMetaFilter> filter = {
    "@translate": (key, value, data) {
      if (!data.containsKey(key)) return value;
      if (data.containsKey(localeKey) && data[localeKey] == Localize.language)
        return value;
      Map map = data[key] as Map;
      if (map == null) return value;
      if (!map.containsKey(Localize.language)) {
        if (map.containsKey("en")) return map["en"];
        return value;
      }
      return map[Localize.language];
    }
  };
}
