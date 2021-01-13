part of masamune.firebase;

/// Utility for Firestore.
class FirestoreUtility {
  /// Increase the number.
  ///
  /// Increase the number in real time and
  /// make it consistent on the server side.
  ///
  /// [path]: Increment path.
  /// [value]: Increment value.
  static Future increment(String path, int value) async {
    String parent = Paths.parent(path);
    String key = Paths.last(path);
    IDataDocument doc = PathMap.get(parent);
    if (doc == null) {
      if (value < 0) return;
      DataField(path, value);
      doc = await FirestoreDocument.listen(parent);
      doc[key] = (doc.getInt(key, 0) + value).limitLow(0);
      if (doc is FirestoreDocument) doc.useCounter([key]);
    } else {
      doc[key] = (doc.getInt(key, 0) + value).limitLow(0);
      if (doc is FirestoreDocument) doc.useCounter([key]);
    }
  }
}
