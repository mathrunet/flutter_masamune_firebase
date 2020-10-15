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
        ISearchable,
        IFirestoreCollectionListener {
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
  FirebaseCore get _app {
    if (this.__app == null) this.__app = FirebaseCore(this.protocol);
    return this.__app;
  }

  FirebaseCore __app;
  FirestoreAuth get _auth {
    if (this.__auth == null) this.__auth = FirestoreAuth(this.protocol);
    return this.__auth;
  }

  FirestoreAuth __auth;
  List<_FirestoreCollectionListener> _listener = ListPool.get();

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
  /// Listen for data updates.
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
      bool reload = false;
      if (!collection.isListenable) collection._isListenable = true;
      if (!collection.isUpdatable) collection._isUpdatable = true;
      if (searchText != null && searchText != collection.searchText) {
        reload = true;
        collection._searchText = searchText;
      }
      if (queryKey != null && queryKey != collection.queryKey) {
        reload = true;
        collection._queryKey = queryKey;
      }
      if (limit != null && limit > 0 && limit != collection.limit) {
        reload = true;
        collection._limit = limit;
      }
      if (collection.isChanged(
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey)) reload = true;
      return reload ? collection.reload() : collection.future;
    }
    collection = SearchableFirestoreCollection._(
        path: path,
        queryKey: queryKey,
        isListenable: true,
        searchText: searchText,
        limit: limit,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._constructListener();
    return collection.future;
  }

  /// Perform a full text search in Firestore using the fields you created the map in Bigram.
  /// Read the data only once.
  ///
  /// If you want to reload the data, use [reload()].
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
  static Future<SearchableFirestoreCollection> load(String path,
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
      bool reload = false;
      if (collection.isListenable) collection._isListenable = false;
      if (!collection.isUpdatable) collection._isUpdatable = true;
      if (searchText != null && searchText != collection.searchText) {
        reload = true;
        collection._searchText = searchText;
      }
      if (queryKey != null && queryKey != collection.queryKey) {
        reload = true;
        collection._queryKey = queryKey;
      }
      if (limit != null && limit > 0 && limit != collection.limit) {
        reload = true;
        collection._limit = limit;
      }
      if (collection.isChanged(
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey)) reload = true;
      return reload ? collection.reload() : collection.future;
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
      bool isListenable = false,
      Iterable<FirestoreDocument> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : this._isListenable = isListenable,
        super(
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
    this._app._registerParent(this);
  }

  /// Search the collection with [searchText].
  ///
  /// [searchText]: Search text.
  Future search<T extends ISearchable>(String searchText) {
    this.init();
    this._searchText = searchText;
    this._isUpdatable = true;
    this._constructListener();
    return this.future;
  }

  /// Update document data.
  Future<T> reload<T extends IDataCollection>() {
    this.init();
    this._isUpdatable = true;
    this._constructListener();
    return this.future;
  }

  /// Read the following data.
  ///
  /// If you want to check whether the next data can be obtained,
  /// execute [canNext()].
  Future<T> next<T extends IDataCollection>() {
    if (!this.isDone) {
      Log.error("Loading is not finished yet.");
      return this.future;
    }
    this.init();
    this._isUpdatable = true;
    this._fatchNext();
    return this.future;
  }

  /// True if the next data is available.
  ///
  /// The next data is acquired by [next()].
  bool canNext() {
    return this._listener.length > 0 &&
        this._listener.last?.snapshot?.docs != null &&
        this._listener.last.snapshot.docs.length >= this.limit;
  }

  void _constructListener() async {
    if (isNotEmpty(this.searchText)) this._isSearching = true;
    try {
      if (this._listener.length > 0) {
        await Future.wait(this._listener.map((e) => e?.listener?.cancel()));
        this._listener.clear();
      }
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      _FirestoreCollectionListener listener = _FirestoreCollectionListener();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      listener.listener =
          listener.reference.snapshots().listen((snapshot) async {
        if (!this._isUpdatable) return;
        listener.snapshot = snapshot;
        listener.removed = snapshot.docChanges.mapAndRemoveEmpty((item) =>
            item?.type == DocumentChangeType.removed ? item?.doc?.id : null);
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        DocumentSnapshot prev = listener.last;
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc == null || !doc.exists) continue;
          data[doc.id] = doc.data();
          if (doc.data().containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data()[Const.time]) < 0)
              updatedTime = doc.data()[Const.time];
          }
          listener.last = doc;
        }
        if (prev != null && prev != listener.last) {
          await this._fetchAt(this._listener.indexOf(listener) + 1);
        }
        this._done(
            data,
            listener,
            updatedTime != null
                ? updatedTime.millisecondsSinceEpoch
                : DateTime.now().frameMillisecondsSinceEpoch);
      });
      this._listener.add(listener);
    } catch (e) {
      this.error(e.toString());
    }
  }

  void _fatchNext() async {
    if (isNotEmpty(this.searchText)) this._isSearching = true;
    try {
      if (this._listener.length <= 0) {
        this._constructListener();
        return;
      }
      _FirestoreCollectionListener last = this._listener.last;
      if (this.limit < 0 || last.snapshot.docs.length < this.limit) {
        this._isSearching = false;
        this.done();
        return;
      }
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      _FirestoreCollectionListener listener = _FirestoreCollectionListener();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      listener.reference =
          this._buildPositionInternal(listener.reference, last.last);
      listener.listener =
          listener.reference.snapshots().listen((snapshot) async {
        if (!this._isUpdatable) return;
        listener.snapshot = snapshot;
        listener.removed = snapshot.docChanges.mapAndRemoveEmpty((item) =>
            item?.type == DocumentChangeType.removed ? item?.doc?.id : null);
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        DocumentSnapshot prev = listener.last;
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc == null || !doc.exists) continue;
          data[doc.id] = doc.data();
          if (doc.data().containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data()[Const.time]) < 0)
              updatedTime = doc.data()[Const.time];
          }
          listener.last = doc;
        }
        if (prev != null && prev != listener.last) {
          await this._fetchAt(this._listener.indexOf(listener) + 1);
        }
        this._done(
            data,
            listener,
            updatedTime != null
                ? updatedTime.millisecondsSinceEpoch
                : DateTime.now().frameMillisecondsSinceEpoch);
      });
      this._listener.add(listener);
    } catch (e) {
      this.error(e.toString());
    }
  }

  Future _fetchAt(int index) async {
    try {
      if (index < 0 || this._listener.length <= index) return;
      _FirestoreCollectionListener listener = this._listener[index];
      if (listener == null) return;
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      await listener.reset();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      if (index > 0)
        listener.reference = this._buildPositionInternal(
            listener.reference, this._listener[index - 1].last);
      listener.listener =
          listener.reference.snapshots().listen((snapshot) async {
        if (!this._isUpdatable) return;
        listener.snapshot = snapshot;
        listener.removed = snapshot.docChanges.mapAndRemoveEmpty((item) =>
            item?.type == DocumentChangeType.removed ? item?.doc?.id : null);
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc == null || !doc.exists) continue;
          data[doc.id] = doc.data();
          if (doc.data().containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data()[Const.time]) < 0)
              updatedTime = doc.data()[Const.time];
          }
          listener.last = doc;
        }
        await this._fetchAt(index + 1);
        this._done(
            data,
            listener,
            updatedTime != null
                ? updatedTime.millisecondsSinceEpoch
                : DateTime.now().frameMillisecondsSinceEpoch);
      });
    } catch (e) {
      this.error(e.toString());
    }
  }

  void _done(Map<String, Map<String, dynamic>> data,
      _FirestoreCollectionListener listener, int updatedTime) {
    this._isSearching = false;
    if (this.isDone &&
        this.length == data.length &&
        updatedTime <= this.updatedTime) return;
    if (this.isUpdating) return;
    this.init();
    if (data != null) {
      listener.data = data;
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
        if (!this
            ._listener
            .any((element) => element?.data?.containsKey(doc.id) ?? false)) {
          if (this
              ._listener
              .any((element) => element?.removed?.contains(doc.id) ?? false)) {
            doc._isDisposable = true;
          }
          this.remove(doc);
          if (!doc.isDisposed) doc.notifyUpdate();
        }
      }
      Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
    }
    this.sort();
    this.notifyUpdate();
    this.done();
    data.release();
    if (!this.isListenable) this._isUpdatable = false;
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
      List<String> tmp = ListPool.get();
      Texts.bigram(this.searchText.toLowerCase())?.forEach((text) {
        if (tmp.contains(text)) return;
        tmp.add(text);
        fquery = fquery.where("${this.queryKey}.$text", isEqualTo: true);
      });
      tmp.release();
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

  Query _buildPositionInternal(Query fquery, DocumentSnapshot lastSnapshot) {
    if (lastSnapshot == null) return fquery;
    if (this.orderBy == OrderBy.none) return fquery;
    return fquery.startAfterDocument(lastSnapshot);
  }

  /// True if communicating with the server for saving or deleting.
  bool get isUpdating {
    for (FirestoreDocument doc in this.data.values) {
      if (doc == null) continue;
      if (doc.isUpdating) return true;
    }
    return false;
  }

  /// True if you are able to update.
  bool get isUpdatable => this._isUpdatable;
  bool _isUpdatable = true;

  /// True if you always listen for changes.
  bool get isListenable => this._isListenable;
  bool _isListenable = false;

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
    this._app._unregisterParent(this);
    if (this._listener.length <= 0) return;
    this._listener.forEach((e) => e?.listener?.cancel());
    this._listener.clear();
  }

  /// Callback event when application quit.
  void onApplicationQuit() {
    super.onApplicationQuit();
    this._disposeInternal();
  }

  // ignore: unused_element
  void _addChildInternal(FirestoreDocument document) {
    if (document == null) return;
    if (!this._queryInternal(document)) return;
    if (!this.data.containsKey(document.id)) this.data[document.id] = document;
    this.notifyUpdate();
  }

  bool _queryInternal(FirestoreDocument document) {
    if (isEmpty(this.queryKey) ||
        isEmpty(this.searchText) ||
        this.searchText.length <= 1) {
      return false;
    } else {
      final map = document.getMap(this.queryKey, null);
      if (map == null) return false;
      return Texts.bigram(this.searchText.toLowerCase())
              ?.any((element) => map.containsKey(element)) ??
          false;
    }
  }

  // ignore: unused_element
  void _removeChildInternal(FirestoreDocument document) {
    if (document == null) return;
    if (!document.isDisposable) return;
    if (!this.data.containsKey(document.id)) return;
    this.data.remove(document.id);
    this.notifyUpdate();
  }
}
