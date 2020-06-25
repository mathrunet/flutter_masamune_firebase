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
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;
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
  DocumentReference get _reference {
    if (this.__reference == null &&
        this.rawPath != null &&
        isNotEmpty(this.rawPath.path)) {
      this.__reference = this._app._db.document(this.rawPath.path);
    }
    return this.__reference;
  }

  DocumentReference __reference;
  StreamSubscription<DocumentSnapshot> _listener;

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
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
  static Future<FirestoreDocument> listen(String path) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
      return document.reload();
    }
    document = FirestoreDocument._(path: path);
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
  static Future<FirestoreDocument> createAsFuture(String path,
      [Map<String, dynamic> data]) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
      if (data != null) document.set(_convertData(path, data));
      return document.asFuture();
    }
    document = FirestoreDocument._(path: path, isTemporary: true);
    if (data != null) document.set(_convertData(path, data));
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
  static FirestoreDocument create(String path, [Map<String, dynamic> data]) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
      if (data != null) document.set(_convertData(path, data));
      return document;
    }
    document = FirestoreDocument._(path: path, isTemporary: true);
    if (data != null) document.set(_convertData(path, data));
    return document;
  }

  static FirestoreDocument _create(String path, [Map<String, dynamic> data]) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
      if (data != null) document.set(_convertData(path, data));
      return document;
    }
    document = FirestoreDocument._(path: path);
    if (data != null) document.set(_convertData(path, data));
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
    path = path?.replaceAll("https", "firestore")?.applyTags();
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
      Iterable<DataField> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order);
  static Iterable<DataField> _convertData(
      String path, Map<String, dynamic> data) {
    List<DataField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      for (MapEntry<String, FirestoreMetaFilter> tmp
          in FirestoreMeta.filter.entries) {
        value = tmp.value(key + tmp.key, value, data);
      }
      list.add(DataField(Paths.child(path, key), value));
    });
    return list;
  }

  /// Update document data.
  Future<T> reload<T extends IFirestoreChangeListener>() {
    this.init();
    this._constructListener();
    return this.future;
  }

  void _constructListener() async {
    try {
      if (this._listener != null) {
        await this._listener.cancel();
        this._listener = null;
      }
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._isRequireAuth && this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      this.__reference = this._app._db.document(this.rawPath.path);
      this._listener = this._reference.snapshots().listen(
          (snapshot) => this._done(
              snapshot.exists ? snapshot.data : MapPool.get(),
              (snapshot.data?.containsKey(Const.time) ?? false)
                  ? (snapshot.data[Const.time] as Timestamp)
                      .millisecondsSinceEpoch
                  : DateTime.now().frameMillisecondsSinceEpoch),
          onError: (error) {
        this.error(error);
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
    this.done();
  }

  void _setInternal(Map<String, dynamic> data) {
    if (data == null) return;
    data.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      for (MapEntry<String, FirestoreMetaFilter> tmp
          in FirestoreMeta.filter.entries) {
        value = tmp.value(key + tmp.key, value, data);
      }
      this[key] = value;
    });
    List<String> list = List.from(this.data.keys);
    for (String tmp in list) {
      if (!data.containsKey(tmp)) this.remove(tmp);
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
  Future<T> save<T extends IDataDocument>() {
    if (this.isDisposed) return this.future;
    assert(this._app != null);
    assert(this._auth != null);
    if (this._app == null || this._auth == null) {
      Log.error("Firebase has not been initialized or authenticated. "
          "Please execute after completing initialization and authentication.");
      return this.future;
    }
    this.init();
    this.registerUntemporary();
    this._isUpdating = true;
    this[Const.uid] = this.id;
    this[Const.time] = Firebase.serverTimestamp;
    this[FirestoreMeta.localeKey] = Localize.language;
    this._app._updateStack.addLast(this);
    return this.future;
  }

  Future _saveInternal(Transaction transaction) async {
    try {
      this._isUpdating = false;
      if (this._reference == null) {
        this.done();
        return;
      }
      if (this._isDelete) {
        await transaction.delete(this._reference);
        this.done();
        this.dispose();
      } else {
        Map<String, dynamic> dic = MapPool.get();
        this.data.forEach((key, value) {
          if (isEmpty(key)) return;
          dic[key] = value?.rawData;
        });
        await transaction.set(this._reference, dic);
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
    this.init();
    this._isDelete = true;
    this._isUpdating = true;
    this._app._updateStack.addLast(this);
    return this.future;
  }

  bool _isDelete = false;

  /// True if communicating with the server for saving or deleting.
  bool get isUpdating => this._isUpdating;
  bool _isUpdating = false;

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
    this._isUpdating = false;
    if (this._listener == null) return;
    this._listener.cancel();
    this._listener = null;
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