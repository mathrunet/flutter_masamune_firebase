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
      if (!key.contains("@count")) return value;
      String tmp = key.replaceAll("@count", Const.empty);
      if (document != null && document is FirestoreDocument) {
        List ignore = document.getList(ignoreKey, []);
        if (!ignore.contains(tmp)) ignore.add(tmp);
        if (document._subListener.containsKey(tmp)) return value;
        document._subListener[tmp] = document._reference
            .collection(tmp)
            .snapshots()
            .listen((collection) {
          if (document.containsKey(tmp) && document.isUpdating) return;
          if (document.containsKey("time") &&
              document.containsKey("@time") &&
              document["time"] != document["@time"]) return;
          num count = collection?.documents?.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + (element?.data["value"] ?? 0)) ??
              0;
          document[tmp] = count;
        });
      }
      return value;
    }
  };
}
