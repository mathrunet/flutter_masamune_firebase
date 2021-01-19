part of masamune.firebase;

/// Firestore's collection model.
///
/// You can get the data as a collection by specifying the Firestore path.
class FirestoreCollectionModel extends CollectionModel {
  /// A key list to use as a counter.
  final List<String> keysAsCounter;

  /// Firestore query.
  final FirestoreQuery query;

  /// Order by type.
  final OrderBy orderBy;

  /// Order by type.
  final OrderBy thenBy;

  /// Key of orderBy.
  final String orderByKey;

  /// Key of thenBy.
  final String thenByKey;

  /// Firestore's collection model.
  ///
  /// You can get the data as a collection by specifying the Firestore path.
  FirestoreCollectionModel(String path,
      {this.query,
      this.keysAsCounter,
      this.orderBy = OrderBy.none,
      this.thenBy = OrderBy.none,
      this.orderByKey,
      this.thenByKey})
      : super(path);

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return FirestoreCollection.listen(
      this.path,
      keysAsCounter: this.keysAsCounter,
      query: this.query,
      orderBy: this.orderBy,
      thenBy: this.thenBy,
      orderByKey: this.orderByKey,
      thenByKey: this.thenByKey,
    );
  }
}
