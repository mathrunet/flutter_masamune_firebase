part of masamune.firebase;

/// Firestore's collection model.
///
/// You can get the data as a collection by specifying the Firestore path.
class FirestoreCollectionModel extends CollectionModel {
  /// A key list to use as a counter.
  final List<String> keysAsCounter;

  /// Firestore query.
  final FirestoreQuery query;

  /// Firestore's collection model.
  ///
  /// You can get the data as a collection by specifying the Firestore path.
  FirestoreCollectionModel(String path,
      {this.query,
      this.keysAsCounter,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(
          path,
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey,
        );

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
