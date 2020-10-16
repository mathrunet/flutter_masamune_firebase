part of masamune.firebase;

/// Data model with a data structure for firestore collections.
///
/// The contents of the collection store data documents and so on, including data that sequentially reads the stored data list as it is stored.
///
/// You can search by text.
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
class SearchableFirestoreCollectionModel
    extends CollectionModel<SearchableFirestoreCollection> {
  final bool listenable;
  final String queryKey;
  final int limit;
  final String searchText;

  /// Data model with a data structure for firestore collections.
  ///
  /// The contents of the collection store data documents and so on, including data that sequentially reads the stored data list as it is stored.
  ///
  /// You can search by text.
  ///
  /// Defines the data document of the specified [path].
  ///
  /// If [listenable] is set to true, updates will be monitored.
  SearchableFirestoreCollectionModel(String path,
      {this.listenable = false,
      this.queryKey = "@search",
      this.limit = 500,
      this.searchText,
      OrderBy orderBy = OrderBy.none,
      String orderByKey,
      OrderBy thenBy = OrderBy.none,
      String thenByKey})
      : super(path,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);

  @override
  Future<SearchableFirestoreCollection> build(ModelContext context) {
    if (this.listenable) {
      return SearchableFirestoreCollection.listen(
        this.path,
        limit: this.limit,
        queryKey: this.queryKey,
        searchText: this.searchText,
        orderBy: this.orderBy,
        thenBy: this.thenBy,
        orderByKey: this.orderByKey,
        thenByKey: this.thenByKey,
      );
    } else {
      return SearchableFirestoreCollection.load(
        this.path,
        limit: this.limit,
        queryKey: this.queryKey,
        searchText: this.searchText,
        orderBy: this.orderBy,
        thenBy: this.thenBy,
        orderByKey: this.orderByKey,
        thenByKey: this.thenByKey,
      );
    }
  }
}
