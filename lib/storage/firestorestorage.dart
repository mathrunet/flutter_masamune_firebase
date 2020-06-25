part of masamune.firebase;

/// Class to upload files to Firebase / Firestore storage.
///
/// For download, specify the URL to download.
///
/// ```
/// await FirestoreStorage.upload( "assets/image.png", file );
/// ```
class FirestoreStorage extends TaskUnit {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreStorage>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreStorage._(
          path: path,
          storageBucket: this.storageBucket,
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
  FirebaseStorage get _storage {
    if (this.__storage == null && this._app != null) {
      this.__storage = isEmpty(this.storageBucket)
          ? FirebaseStorage.instance
          : FirebaseStorage(
              app: this._app.app, storageBucket: this.storageBucket);
    }
    return __storage;
  }

  FirebaseStorage __storage;
  StorageReference get _reference {
    if (this.__reference == null &&
        this._storage != null &&
        isNotEmpty(this.rawPath.path)) {
      this.__reference = this._storage.ref().child(this.rawPath.path);
    }
    return this.__reference;
  }

  StorageReference __reference;

  /// Firebase Storage bucket domain.
  String get storageBucket => this._storageBucket;
  String _storageBucket;

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
  factory FirestoreStorage(String path) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    FirestoreStorage unit = PathMap.get<FirestoreStorage>(path);
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [upload()] first.");
    return null;
  }

  /// Perform upload.
  ///
  /// Put the file to be uploaded in [File].
  ///
  /// [path]: Upload destination path.
  /// [file]: File to upload.
  /// [storageBucket]: Storage bucket path.
  /// [timeout]: Timeout time.
  static Future<FirestoreStorage> upload(String path, File file,
      {String storageBucket, Duration timeout = Const.timeout}) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    assert(file != null);
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (file == null) {
      Log.error("File is invalid.");
      return Future.delayed(Duration.zero);
    }
    FirestoreStorage unit = PathMap.get<FirestoreStorage>(path);
    if (unit != null) {
      if (isNotEmpty(storageBucket)) unit._storageBucket = storageBucket;
      return unit.reUpload(file, timeout: timeout);
    }
    unit = FirestoreStorage._(path: path, storageBucket: storageBucket);
    unit._upload(file, timeout);
    return unit.future;
  }

  FirestoreStorage._(
      {String path, String storageBucket, int group = 0, int order = 10})
      : super(path: path, group: group, order: order) {
    this._storageBucket = storageBucket;
  }

  /// Upload the file again.
  ///
  /// [file]: File to upload.
  /// [timeout]: Timeout time.
  Future<FirestoreStorage> reUpload(File file,
      {Duration timeout = Const.timeout}) {
    assert(file != null);
    if (file == null) {
      Log.error("File is invalid.");
      return null;
    }
    this.init();
    this._upload(file, timeout);
    return this.future;
  }

  Future _upload(File file, Duration timeout) async {
    try {
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      if (this._app == null || this._auth == null) {
        this.error("Firebase is not initialized and authenticated.");
        return;
      }
      this.__storage = isEmpty(this.storageBucket)
          ? FirebaseStorage.instance
          : FirebaseStorage(
              app: this._app.app, storageBucket: this.storageBucket);
      this.__reference = this._storage.ref().child(this.rawPath.path);
      StorageUploadTask uploadTask = this.__reference.putFile(file);
      StorageTaskSnapshot snapshot =
          await uploadTask.onComplete.timeout(timeout);
      if (isNotEmpty(snapshot.error)) {
        this.error("Upload failed.");
        return;
      }
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Get the protocol of the path.
  @override
  String get protocol => "firestore";
}
