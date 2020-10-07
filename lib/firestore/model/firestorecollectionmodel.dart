part of masamune.firebase;

/// Data model with a data structure for firestore collections.
///
/// The contents of the collection store data documents and so on, including data that sequentially reads the stored data list as it is stored.
///
/// You can add or remove documents that are children of this collection by using [append] or [delete].
///
/// ```
///
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(
///       title: Text("Title"),
///     ),
///     body: ListView(
///       children: FirestoreCollectionModel("user").map(
///         (item) => ListTile(
///           title: Text(
///             item.getString("uid")
///           ),
///         ),
///       ),
///     ),
///     floatingActionButton: FloatingActionButton(
///       onPressed: () {
///         FirestoreCollectionModel("user").append(
///           builder: (doc) {
///             doc["uid"] = Texts.uuid;
///           },
///         );
///       },
///       child: Icon(Icons.add),
///     ),
///   );
/// }
/// ```
class FirestoreCollectionModel extends CollectionModel<FirestoreCollection> {
  final bool listenable;
  final FirestoreQuery query;

  /// Data model with a data structure for firestore collections.
  ///
  /// The contents of the collection store data documents and so on, including data that sequentially reads the stored data list as it is stored.
  ///
  /// You can add or remove documents that are children of this collection by using [append] or [delete].
  ///
  /// Defines the data document of the specified [path].
  ///
  /// If [listenable] is set to true, updates will be monitored.
  FirestoreCollectionModel(String path,
      {this.listenable = false,
      this.query,
      OrderBy orderBy = OrderBy.none,
      String orderByKey,
      OrderBy thenBy = OrderBy.none,
      String thenByKey})
      : super(
            path: path,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);

  @override
  Future<FirestoreCollection> createTask(ModelContext context) {
    if (this.listenable) {
      return FirestoreCollection.listen(
        this.path,
        query: this.query,
        orderBy: this.orderBy,
        thenBy: this.thenBy,
        orderByKey: this.orderByKey,
        thenByKey: this.thenByKey,
      );
    } else {
      return FirestoreCollection.load(
        this.path,
        query: this.query,
        orderBy: this.orderBy,
        thenBy: this.thenBy,
        orderByKey: this.orderByKey,
        thenByKey: this.thenByKey,
      );
    }
  }

  @override
  FirestoreCollection build(ModelContext context) =>
      PathMap.get<FirestoreCollection>(this.path);

  /// Add a new document to the collection.
  ///
  /// Documents added to the collection are stored in the path specified by [id] (or UUID).
  ///
  /// You can define the initial values of a document by specifying [data] and edit the internal data with the [builder].
  Future append(
      {String id,
      Map<String, dynamic> data,
      FutureOr builder(FirestoreDocument document)}) async {
    String path = Paths.child(this.path, id ?? Texts.uuid);
    FirestoreDocument state = await FirestoreDocument.listen(path);
    if (state == null || state.isDisposed) {
      state = FirestoreDocument.create(path);
    }
    if (data != null) {
      for (MapEntry<String, dynamic> tmp in data.entries) {
        if (isEmpty(tmp.key) || tmp.value == null) continue;
        state[tmp.key] = tmp.value;
      }
    }
    if (builder != null) await builder(state);
    await state.save();
  }
}
