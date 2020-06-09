part of masamune.firebase;

/// Perform a full text search in Firestore using the fields you created the map in Bigram.
///
/// For details, please see the URL below.
///
/// https://qiita.com/oukayuka/items/d3cee72501a55e8be44a
///
/// ```
/// SearchableFirestoreCollection col = await SearchableFirestoreCollection.listen( "user/user" );
/// for( FirestoreDocument doc in col ) { ... }
/// String name = doc.getString( "name" );
/// newDocument["age"] = 18;
/// newDocument.save();
/// ```
class SearchableFirestoreCollection extends TaskCollection<FirestoreDocument>
    with SortableDataCollectionMixin<FirestoreDocument>
    implements
        ITask,
        IDataCollection<FirestoreDocument>,
        IFirestoreChangeListener,
        ISearchable {
  /// Maximum search results.
  int get limit => this._limit;
  int _limit = 500;

  /// The key that contains the Bigram data for the search.
  String get queryKey => this._queryKey;
  String _queryKey = "@search";

  /// Current search text.
  String get searchText => this._searchText;
  String _searchText;

  /// True while searching.
  bool get isSearching => this._isSearching;
  bool _isSearching;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<SearchableFirestoreCollection>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      SearchableFirestoreCollection._(
          path: path,
          searchText: this.searchText,
          isTemporary: isTemporary,
          queryKey: this.queryKey,
          group: group,
          order: order,
          orderBy: this.orderBy,
          thenBy: this.thenBy,
          orderByKey: this.orderByKey,
          thenByKey: this.thenByKey) as T;
  Firebase get _app {
    if (this.__app == null) this.__app = Firebase(this.protocol);
    return this.__app;
  }

  Firebase __app;
  FirestoreAuth get _auth {
    if (this.__auth == null) this.__auth = FirestoreAuth(this.protocol);
    return this.__auth;
  }

  FirestoreAuth __auth;
  Query get _reference {
    if (this.__reference == null &&
        this.rawPath != null &&
        isNotEmpty(this.rawPath.path)) {
      this.__reference = this._app._db.collection(this.rawPath.path);
    }
    return this.__reference;
  }

  Query __reference;
  StreamSubscription<QuerySnapshot> _listener;

  /// Perform a full text search in Firestore using the fields you created the map in Bigram.
  ///
  /// For details, please see the URL below.
  ///
  /// https://qiita.com/oukayuka/items/d3cee72501a55e8be44a
  ///
  /// ```
  /// SearchableFirestoreCollection col = await SearchableFirestoreCollection.listen( "user/user" );
  /// for( FirestoreDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  factory SearchableFirestoreCollection(String path) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 1));
    if (length <= 0 || length % 2 != 1) {
      Log.error("Path is not document path.");
      return null;
    }
    SearchableFirestoreCollection collection =
        PathMap.get<SearchableFirestoreCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Perform a full text search in Firestore using the fields you created the map in Bigram.
  ///
  /// For details, please see the URL below.
  ///
  /// https://qiita.com/oukayuka/items/d3cee72501a55e8be44a
  ///
  /// ```
  /// SearchableFirestoreCollection col = await SearchableFirestoreCollection.listen( "user/user" );
  /// for( FirestoreDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  /// [queryKey]: Key to search.
  /// [searchText]: The text to search for.
  /// [query]: Querying collections.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static Future<SearchableFirestoreCollection> listen(String path,
      {String queryKey = "@search",
      int limit = 500,
      String searchText,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 1));
    if (length <= 0 || length % 2 != 1) {
      Log.error("Path is not document path.");
      return Future.delayed(Duration.zero);
    }
    SearchableFirestoreCollection collection =
        PathMap.get<SearchableFirestoreCollection>(path);
    if (collection != null) {
      if (searchText != null) collection._searchText = searchText;
      if (queryKey != null) collection._queryKey = queryKey;
      if (limit > 0) collection._limit = limit;
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      return collection.reload();
    }
    collection = SearchableFirestoreCollection._(
        path: path,
        queryKey: queryKey,
        searchText: searchText,
        limit: limit,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._constructListener();
    return collection.future;
  }

  SearchableFirestoreCollection._(
      {String path,
      String searchText,
      String queryKey = "@search",
      int limit = 500,
      Iterable<FirestoreDocument> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this._searchText = searchText;
    this._limit = limit;
    this._queryKey = queryKey;
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
  }

  /// Search the collection with [searchText].
  ///
  /// [searchText]: Search text.
  Future search<T extends ISearchable>(String searchText) {
    this.init();
    this._searchText = searchText;
    this._constructListener();
    return this.future;
  }

  /// Update document data.
  Future<T> reload<T extends IFirestoreChangeListener>() {
    this.init();
    this._constructListener();
    return this.future;
  }

  void _constructListener() async {
    if (isNotEmpty(this.searchText)) this._isSearching = true;
    try {
      if (this._listener != null) {
        await this._listener.cancel();
        this._listener = null;
      }
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      this.__reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      this._listener = this._reference.snapshots().listen((snapshot) {
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        for (DocumentSnapshot doc in snapshot.documents) {
          if (doc == null || !doc.exists) continue;
          data[doc.documentID] = doc.data;
          if (doc.data.containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data[Const.time]) < 0)
              updatedTime = doc.data[Const.time];
          }
        }
        this._done(
            data,
            updatedTime != null
                ? updatedTime.millisecondsSinceEpoch
                : DateTime.now().frameMillisecondsSinceEpoch);
      });
    } catch (e) {
      this.error(e.toString());
    }
  }

  void _done(Map<String, Map<String, dynamic>> data, int updatedTime) {
    this._isSearching = false;
    if (this.isDone &&
        this.length == data.length &&
        updatedTime <= this.updatedTime) return;
    if (this.isUpdating) return;
    this.init();
    if (data != null) {
      List<FirestoreDocument> addData = ListPool.get();
      data.forEach((key, value) {
        if (isEmpty(key) || value == null) return;
        FirestoreDocument doc =
            this.data.firstWhere((k, v) => v?.id == key, orElse: () => null);
        if (doc != null) {
          doc._setInternal(value);
        } else {
          addData.add(
              FirestoreDocument._create(Paths.child(this.path, key), value));
        }
        value.release();
      });
      this._setInternal(addData);
      for (int i = this.data.length - 1; i >= 0; i--) {
        FirestoreDocument doc = this.data[i];
        if (doc == null) continue;
        if (!data.containsKey(doc.id)) this.remove(doc);
      }
      Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
    }
    this.sort();
    this.done();
    data.release();
  }

  void _setInternal(Iterable<FirestoreDocument> children) {
    if (children != null) {
      for (FirestoreDocument doc in children) {
        if (doc == null) continue;
        this.setInternal(doc);
      }
    }
  }

  /// Apply the changed collection data to the remote Firestore.
  ///
  /// It may take up to 1 second or more.
  ///
  /// Use the [isUpdating] flag if you want to check if it is updating.
  void save() {
    if (this.isDisposed) return;
    for (FirestoreDocument tmp in this.data.values) {
      if (tmp == null) continue;
      tmp.save();
    }
  }

  /// Delete this FirestoreCollection path from the remote Firestore.
  ///
  /// This object itself is also [dispose()].
  ///
  /// It may take up to 1 second or more.
  ///
  /// Use the [isUpdating] flag if you want to check if it is updating.
  void delete() {
    if (this.isDisposed) return;
    for (int i = this.data.length - 1; i >= 0; i--) {
      FirestoreDocument doc = this.data[i];
      if (doc == null) continue;
      doc.delete();
      this.data.removeAt(i);
    }
  }

  Query _buildQueryInternal(CollectionReference reference) {
    if (reference == null) return reference;
    Query fquery = reference;
    if (isEmpty(this.queryKey) ||
        isEmpty(this.searchText) ||
        this.searchText.length <= 1) {
      fquery = _buildOrderInternal(fquery);
    } else {
      Texts.bigram(this.searchText.toLowerCase())?.forEach((text) {
        fquery = fquery.where("${this.queryKey}.$text", isEqualTo: true);
      });
    }
    return fquery.limit(this.limit);
  }

  Query _buildOrderInternal(Query fquery) {
    switch (this.orderBy) {
      case OrderBy.asc:
        fquery = fquery.orderBy(this.orderByKey);
        break;
      case OrderBy.desc:
        fquery = fquery.orderBy(this.orderByKey, descending: true);
        break;
      default:
        break;
    }
    return fquery;
  }

  /// True if communicating with the server for saving or deleting.
  bool get isUpdating {
    for (FirestoreDocument doc in this.data.values) {
      if (doc == null) continue;
      if (doc.isUpdating) return true;
    }
    return false;
  }

  /// Get the protocol of the path.
  @override
  String get protocol {
    if (isEmpty(this.rawPath.scheme)) return "firestore";
    return this.rawPath.scheme;
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @override
  void dispose() {
    super.dispose();
    this._disposeInternal();
  }

  void _disposeInternal() {
    this.__reference = null;
    if (this._listener == null) return;
    this._listener.cancel();
    this._listener = null;
  }

  /// Callback event when application quit.
  void onApplicationQuit() {
    super.onApplicationQuit();
    this._disposeInternal();
  }
}
