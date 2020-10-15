part of masamune.firebase;

/// Class for handling data of Firebase Remote Config as a document.
///
/// You cannot save from here.
///
/// ```
/// RemoteConfigDocument doc = await RemoteConfigDocument.listen( "config" );
/// String name = doc.getString( "name" );
/// ```
class RemoteConfigDocument extends FirestoreDocument {
  @override
  bool get _isRequireAuth => false;
  static RemoteConfig get _config {
    return __config;
  }

  static RemoteConfig __config;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<RemoteConfigDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      RemoteConfigDocument._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;

  /// Class for handling data of Firebase Remote Config as a document.
  ///
  /// You cannot save from here.
  ///
  /// ```
  /// RemoteConfigDocument doc = await RemoteConfigDocument.listen( "config" );
  /// String name = doc.getString( "name" );
  /// ```
  ///
  /// [path]: Document path.
  factory RemoteConfigDocument(String path) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    RemoteConfigDocument document = PathMap.get<RemoteConfigDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [load()] first.");
    return null;
  }

  /// Class for handling data of Firebase Remote Config as a document.
  ///
  /// You cannot save from here.
  ///
  /// ```
  /// RemoteConfigDocument doc = await RemoteConfigDocument.listen( "config" );
  /// String name = doc.getString( "name" );
  /// ```
  ///
  /// Request to a document.
  ///
  /// [path]: Document path.
  static Future<RemoteConfigDocument> load(String path) {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    RemoteConfigDocument document = PathMap.get<RemoteConfigDocument>(path);
    if (document != null) {
      return document.reload();
    }
    document = RemoteConfigDocument._(path: path);
    document._constructListener();
    return document.future;
  }

  RemoteConfigDocument._(
      {String path,
      Iterable<DataField> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super._(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order);
  @override
  void _constructListener() async {
    try {
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (_config == null) __config = await RemoteConfig.instance;
      _config
          .setConfigSettings(RemoteConfigSettings(debugMode: Log.isDebugBuild));
      _config.removeListener(this._onUpdate);
      _config.addListener(this._onUpdate);
      await _config.fetch();
      await _config.activateFetched();
    } catch (e) {
      this.error(e.toString());
    }
  }

  dynamic _format(String value) {
    if (isEmpty(value)) return value;
    int i = int.tryParse(value);
    if (i != null) return i;
    double d = double.tryParse(value);
    if (d != null) return d;
    if (value.toLowerCase() == "true") return true;
    if (value.toLowerCase() == "false") return false;
    return value;
  }

  void _onUpdate() {
    Map<String, RemoteConfigValue> data = _config.getAll();
    if (data != null) {
      data.forEach((key, value) {
        if (isEmpty(key) || value == null) return;
        this[key] = this._format(value.toString());
      });
    }
    this.done();
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
    if (_config == null) return;
    _config.removeListener(this._onUpdate);
  }

  /// Callback event when application quit.
  void onApplicationQuit() {
    super.onApplicationQuit();
    this._disposeInternal();
    _config.dispose();
  }
}
