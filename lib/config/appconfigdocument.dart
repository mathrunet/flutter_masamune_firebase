part of masamune.firebase;

/// Firestore document that stores the application config.
///
/// Usually it is stored in [app/config] and updated from the console.
///
/// ```
/// AppConfigDocument doc = await AppConfigDocument.listen( );
/// String name = doc.getString( "name" );
/// ```
class AppConfigDocument extends FirestoreDocument {
  @override
  bool get _isRequireAuth => false;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<AppConfigDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      AppConfigDocument._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;

  /// Firestore document that stores the application config.
  ///
  /// Usually it is stored in[app/config]and updated from the console.
  ///
  /// ```
  /// AppConfigDocument doc = await AppConfigDocument.listen( );
  /// String name = doc.getString( "name" );
  /// ```
  ///
  /// [path]: Document path.
  factory AppConfigDocument(String path) {
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
    AppConfigDocument document = PathMap.get<AppConfigDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Firestore document that stores the application config.
  ///
  /// Usually it is stored in[app/config]and updated from the console.
  ///
  /// ```
  /// AppConfigDocument doc = await AppConfigDocument.listen( );
  /// String name = doc.getString( "name" );
  /// ```
  ///
  /// Request and listen to a document.
  ///
  /// [path]: Document path.
  static Future<AppConfigDocument> listen({String path = "app/config"}) {
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
    AppConfigDocument document = PathMap.get<AppConfigDocument>(path);
    if (document != null) {
      return document.future;
    }
    document = AppConfigDocument._(path: path);
    document._constructListener();
    return document.future;
  }

  AppConfigDocument._(
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
}
