part of masamune.firebase;

/// Class for managing Firebase applications.
///
/// Please initialize with [Firebase.initialize()] or [Firebase.configure()] when launching the app.
class Firebase extends TaskUnit {
  /// Get server timestamp.
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<Firebase>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      Firebase._(path: path) as T;
  Timer _timer;

  /// Firebase application.
  FirebaseApp get app => this._app;
  FirebaseApp _app;

  /// Firebase options.
  FirebaseOptions get options => this._options;
  FirebaseOptions _options;
  Firestore _db;
  Queue<FirestoreDocument> _updateStack = QueuePool.get();
  void _startUpdate() {
    if (this._timer != null) return;
    this._timer = Timer.periodic(Config.periodicExecutionTime, (timer) async {
      if (this._updateStack.length <= 0) return;
      await this._db.runTransaction((transaction) async {
        FirestoreDocument doc;
        List<FirestoreDocument> applied = ListPool.get();
        while (this._updateStack.length > 0 &&
            (doc = this._updateStack.removeLast()) != null) {
          if (applied.contains(doc)) continue;
          doc._saveInternal(transaction);
          applied.add(doc);
        }
        applied.release();
      });
    });
  }

  /// Search for an instance of Firebase from [protocol].
  ///
  /// [protocol]: Protocol.
  factory Firebase([String protocol]) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    Firebase unit = PathMap.get<Firebase>(path);
    if (unit != null) return unit;
    unit = PathMap.get<Firebase>(Texts.format(_systemPath, [Const.empty]));
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. First you need to do like [initialize()].");
    return null;
  }
  static const String _systemPath = "system://database/%s";

  /// Check if the Firestore information is being updated.
  ///
  /// True if updating.
  ///
  /// Firestore can be updated only at least every 1 second,
  /// so it is better to use this to perform processing during update.
  static bool get isUpdating {
    List<FirestoreDocument> docs = PathMap.getAll<FirestoreDocument>();
    if (docs == null) return false;
    for (FirestoreDocument doc in docs) {
      if (doc == null) continue;
      if (doc.isUpdating) return true;
    }
    docs.release();
    return false;
  }

  /// Class for managing Firebase applications.
  ///
  /// Please initialize with [Firebase.initialize()] or [Firebase.configure()] when launching the app.
  ///
  /// Use the settings in the default app [google-services.json] or [GoogleService-Info.plist].
  ///
  /// [timeout]: Timeout time.
  static Future<Firebase> initialize({Duration timeout = Const.timeout}) =>
      Firebase.configure(timeout: timeout);

  /// Class for managing Firebase applications.
  ///
  /// Please initialize with [Firebase.initialize()] or [Firebase.configure()] when launching the app.
  ///
  /// Launch with name and options.
  ///
  /// [protocol]: Firebase name.
  /// [options]: Firebase startup options.
  /// [timeout]: Timeout time.
  static Future<Firebase> configure(
      {String protocol,
      FirebaseOptions options,
      Duration timeout = Const.timeout}) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    Firebase unit = PathMap.get<Firebase>(path);
    if (unit != null) return unit.future;
    unit = Firebase._(path: path);
    unit._createDatabaseProcess(protocol, options, timeout);
    return unit.future;
  }

  Firebase._({String path}) : super(path: path, group: -1);
  void _createDatabaseProcess(
      String protocol, FirebaseOptions options, Duration timeout) async {
    try {
      if (isEmpty(protocol) ||
          isEmpty(options) ||
          protocol == Protocol.system ||
          protocol == "firestore") {
        this._app = FirebaseApp.instance;
        this._db = Firestore(app: this._app);
      } else {
        this._app =
            await FirebaseApp.configure(name: protocol, options: options)
                .timeout(timeout);
        this._db = Firestore(app: this._app);
      }
      if (this._app == null || this._db == null) {
        this.error("FirebaseApp is not found.");
      } else {
        this._options = await this._app.options;
        this._startUpdate();
        this.done();
      }
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// True if the object is temporary data.
  @override
  bool get isTemporary => false;

  /// Get the protocol of the path.
  @override
  String get protocol => "firestore";
}
