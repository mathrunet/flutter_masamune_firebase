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

  /// Key for geo hash.
  static const String geoHashKey = "@geohash";

  /// Describes the metadata and processing at the time of getting.
  static final Map<String, FirestoreMetaFilter> filter = {
    "@translate": (key, value, data, document) {
      key = key + "@translate";
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
    },
    "@count": (key, value, data, document) {
      if (data.containsKey("$key@count")) return null;
      if (!key.endsWith("@count")) return value;
      String tmp = key.replaceAll("@count", Const.empty);
      if (document != null && document is FirestoreDocument) {
        if (document._subListener.containsKey(tmp)) return value;
        document.addCounterListener(tmp);
      }
      return value;
    },
  };
}
