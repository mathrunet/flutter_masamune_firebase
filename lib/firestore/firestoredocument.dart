part of masamune.firebase;

/// Manage Firestore documents.
///
/// Basically listen, set the value if there is a value to update and [save()].
///
/// ```
/// FirestoreDocument doc = await FirestoreDocuemnt.listen( "user/user" );
/// String name = doc.getString( "name" );
/// doc["age"] = 18;
/// doc.save();
/// ```
class FirestoreDocument extends TaskDocument<DataField>
    with DataDocumentMixin<DataField>
    implements ITask, IDataDocument<DataField>, IFirestoreChangeListener {
  bool get _isRequireAuth => true;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreDocument._(
          path: path,
          isListenable: this.isListenable,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;
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
  DocumentReference get _reference {
    if (this.__reference == null &&
        this.rawPath != null &&
        isNotEmpty(this.rawPath.path)) {
      this.__reference = this._app._db.doc(this.rawPath.path);
    }
    return this.__reference;
  }

  DocumentReference __reference;
  List<String> _keysAsCounter;
  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot> _listener;
  Map<String, StreamSubscription> _subListener = MapPool.get();

  /// Manage Firestore documents.
  ///
  /// Basically listen, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// [path]: Document path.
  factory FirestoreDocument(String path) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Manage Firestore documents.
  /// Listen for data updates.
  ///
  /// Basically listen, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Request and listen to a document.
  ///
  /// [path]: Document path.
  /// [keysAsCounter]: A key used as a counter.
  static Future<FirestoreDocument> listen(String path,
      {List<String> keysAsCounter}) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) {
      if (!document.isListenable) document._isListenable = true;
      if (!document.isUpdatable) document._isUpdatable = true;
      if (keysAsCounter != null) document._keysAsCounter = keysAsCounter;
      return document.future;
    }
    document = FirestoreDocument._(
        path: path, isListenable: true, keysAsCounter: keysAsCounter);
    document._constructListener();
    return document.future;
  }

  /// Manage Firestore documents.
  /// Read the data only once.
  ///
  /// If you want to reload the data, use [reload()].
  ///
  /// Basically listen, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Request and listen to a document.
  ///
  /// [path]: Document path.
  /// [keysAsCounter]: A key used as a counter.
  static Future<FirestoreDocument> load(String path,
      {List<String> keysAsCounter}) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) {
      bool reload = false;
      if (document.isListenable) document._isListenable = false;
      if (!document.isUpdatable) document._isUpdatable = true;
      if (keysAsCounter != null &&
          !keysAsCounter.equals(document._keysAsCounter)) {
        reload = true;
        document._keysAsCounter = keysAsCounter;
      }
      return reload ? document.reload() : document.future;
    }
    document = FirestoreDocument._(path: path, keysAsCounter: keysAsCounter);
    document._constructListener();
    return document.future;
  }

  /// Manage Firestore documents.
  ///
  /// Basically listen, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Create a FirestoreDocument that has not yet been synchronized with the remote Firestore.
  ///
  /// [path]: Document path.
  /// [data]: Data set locally.
  /// [keysAsCounter]: A key used as a counter.
  static Future<FirestoreDocument> createAsFuture(String path,
      {Map<String, dynamic> data, List<String> keysAsCounter}) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) {
      if (document.isListenable) document._isListenable = false;
      if (!document.isUpdatable) document._isUpdatable = true;
      if (keysAsCounter != null) document._keysAsCounter = keysAsCounter;
      if (data != null) document.set(document._convertData(path, data));
      return document.asFuture();
    }
    document = FirestoreDocument._(
        path: path, isTemporary: true, keysAsCounter: keysAsCounter);
    if (data != null) document.set(document._convertData(path, data));
    document.done();
    return document.asFuture();
  }

  /// Manage Firestore documents.
  ///
  /// Basically listen, set the value if there is a value to update and [save()]
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Create a FirestoreDocument that has not yet been synchronized with the remote Firestore.
  ///
  /// [path]: Document path
  /// [data]: Data set locally
  static FirestoreDocument create(String path,
      {Map<String, dynamic> data, List<String> keysAsCounter}) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) {
      if (document.isListenable) document._isListenable = false;
      if (!document.isUpdatable) document._isUpdatable = true;
      if (keysAsCounter != null) document._keysAsCounter = keysAsCounter;
      if (data != null) document.set(document._convertData(path, data));
      return document;
    }
    document = FirestoreDocument._(
        path: path, isTemporary: true, keysAsCounter: keysAsCounter);
    if (data != null) document.set(document._convertData(path, data));
    document.done();
    return document;
  }

  static FirestoreDocument _create(String path,
      {Map<String, dynamic> data, List<String> keysAsCounter}) {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document != null) {
      if (document.isListenable) document._isListenable = false;
      if (!document.isUpdatable) document._isUpdatable = true;
      if (keysAsCounter != null) document._keysAsCounter = keysAsCounter;
      if (data != null) document.set(document._convertData(path, data));
      return document;
    }
    document = FirestoreDocument._(path: path, keysAsCounter: keysAsCounter);
    if (data != null) document.set(document._convertData(path, data));
    document.done();
    return document;
  }

  /// Manage Firestore documents.
  ///
  /// Basically listen, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// FirestoreDocument doc = await FirestoreDocuemnt.request( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Delete the document at the specified path.
  ///
  /// [path]: Document path to delete.
  static Future deleteAt(String path) async {
    path =
        Paths.removeQuery(path?.replaceAll("https", "firestore")?.applyTags());
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDocument document = PathMap.get<FirestoreDocument>(path);
    if (document == null) document = FirestoreDocument._(path: path);
    return document.delete();
  }

  FirestoreDocument._(
      {String path,
      bool isListenable = false,
      Iterable<DataField> children,
      bool isTemporary = false,
      List<String> keysAsCounter,
      int group = 0,
      int order = 10})
      : this._isListenable = isListenable,
        this._keysAsCounter = keysAsCounter,
        super(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order);

  /// Set the data.
  ///
  /// Protected data.
  ///
  /// [children]: List of data.
  @override
  @protected
  void set(Iterable<DataField> children) {
    super.set(children);
    if (this.isTemporary) return;
    this._app._addChild(this);
  }

  Iterable<DataField> _convertData(String path, Map<String, dynamic> data) {
    List<DataField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      for (MapEntry<String, FirestoreMetaFilter> tmp
          in FirestoreMeta.filter.entries) {
        value = tmp.value(key, value, data, this);
      }
      if (value is DataField) {
        String child = Paths.child(path, key);
        if (value.path == child)
          list.add(value);
        else
          list.add(value.clone(path: child, isTemporary: false));
      } else {
        if (value is GeoPoint) {
          value = FirestoreGeoData.fromGeoPoint(value);
        }
        list.add(DataField(Paths.child(path, key), value));
      }
    });
    return list;
  }

  /// Update document data.
  Future<T> reload<T extends IDataDocument>() {
    this.init();
    this._isUpdatable = true;
    this._constructListener();
    return this.future;
  }

  void _constructListener() async {
    try {
      if (this._listener != null) {
        await this._listener.cancel();
        this._listener = null;
      }
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (this._isRequireAuth && this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      this.__reference = this._app._db.doc(this.rawPath.path);
      this._listener = this._reference.snapshots().listen((snapshot) async {
        if (!this.isUpdatable) return;
        if (snapshot == null ||
            !snapshot.exists ||
            snapshot.data() == null ||
            snapshot.data().length <= 0) {
          this.done();
          this._isDisposable = true;
          this.dispose();
        } else {
          this._done(
              snapshot.exists ? snapshot.data() : MapPool.get(),
              (snapshot.data()?.containsKey(Const.time) ?? false)
                  ? (snapshot.data()[Const.time] as Timestamp)
                      .millisecondsSinceEpoch
                  : DateTime.now().frameMillisecondsSinceEpoch);
        }
      }, onError: (error) {
        this.reload();
      }, cancelOnError: true);
    } catch (e) {
      this.error(e.toString());
    }
  }

  void _done(Map<String, dynamic> data, int updatedTime) {
    if (this.isDone &&
        this.length == data.length &&
        updatedTime <= this.updatedTime) return;
    if (this.isUpdating) return;
    this.init();
    this._setInternal(data);
    if (this._keysAsCounter != null) this.useCounter(this._keysAsCounter);
    this.notifyUpdate();
    this.done();
    if (!this.isListenable) this._isUpdatable = false;
  }

  void _setInternal(Map<String, dynamic> data) {
    if (data == null) return;
    data.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      for (MapEntry<String, FirestoreMetaFilter> tmp
          in FirestoreMeta.filter.entries) {
        value = tmp.value(key, value, data, this);
      }
      if (value is GeoPoint) {
        this[key] = FirestoreGeoData.fromGeoPoint(value);
      } else {
        this[key] = value;
      }
    });
    List<String> list = List.from(this.data.keys);
    for (String tmp in list) {
      if (data.containsKey(tmp)) continue;
      if (this._subListener.containsKey(tmp)) continue;
      this.remove(tmp);
    }
    list.release();
    Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
  }

  /// Apply the changed document data to the remote Firestore.
  ///
  /// It may take up to 1 second or more.
  ///
  /// Use the [isUpdating] flag if you want to check if it is updating.
  @override
  Future<T> save<T extends IDataDocument>(
      {Map<String, dynamic> data, void builder(T document)}) {
    if (this.isDisposed) return this.future;
    assert(this._app != null);
    assert(this._auth != null);
    if (this._app == null || this._auth == null) {
      Log.error("Firebase has not been initialized or authenticated. "
          "Please execute after completing initialization and authentication.");
      return this.future;
    }
    data?.forEach((key, value) => this[key] = value);
    builder?.call(this as T);
    this.init();
    this.registerUntemporary();
    this._isUpdating = true;
    this[Const.uid] = this.id;
    this[Const.time] = FirebaseCore.serverTimestamp;
    this[FirestoreMeta.localeKey] = Localize.language;
    this
        ._app
        ._updateStack
        .removeWhere((element) => element == this || element.path == this.path);
    this._app._updateStack.add(this);
    if (!this.isTemporary) {
      this._app._addChild(this);
    }
    if (this._keysAsCounter != null) this.useCounter(this._keysAsCounter);
    return this.future;
  }

  Future _saveInternal(Transaction transaction) async {
    try {
      this._isUpdating = false;
      if (this._reference == null) {
        this.done();
        return;
      }
      if (this._isDelete && this.isDisposed) {
        transaction.delete(this._reference);
      } else {
        Map<String, dynamic> dic = MapPool.get();
        List<String> ignore = this.data[FirestoreMeta.ignoreKey]?.getList(null);
        DocumentSnapshot snapshot = await this._reference.get();
        if (snapshot == null || !snapshot.exists) {
          this.data.forEach((key, value) {
            if (isEmpty(key)) return;
            if (key.contains(Const.atmark)) return;
            if (ignore != null && ignore.contains(key)) return;
            Object val = value?.rawData;
            if (val is FirestoreGeoData) {
              dic["$key${FirestoreMeta.geoHashKey}"] = val.hash;
              dic[key] = val.geoPoint;
            } else if (val is GeoData) {
              FirestoreGeoData geoData = FirestoreGeoData.fromGeoData(val);
              dic["$key${FirestoreMeta.geoHashKey}"] = geoData.hash;
              dic[key] = geoData.geoPoint;
            } else if (val is GeoPoint) {
              FirestoreGeoData geoData = FirestoreGeoData.fromGeoPoint(val);
              dic["$key${FirestoreMeta.geoHashKey}"] = geoData.hash;
              dic[key] = geoData.geoPoint;
            } else {
              dic[key] = val;
            }
          });
          transaction.set(this._reference, dic);
        } else {
          this.data.forEach((key, value) {
            if (isEmpty(key)) return;
            if (key.contains(Const.atmark) ||
                (ignore != null && ignore.contains(key))) {
              if (snapshot.data().containsKey(key)) {
                dic[key] = snapshot.data()[key];
              }
              return;
            }
            Object val = value?.rawData;
            if (val is FirestoreGeoData) {
              dic["$key${FirestoreMeta.geoHashKey}"] = val.hash;
              dic[key] = val.geoPoint;
            } else if (val is GeoData) {
              FirestoreGeoData geoData = FirestoreGeoData.fromGeoData(val);
              dic["$key${FirestoreMeta.geoHashKey}"] = geoData.hash;
              dic[key] = geoData.geoPoint;
            } else if (val is GeoPoint) {
              FirestoreGeoData geoData = FirestoreGeoData.fromGeoPoint(val);
              dic["$key${FirestoreMeta.geoHashKey}"] = geoData.hash;
              dic[key] = geoData.geoPoint;
            } else {
              dic[key] = val;
            }
          });
          transaction.set(this._reference, dic);
        }
        dic.release();
        this.done();
      }
    } catch (e) {
      Log.error(e);
    }
  }

  /// Delete this FirestoreDocument path from the remote Firestore.
  ///
  /// This object itself is also [dispose()].
  ///
  /// It may take up to 1 second or more.
  ///
  /// Use the [isUpdating] flag if you want to check if it is updating.
  @override
  Future delete() {
    if (this.isDisposed) return this.future;
    assert(this._app != null);
    assert(this._auth != null);
    if (this._app == null || this._auth == null) {
      Log.error("Firebase has not been initialized or authenticated. "
          "Please execute after completing initialization and authentication.");
      return this.future;
    }
    this._isDisposable = true;
    this.dispose();
    this._isDelete = true;
    this._isUpdating = true;
    this._app._updateStack.add(this);
    return this.future;
  }

  bool _isDelete = false;

  /// True if the object can be destroyed.
  @override
  bool get isDisposable => this._isDisposable || this.isTemporary;
  bool _isDisposable = false;

  /// True if communicating with the server for saving or deleting.
  bool get isUpdating => this._isUpdating;
  bool _isUpdating = false;

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

  /// Adds a count listener to the specified key.
  ///
  /// [key]: Keys to listen.
  FirestoreDocument useCounter(List<String> keys) {
    if (keys == null || keys.length <= 0) return this;
    for (String key in keys) {
      if (this._subListener.containsKey(key)) continue;
      List ignore = this.getList(FirestoreMeta.ignoreKey, []);
      if (!ignore.contains(key)) {
        ignore.add(key);
        this[FirestoreMeta.ignoreKey] = ignore;
      }
      num count;
      Future task;
      this._subListener[key] =
          this._reference.collection(key).snapshots().listen((collection) {
        count = collection?.docs?.fold(
                0,
                (previousValue, element) =>
                    previousValue + (element?.data()["value"] ?? 0)) ??
            0;
        if (task != null) return;
        int time = this.containsKey("time") && this["time"] is Timestamp
            ? (this["time"] as Timestamp).millisecondsSinceEpoch
            : 0;
        int countAt =
            this.containsKey("@countAt") && this["@countAt"] is Timestamp
                ? (this["@countAt"] as Timestamp).millisecondsSinceEpoch
                : 0;
        if (this.containsKey(key) && (this.isUpdating || time > countAt)) {
          task = Future.microtask(() async {
            await Future.doWhile(() async {
              await Future.delayed(Config.frameTime);
              int time = this.containsKey("time") && this["time"] is Timestamp
                  ? (this["time"] as Timestamp).millisecondsSinceEpoch
                  : 0;
              int countAt =
                  this.containsKey("@countAt") && this["@countAt"] is Timestamp
                      ? (this["@countAt"] as Timestamp).millisecondsSinceEpoch
                      : 0;
              return this.containsKey(key) &&
                  (this.isUpdating || time > countAt);
            });
            this[key] = count;
            task = null;
            this.notifyUpdate();
          });
        } else {
          this[key] = count;
          task = null;
          this.notifyUpdate();
        }
      });
    }
    return this;
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
    this._isUpdating = false;
    this._app._removeChild(this);
    if (this._listener != null) {
      this._listener.cancel();
      this._listener = null;
    }
    this._subListener.forEach((key, value) => value?.cancel());
  }

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);

  /// Callback event when application quit.
  void onApplicationQuit() {
    super.onApplicationQuit();
    this._disposeInternal();
  }
}

/// Extension method for Future in FirestoreDocument.
extension FirestoreDocumentFutureExtension on Future<FirestoreDocument> {
  Future<FirestoreDocument> useCounter(List<String> keys) {
    if (this == null || keys == null || keys.length <= 0) return this;
    return this.then((path) {
      return path.useCounter(keys);
    });
  }
}
