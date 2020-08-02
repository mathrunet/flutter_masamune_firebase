part of masamune.firebase;

/// Get the Firestore collection.
///
/// Normally retrieve 200 documents from the path,
/// but you can change the search criteria by specifying [query].
///
/// ```
/// FirestoreCollection col = await FirestoreCollection.listen( "user/user" );
/// for( FirestoreDocument doc in col ) { ... }
/// String name = doc.getString( "name" );
/// newDocument["age"] = 18;
/// newDocument.save();
/// ```
class FirestoreCollection extends TaskCollection<FirestoreDocument>
    with SortableDataCollectionMixin<FirestoreDocument>
    implements
        ITask,
        IDataCollection<FirestoreDocument>,
        IFirestoreChangeListener,
        IFirestoreCollection {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreCollection>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreCollection._(
          path: path,
          isTemporary: isTemporary,
          group: group,
          order: order,
          query: this.query,
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
  List<_FirestoreCollectionListener> _listener = ListPool.get();

  /// Get the Firestore collection.
  ///
  /// Normally retrieve 200 documents from the path,
  /// but you can change the search criteria by specifying [query].
  ///
  /// ```
  /// FirestoreCollection col = await FirestoreCollection.listen( "user/user" );
  /// for( FirestoreDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  factory FirestoreCollection(String path) {
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
    FirestoreCollection collection = PathMap.get<FirestoreCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Get the Firestore collection.
  ///
  /// Normally retrieve 200 documents from the path,
  /// but you can change the search criteria by specifying [query].
  ///
  /// ```
  /// FirestoreCollection col = await FirestoreCollection.listen( "user/user" );
  /// for( FirestoreDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  /// [query]: Querying collections.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static Future<FirestoreCollection> listen(String path,
      {FirestoreQuery query,
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
    FirestoreCollection collection = PathMap.get<FirestoreCollection>(path);
    if (collection != null) {
      if (query != null) collection.query = query;
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      return collection.reload();
    }
    collection = FirestoreCollection._(
        path: path,
        query: query,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._constructListener();
    return collection.future;
  }

  FirestoreCollection._(
      {String path,
      Iterable<FirestoreDocument> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10,
      FirestoreQuery query,
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
    if (query != null) this.query = query;
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
  }

  /// Update document data.
  Future<T> reload<T extends IDataCollection>() {
    this.init();
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
    this._fetchNext();
    return this.future;
  }

  /// True if the next data is available.
  ///
  /// The next data is acquired by [next()].
  bool canNext() {
    return this._listener.length > 0 &&
        this._listener.last?.snapshot?.documents != null &&
        this._listener.last.snapshot.documents.length >= this.query.limit;
  }

  void _constructListener() async {
    try {
      if (this._listener.length > 0) {
        await Future.wait(this._listener.map((e) => e?.listener?.cancel()));
        this._listener.clear();
      }
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      if (this.query != null && this.query.type == FirestoreQueryType.empty) {
        this.clear();
        this.notifyUpdate();
        this.done();
        return;
      }
      _FirestoreCollectionListener listener = _FirestoreCollectionListener();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      listener.listener = listener.reference.snapshots().listen((snapshot) {
        listener.snapshot = snapshot;
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        DocumentSnapshot prev = listener.last;
        for (DocumentSnapshot doc in snapshot.documents) {
          if (doc == null || !doc.exists) continue;
          data[doc.documentID] = doc.data;
          if (doc.data.containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data[Const.time]) < 0)
              updatedTime = doc.data[Const.time];
          }
          listener.last = doc;
        }
        if (prev != null && prev != listener.last) {
          this._fetchAt(this._listener.indexOf(listener) + 1);
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

  void _fetchNext() async {
    try {
      if (this._listener.length <= 0) {
        this._constructListener();
        return;
      }
      _FirestoreCollectionListener last = this._listener.last;
      if (this.query == null ||
          this.query.limit < 0 ||
          last.snapshot.documents.length < this.query.limit) {
        this.done();
        return;
      }
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      _FirestoreCollectionListener listener = _FirestoreCollectionListener();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      listener.reference =
          this._buildPositionInternal(listener.reference, last.last);
      listener.listener = listener.reference.snapshots().listen((snapshot) {
        listener.snapshot = snapshot;
        Timestamp updatedTime;
        Map<String, Map<String, dynamic>> data = MapPool.get();
        DocumentSnapshot prev = listener.last;
        for (DocumentSnapshot doc in snapshot.documents) {
          if (doc == null || !doc.exists) continue;
          data[doc.documentID] = doc.data;
          if (doc.data.containsKey(Const.time)) {
            if (updatedTime == null ||
                updatedTime.compareTo(doc.data[Const.time]) < 0)
              updatedTime = doc.data[Const.time];
          }
          listener.last = doc;
        }
        if (prev != null && prev != listener.last) {
          this._fetchAt(this._listener.indexOf(listener) + 1);
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
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      await listener.reset();
      listener.reference =
          this._buildQueryInternal(this._app._db.collection(this.rawPath.path));
      if (index > 0)
        listener.reference = this._buildPositionInternal(
            listener.reference, this._listener[index - 1].last);
      listener.listener = listener.reference.snapshots().listen((snapshot) {
        listener.snapshot = snapshot;
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
          listener.last = doc;
        }
        this._fetchAt(index + 1);
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
            .any((element) => element?.data?.containsKey(doc.id) ?? false))
          this.remove(doc);
      }
      Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
    }
    this.sort();
    this.notifyUpdate();
    this.done();
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
    }
    this.clear();
  }

  Query _buildQueryInternal(CollectionReference reference) {
    if (this.query == null || reference == null || isEmpty(this.query.key))
      return reference;
    Query fquery = reference;
    switch (this.query.type) {
      case FirestoreQueryType.equalTo:
        if (this.query.value != null)
          fquery = fquery.where(this.query.key, isEqualTo: this.query.value);
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.higherThan:
        if (this.query.value != null)
          fquery = fquery.where(this.query.key,
              isGreaterThanOrEqualTo: this.query.value);
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.lowerThan:
        if (this.query.value != null)
          fquery = fquery.where(this.query.key,
              isLessThanOrEqualTo: this.query.value);
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.range:
        if (this.query.value is Range)
          fquery = fquery
              .where(this.query.key,
                  isGreaterThanOrEqualTo: this.query.value.min)
              .where(this.query.key, isLessThanOrEqualTo: this.query.value.max);
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.arrayContains:
        if (this.query.value != null)
          fquery =
              fquery.where(this.query.key, arrayContains: this.query.value);
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.arrayContainsAny:
        if (this.query.contains != null && this.query.contains.length > 0) {
          fquery = fquery.where(this.query.key,
              arrayContainsAny: this.query.contains);
        }
        fquery = this._buildOrderInternal(fquery);
        break;
      case FirestoreQueryType.inArray:
        if (this.query.contains != null && this.query.contains.length > 0) {
          fquery = fquery.where(this.query.key, whereIn: this.query.contains);
        }
        fquery = this._buildOrderInternal(fquery);
        break;
      default:
        break;
    }
    return fquery;
  }

  Query _buildOrderInternal(Query fquery) {
    switch (this.query.orderBy) {
      case OrderBy.asc:
        fquery = (this.query.limit < 0)
            ? fquery.orderBy(this.query.orderByKey ?? this.query.key)
            : fquery
                .orderBy(this.query.orderByKey ?? this.query.key)
                .limit(this.query.limit);
        break;
      case OrderBy.desc:
        fquery = (this.query.limit < 0)
            ? fquery.orderBy(this.query.orderByKey ?? this.query.key,
                descending: true)
            : fquery
                .orderBy(this.query.orderByKey ?? this.query.key,
                    descending: true)
                .limit(this.query.limit);
        break;
      default:
        switch (this.orderBy) {
          case OrderBy.asc:
            fquery = (this.query.limit < 0)
                ? fquery.orderBy(this.query.key ?? this.orderByKey)
                : fquery
                    .orderBy(this.query.key ?? this.orderByKey)
                    .limit(this.query.limit);
            break;
          case OrderBy.desc:
            fquery = (this.query.limit < 0)
                ? fquery.orderBy(this.query.key ?? this.orderByKey,
                    descending: true)
                : fquery
                    .orderBy(this.query.key ?? this.orderByKey,
                        descending: true)
                    .limit(this.query.limit);
            break;
          default:
            break;
        }
        break;
    }
    return fquery;
  }

  Query _buildLimitInternal(Query fquery) {
    if (this.query.limit < 0) return fquery;
    return fquery.limit(this.query.limit);
  }

  Query _buildPositionInternal(Query fquery, DocumentSnapshot lastSnapshot) {
    if (lastSnapshot == null) return fquery;
    if (this.query.orderBy == OrderBy.none) return fquery;
    return fquery.startAfterDocument(lastSnapshot);
  }

  /// Set the query.
  ///
  /// After setting the query, execute [reload()] to reflect the setting.
  FirestoreQuery query = FirestoreQuery();

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

  /// Order for sorting.
  @override
  OrderBy get orderBy {
    if (this.query == null || this.query.orderBy == OrderBy.none)
      return super.orderBy;
    return this.query.orderBy;
  }

  /// Compare key for sorting.
  @override
  String get orderByKey {
    if (this.query == null || this.query.orderBy == OrderBy.none)
      return super.orderByKey;
    return this.query.orderByKey ?? this.query.key ?? this.orderByKey;
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
    if (this._listener.length <= 0) return;
    this._listener.forEach((e) => e?.listener?.cancel());
    this._listener.clear();
  }

  /// Callback event when application quit.
  void onApplicationQuit() {
    super.onApplicationQuit();
    this._disposeInternal();
  }
}
