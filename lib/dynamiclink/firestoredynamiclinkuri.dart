part of masamune.firebase;

/// Create a URL for Dynamic Link.
///
/// Create a URL to access [path].
class FirestoreDynamicLinkURI extends Task<Uri> implements ITask {
  /// Rest API URL.
  static const String restAPIURL =
      "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=%s";

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreDynamicLinkURI>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreDynamicLinkURI._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;
  Firebase get _app {
    if (this.__app == null) this.__app = Firebase(this.protocol);
    return this.__app;
  }

  Firebase __app;
  FirebaseDynamicLinks get _dynamicLink {
    if (this.__dynamicLink == null)
      this.__dynamicLink = FirebaseDynamicLinks.instance;
    return this.__dynamicLink;
  }

  FirebaseDynamicLinks __dynamicLink;

  /// Create a URL for Dynamic Link.
  ///
  /// Create a URL to access [path].
  ///
  /// [path]: Path to create.
  factory FirestoreDynamicLinkURI(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    FirestoreDynamicLinkURI unit = PathMap.get<FirestoreDynamicLinkURI>(path);
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [create()] first.");
    return null;
  }

  /// Create a URL for Dynamic Link.
  ///
  /// Create a URL to access [path].
  ///
  /// [path]: Path to create.
  /// [uriPrefix]: URL prefix.
  /// [iosBundleId]: IOS Bundle ID.
  /// [webAPIkey]: API key for the web.
  /// [packageName]: Package name.
  /// [minimumVersion]: Minimum version.
  /// [socialTitle]: Social media title.
  /// [socialImageURL]: Social image url.
  /// [socialDescription]: Social media description.
  static Future<FirestoreDynamicLinkURI> create(String path,
      {String uriPrefix,
      String iosBundleId,
      String webAPIKey,
      String packageName,
      int minimumVersion = 1,
      String socialDescription,
      String socialImageURL,
      String socialTitle}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    assert(isNotEmpty(uriPrefix));
    assert(isNotEmpty(iosBundleId));
    assert(!(Config.isWeb && isEmpty(webAPIKey)));
    if (isEmpty(path) || isEmpty(uriPrefix)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(iosBundleId)) {
      Log.error("Bundle Id is empty.");
      return Future.delayed(Duration.zero);
    }
    if (Config.isWeb && isEmpty(webAPIKey)) {
      Log.error("Web API Key is empty.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDynamicLinkURI unit = PathMap.get<FirestoreDynamicLinkURI>(path);
    if (unit != null) return unit.future;
    unit = FirestoreDynamicLinkURI._(path: path);
    unit._constructURI(
        uriPrefix: uriPrefix,
        iosBundleId: iosBundleId,
        webAPIKey: webAPIKey,
        packageName: packageName,
        minimumVersion: minimumVersion,
        socialDescription: socialDescription,
        socialImageURL: socialImageURL,
        socialTitle: socialTitle);
    return unit.future;
  }

  FirestoreDynamicLinkURI._(
      {String path,
      dynamic value,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(
            path: path,
            value: value,
            isTemporary: isTemporary,
            group: group,
            order: order);
  void _constructURI(
      {String uriPrefix,
      String iosBundleId,
      String webAPIKey,
      String packageName,
      int minimumVersion = 1,
      String socialDescription,
      String socialImageURL,
      String socialTitle}) async {
    try {
      if (this._app == null) this.__app = await Firebase.initialize();
      if (Config.isWeb) {
        Response res = await post(Texts.format(restAPIURL, [webAPIKey]),
            headers: {HttpHeaders.contentTypeHeader: "application/json"},
            body: Json.encode({
              "dynamicLinkInfo": {
                "domainUriPrefix": uriPrefix,
                "link": this.path,
                "androidInfo": {
                  "androidPackageName": packageName,
                  "androidMinPackageVersionCode": minimumVersion.toString()
                },
                "iosInfo": {
                  "iosBundleId": packageName,
                  "iosAppStoreId": iosBundleId
                },
                "socialMetaTagInfo": {
                  "socialTitle": socialTitle,
                  "socialDescription": socialDescription,
                  "socialImageLink": socialImageURL
                }
              }
            }));
        this.data = Uri.parse(res.body);
      } else {
        if (this._dynamicLink == null)
          this.__dynamicLink = FirebaseDynamicLinks.instance;
        PackageInfo info = await PackageInfo.fromPlatform();
        int version = int.tryParse(info.buildNumber) ?? minimumVersion;
        DynamicLinkParameters data = DynamicLinkParameters(
            uriPrefix: uriPrefix,
            link: Uri.parse(this.path),
            androidParameters: AndroidParameters(
              packageName: packageName ?? info.packageName,
              minimumVersion: version,
            ),
            iosParameters: IosParameters(
              bundleId: packageName ?? info.packageName,
              minimumVersion: version.toString(),
              appStoreId: iosBundleId,
            ),
            socialMetaTagParameters: SocialMetaTagParameters(
                title: socialTitle,
                description: socialDescription,
                imageUrl:
                    socialImageURL != null ? Uri.parse(socialImageURL) : null));
        this.data = (await data.buildShortLink())?.shortUrl;
      }
      this.done();
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Get the protocol of the path.
  @override
  String get protocol => "firestore";

  /// When map data is stored.
  /// You can get the data by specifying the path.
  ///
  /// [path]: The path to get the data.
  @override
  dynamic operator [](String path) {
    if (isEmpty(path)) return null;
    path = path.trimString(Const.slash);
    Uri tmp = this.data;
    if (tmp == null || tmp.queryParameters == null) return null;
    if (!tmp.queryParameters.containsKey(path)) return null;
    return tmp.queryParameters[path];
  }
}
