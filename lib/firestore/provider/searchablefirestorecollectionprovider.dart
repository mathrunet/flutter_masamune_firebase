part of masamune.firebase;

/// Provider of the searchable firestore data collection.
///
/// You can store and
/// use data fields there by describing the path as it is.
///
/// ```dart
/// final collection = SeachableFirestoreCollectionProvider("user", searchText: "search");
/// ```
class SearchableFirestoreCollectionProvider
    extends PathProvider<SearchableFirestoreCollection> {
  /// Provider of the searchable firestore data collection.
  ///
  /// You can store and
  /// use data fields there by describing the path as it is.
  ///
  /// ```dart
  /// final collection = SeachableFirestoreCollectionProvider("user", searchText: "search");
  /// ```
  ///
  /// [path]: Collection path.
  /// [limit]: Limit count.
  /// [queryKey]: Key to search.
  /// [searchText]: The text to search for.
  /// [query]: Querying collections.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  SearchableFirestoreCollectionProvider(
    String path, {
    String queryKey = "@search",
    int limit = 500,
    String searchText,
    OrderBy orderBy = OrderBy.none,
    String orderByKey,
    OrderBy thenBy = OrderBy.none,
    String thenByKey,
  }) : super(
          (_) => SearchableFirestoreCollection.listen(
            path,
            limit: limit,
            queryKey: queryKey,
            searchText: searchText,
            orderBy: orderBy,
            thenBy: thenBy,
            orderByKey: orderByKey,
            thenByKey: thenByKey,
          ),
        );
}
