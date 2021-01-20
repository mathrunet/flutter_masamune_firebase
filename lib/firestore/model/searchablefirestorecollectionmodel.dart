part of masamune.firebase;

/// Firestore's collection model.
///
/// You can get the data as a collection by specifying the Firestore path.
class SearchableFirestoreCollectionModel extends CollectionModel {
  String _searchText;

  /// Search text.
  String get searchText => this._searchText ?? this.defaultSearchText;

  /// Search text.
  set searchText(String value) {
    if (value == this.searchText) return;
    this._searchText = value;
    this.rebuild();
  }

  /// A key list to use as a counter.
  final List<String> keysAsCounter;

  /// The query key to perform the search.
  final String queryKey;

  /// Search limit.
  final int limit;

  /// Default search text.
  final String defaultSearchText;

  /// Firestore's collection model.
  ///
  /// You can get the data as a collection by specifying the Firestore path.
  SearchableFirestoreCollectionModel(
    String path, {
    this.queryKey = "@search",
    this.limit = 500,
    this.defaultSearchText,
    this.keysAsCounter,
    OrderBy orderBy = OrderBy.none,
    OrderBy thenBy = OrderBy.none,
    String orderByKey,
    String thenByKey,
  }) : super(
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
    return SearchableFirestoreCollection.listen(
      this.path,
      keysAsCounter: this.keysAsCounter,
      queryKey: this.queryKey,
      searchText: this.searchText,
      orderBy: this.orderBy,
      thenBy: this.thenBy,
      orderByKey: this.orderByKey,
      thenByKey: this.thenByKey,
    );
  }
}
