part of masamune.firebase;

/// Provider of the firestore data collection.
///
/// You can store and
/// use data fields there by describing the path as it is.
///
/// ```dart
/// final collection = FirestoreCollectionProvider("user");
/// ```
class FirestoreCollectionProvider extends PathProvider<FirestoreCollection> {
  /// Provider of the firestore data collection.
  ///
  /// You can store and
  /// use data fields there by describing the path as it is.
  ///
  /// ```dart
  /// final collection = FirestoreCollectionProvider("user");
  /// ```
  ///
  /// [path]: Collection path.
  /// [query]: Firestore query.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  FirestoreCollectionProvider(
    String path, {
    FirestoreQuery query,
    OrderBy orderBy = OrderBy.none,
    String orderByKey,
    OrderBy thenBy = OrderBy.none,
    String thenByKey,
  }) : super(
          (_) => FirestoreCollection.listen(
            path,
            query: query,
            orderBy: orderBy,
            thenBy: thenBy,
            orderByKey: orderByKey,
            thenByKey: thenByKey,
          ),
        );
}
