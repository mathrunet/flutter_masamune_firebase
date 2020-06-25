part of masamune.firebase;

/// Firebase / Firestore Authentication class.
///
/// Basically, anonymous authentication is performed,
/// followed by a flow linking a specific authentication method.
class FirestoreAuth extends Auth {
  static const String _hashKey = "MBdKdx3nAHFNeaP32zu8re9rzfHSGZj3";

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreAuth>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreAuth._(path) as T;
  Firebase get _app {
    if (this.__app == null) this.__app = Firebase(this.protocol);
    return this.__app;
  }

  Firebase __app;
  FirebaseAuth get _auth {
    if (this.__auth == null) this.__auth = FirebaseAuth.fromApp(this._app.app);
    return this.__auth;
  }

  FirebaseAuth __auth;
  FirebaseUser _link;
  GoogleSignIn get _google {
    if (this.__google == null) this.__google = GoogleSignIn();
    return this.__google;
  }

  GoogleSignIn __google;
  TwitterLogin get _twitter {
    if (this.__twitter == null)
      this.__twitter = TwitterLogin(
          consumerKey: _twitterAPIKey, consumerSecret: _twitterAPISecret);
    return this.__twitter;
  }

  TwitterLogin __twitter;
  FacebookLogin get _facebook {
    if (this.__facebook == null) this.__facebook = FacebookLogin();
    return this.__facebook;
  }

  FacebookLogin __facebook;

  /// Search for an instance of FirestoreAuth from [protocol].
  ///
  /// [protocol]: Protocol.
  factory FirestoreAuth([String protocol]) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit != null) return unit;
    unit = PathMap.get<FirestoreAuth>(Texts.format(_systemPath, [Const.empty]));
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. First you need to do like [signIn].");
    return null;
  }

  /// Set options for authentication.
  ///
  /// [twitterAPIKey]: Twitter API Key.
  /// [twitterAPISecret]: Twitter API Secret.
  static void options({String twitterAPIKey, String twitterAPISecret}) {
    _twitterAPIKey = twitterAPIKey;
    _twitterAPISecret = twitterAPISecret;
  }

  static String _twitterAPIKey;
  static String _twitterAPISecret;

  /// Check if you are logged in.
  ///
  /// True if logged in.
  ///
  /// [protocol]: Protocol specification.
  /// [timeout]: Timeout time.
  /// [retryWhenTimeout]: If it times out, try again.
  static Future<bool> tryRestoreAuth(
      {String protocol,
      Duration timeout = Const.timeout,
      bool retryWhenTimeout = false}) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit != null) return unit._tryRestoreAuth(timeout, retryWhenTimeout);
    unit = FirestoreAuth._(path);
    return unit._tryRestoreAuth(timeout, retryWhenTimeout);
  }

  Future<bool> _tryRestoreAuth(Duration timeout, bool retryWhenTimeout) async {
    if (this._app == null)
      this.__app = await Firebase.initialize(timeout: timeout);
    if (this._auth == null) return false;
    try {
      FirebaseUser user = await this._auth.currentUser().timeout(timeout);
      if (user != null) {
        await user.reload().timeout(timeout);
        this._link = user;
        Log.ast("Logged-in user was found: %s", [this._link.uid]);
        this.authorized(this._link.uid);
        return true;
      }
    } on TimeoutException catch (e) {
      if (!retryWhenTimeout) throw e;
      return _tryRestoreAuth(timeout, retryWhenTimeout);
    } catch (e) {}
    return false;
  }

  /// True if you are signed in.
  ///
  /// [protorol]: Protocol specification.
  static bool isSignedIn({String protocol}) {
    return isNotEmpty(getUID(protocol: protocol));
  }

  /// You can get the UID after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  static String getUID({String protocol}) {
    FirestoreAuth auth = FirestoreAuth(protocol);
    if (auth == null) return null;
    return auth.uid;
  }

  /// You can get the Email after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  static String getEmail({String protocol}) {
    FirestoreAuth auth = FirestoreAuth(protocol);
    if (auth == null) return null;
    return auth._link?.email;
  }

  /// You can get the PhoneNumber after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  static String getPhone({String protocol}) {
    FirestoreAuth auth = FirestoreAuth(protocol);
    if (auth == null) return null;
    return auth._link?.phoneNumber;
  }

  /// You can get the PhotoURL after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  static String getPhoto({String protocol}) {
    FirestoreAuth auth = FirestoreAuth(protocol);
    if (auth == null) return null;
    return auth._link?.photoUrl;
  }

  /// You can get the Display Name after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  static String getName({String protocol}) {
    FirestoreAuth auth = FirestoreAuth(protocol);
    if (auth == null) return null;
    return auth._link?.displayName;
  }

  /// Process sign-in.
  /// Basically, anonymous authentication is performed,
  /// followed by a flow linking a specific authentication method.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signIn(
          {String protocol, Duration timeout = Const.timeout}) =>
      signInAnonymously(protocol: protocol, timeout: timeout);

  /// Process sign-in
  /// Perform an anonymous login
  ///
  /// [protorol]: Protocol specification
  /// [timeout]: Timeout time
  static Future<FirestoreAuth> signInAnonymously(
      {String protocol, Duration timeout = Const.timeout}) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else if (unit._link != null && isNotEmpty(unit.uid)) {
      return unit.future;
    } else {
      unit.init();
    }
    unit._anonymousProcess(timeout);
    return unit.future;
  }

  static const String _systemPath = "system://auth/%s";
  FirestoreAuth._([String path]) : super(path: path);

  /// Sign out.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signOut(
      {String protocol, Duration timeout = Const.timeout}) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    assert(!(isEmpty(unit.uid) || unit._link == null));
    if (isEmpty(unit.uid) || unit._link == null) {
      Log.error("Not logged in yet. Please wait until login is successful.");
      return unit.future;
    }
    unit._signOutProcess(timeout);
    return unit.future;
  }

  Future _signOutProcess(Duration timeout) async {
    try {
      if (this._app == null)
        this.__app = await Firebase.initialize(timeout: timeout);
      if (this._auth == null) {
        this.error("Firebase auth is not found.");
        return;
      }
      await Future.wait([
        this._google?.currentUser?.clearAuthCache(),
        this._twitter?.logOut(),
        this._facebook?.logOut(),
        this._auth.signOut()
      ]).timeout(timeout);
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Link to Facebook.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInToFacebook(
      {String protocol, Duration timeout = Const.timeout}) {
    assert(!Config.isWeb);
    if (Config.isWeb) {
      Log.error("This function does not support the Web.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToFacebookProcess(timeout);
    return unit.future;
  }

  Future _linkToFacebookProcess(Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(FacebookAuthProvider.providerId))) {
        this.error("This user is already linked to a Facebook account.");
        return;
      }
      FacebookLoginResult result = await this._facebook.logIn(["email"]);
      switch (result.status) {
        case FacebookLoginStatus.cancelledByUser:
          this.error("Login canceled");
          return;
        case FacebookLoginStatus.error:
          this.error("Login terminated with error: ${result.errorMessage}");
          return;
        default:
          break;
      }
      AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Facebook account to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Link to Twitter.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInToTwitter(
      {String protocol, Duration timeout = Const.timeout}) {
    assert(!Config.isWeb);
    if (Config.isWeb) {
      Log.error("This function does not support the Web.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToTwitterProcess(_twitterAPIKey, _twitterAPISecret, timeout);
    return unit.future;
  }

  Future _linkToTwitterProcess(
      String apiKey, String apiSecret, Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(TwitterAuthProvider.providerId))) {
        this.error("This user is already linked to a Twitter account.");
        return;
      }
      TwitterLoginResult result = await this._twitter.authorize();
      switch (result.status) {
        case TwitterLoginStatus.cancelledByUser:
          this.error("Login canceled");
          return;
        case TwitterLoginStatus.error:
          this.error("Login terminated with error: ${result.errorMessage}");
          return;
        default:
          break;
      }
      AuthCredential credential = TwitterAuthProvider.getCredential(
          authToken: result.session.token,
          authTokenSecret: result.session.secret);
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Twitter account to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Link to Apple.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInToApple(
      {String protocol, Duration timeout = Const.timeout}) {
    assert(!Config.isWeb);
    if (Config.isWeb) {
      Log.error("This function does not support the Web.");
      return Future.delayed(Duration.zero);
    }
    assert(Config.isIOS);
    if (!Config.isIOS) {
      Log.error("This function is only compatible with IOS.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToAppleProcess(timeout);
    return unit.future;
  }

  Future _linkToAppleProcess(Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(TwitterAuthProvider.providerId))) {
        this.error("This user is already linked to a Apple account.");
        return;
      }
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(
          requestedScopes: [Scope.fullName],
          requestedOperation: OpenIdOperation.operationLogin,
        )
      ]);
      switch (result.status) {
        case AuthorizationStatus.cancelled:
          this.error("Login canceled");
          return;
        case AuthorizationStatus.error:
          this.error(
              "Login terminated with error: ${result.error.localizedDescription}");
          return;
        default:
          break;
      }
      OAuthProvider provider = OAuthProvider(providerId: "apple.com");
      AuthCredential credential = provider.getCredential(
        idToken: String.fromCharCodes(result.credential.identityToken),
        accessToken: String.fromCharCodes(result.credential.authorizationCode),
      );
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Apple account to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  /// Link by email link.
  ///
  /// You need to do [sendEmailLink] first.
  ///
  /// Enter the link acquired by Dynamic Link.
  ///
  /// [link]: Email link.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInEmailLink(String link,
      {String protocol, Duration timeout = Const.timeout}) {
    assert(isNotEmpty(link));
    if (isEmpty(link)) {
      Log.error("This email link is invalid.");
      return Future.delayed(Duration.zero);
    }
    String email = Prefs.getString("FirestoreSignInEmail".toSHA256(_hashKey));
    assert(isNotEmpty(email));
    if (isEmpty(email)) {
      Log.error(
          "The processing is invalid. First create a link with [sendEmailLink].");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToEmailLinkProcess(email, link, timeout);
    return unit.future;
  }

  Future _linkToEmailLinkProcess(
      String email, String link, Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (!await this._auth.isSignInWithEmailLink(link)) {
        this.error("This email link is invalid.");
        return;
      }
      AuthCredential credential =
          EmailAuthProvider.getCredentialWithLink(email: email, link: link);
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Email Link to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
      return;
    }
  }

  /// Send an email link.
  ///
  /// [email]: Email.
  /// [url]: URL domain of the link. Specify the domain of Dynamic Link.
  /// [packageName]: App package name.
  /// [androidMinimumVersion]: Minimum version of android.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> sendEmailLink(
      {@required String email,
      @required String url,
      @required String packageName,
      int androidMinimumVersion = 1,
      String protocol,
      Duration timeout = Const.timeout}) {
    assert(isNotEmpty(email));
    if (isEmpty(email)) {
      Log.error("This email is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._sendEmailLinkProcess(
        email: email,
        url: url,
        androidMinimumVersion: androidMinimumVersion,
        packageName: packageName,
        timeout: timeout);
    return unit.future;
  }

  Future _sendEmailLinkProcess(
      {String email,
      String url,
      String packageName,
      int androidMinimumVersion,
      Duration timeout}) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(EmailAuthProvider.providerId))) {
        this.error("This user is already linked to a Email account.");
        return;
      }
      await this._auth.sendSignInWithEmailLink(
          email: email,
          url: url,
          handleCodeInApp: true,
          iOSBundleID: packageName,
          androidPackageName: packageName,
          androidInstallIfNotAvailable: true,
          androidMinimumVersion: androidMinimumVersion.toString());
      Prefs.set("FirestoreSignInEmail".toSHA256(_hashKey), email);
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
      return;
    }
  }

  /// Authenticate by sending a code to your phone number.
  ///
  /// [phoneNumber]: Telephone number (starting with the country code).
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInSMS(String phoneNumber,
      {String protocol, Duration timeout = const Duration(seconds: 60)}) {
    assert(isNotEmpty(phoneNumber));
    if (isEmpty(phoneNumber)) {
      Log.error("This Phone number is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._signInSMS(phoneNumber: phoneNumber, timeout: timeout);
    return unit.future;
  }

  Future _signInSMS({String phoneNumber, Duration timeout}) async {
    try {
      await this._prepareProcessInternal(timeout);
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(PhoneAuthProvider.providerId))) {
        this.error("This user is already linked to a Phone number account.");
        return;
      }
      await this._auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: timeout,
          verificationCompleted: (credential) async {
            if (this._link != null) {
              this._link = (await this
                      ._link
                      .linkWithCredential(credential)
                      .timeout(timeout))
                  .user;
            } else {
              this._link = (await this
                      ._auth
                      .signInWithCredential(credential)
                      .timeout(timeout))
                  .user;
            }
            if (this._link == null || isEmpty(this._link.uid)) {
              this.error("User is not found.");
              return;
            }
            Log.ast("Linked Phone number to user: %s", [this._link.uid]);
            this.authorized(this._link.uid);
          },
          verificationFailed: (error) {
            this.error(error.message);
          },
          codeSent: (number, [code]) {
            Log.ast("Submitted the code for Phone number.$number $code");
          },
          codeAutoRetrievalTimeout: (error) {
            this.timeout(error);
          });
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
      return;
    }
  }

  /// Log in using your email and password.
  ///
  /// [email]: Mail address.
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInEmailAndPassword(
      {@required String email,
      @required String password,
      String protocol,
      Duration timeout = Const.timeout}) {
    assert(isNotEmpty(email));
    assert(isNotEmpty(password));
    if (isEmpty(email) || isEmpty(password)) {
      Log.error("This email or password is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToEmailAndPasswordProcess(email, password, timeout);
    return unit.future;
  }

  Future _linkToEmailAndPasswordProcess(
      String email, String password, Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      AuthCredential credential =
          EmailAuthProvider.getCredential(email: email, password: password);
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Email and Password to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
      return;
    }
  }

  /// Link Google.
  ///
  /// Google login dialog appears.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signInToGoogle(
      {String protocol, Duration timeout = Const.timeout}) {
    if (isEmpty(protocol)) protocol = "firestore";
    String path = Texts.format(_systemPath, [protocol]);
    FirestoreAuth unit = PathMap.get<FirestoreAuth>(path);
    if (unit == null) {
      unit = FirestoreAuth._(path);
    } else {
      unit.init();
    }
    unit._linkToGoogleProcess(timeout);
    return unit.future;
  }

  Future _linkToGoogleProcess(Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      GoogleSignInAccount googleCurrentUser = this._google.currentUser;
      if (googleCurrentUser == null) {
        googleCurrentUser =
            await this._google.signInSilently().timeout(timeout);
      }
      if (googleCurrentUser == null) {
        googleCurrentUser = await this._google.signIn();
      }
      if (googleCurrentUser == null) {
        this.error("Google user could not get.");
        return;
      }
      if (this._link != null &&
          this._link.providerData.any(
              (t) => t.providerId?.contains(GoogleAuthProvider.providerId))) {
        this.error("This user is already linked to a Google account.");
        return;
      }
      GoogleSignInAuthentication googleAuth =
          await googleCurrentUser.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (this._link != null) {
        this._link =
            (await this._link.linkWithCredential(credential).timeout(timeout))
                .user;
      } else {
        this._link =
            (await this._auth.signInWithCredential(credential).timeout(timeout))
                .user;
      }
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
      Log.ast("Linked Google account to user: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
      return;
    }
  }

  Future _anonymousProcess(Duration timeout) async {
    try {
      await this._prepareProcessInternal(timeout);
      await this._anonymousProcessInternal(timeout);
      Log.ast("Anonymous login successful: %s", [this._link.uid]);
      this.authorized(this._link.uid);
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  Future _prepareProcessInternal(Duration timeout) async {
    if (this._app == null)
      this.__app = await Firebase.initialize(timeout: timeout);
    if (this._app == null) {
      this.error("Firebase app is not found.");
      return;
    }
    if (this._auth == null) {
      this.error("Firebase auth is not found.");
      return;
    }
    try {
      FirebaseUser user = await this._auth.currentUser().timeout(timeout);
      if (user != null) {
        await user.reload().timeout(timeout);
        this._link = user;
        Log.ast("Logged-in user was found: %s", [this._link.uid]);
        return;
      }
    } on TimeoutException catch (e) {
      throw e;
    } catch (e) {}
  }

  Future _anonymousProcessInternal(Duration timeout) async {
    if (this._link != null) return;
    try {
      this._link =
          (await this._auth.signInAnonymously().timeout(timeout))?.user;
      if (this._link == null || isEmpty(this._link.uid)) {
        this.error("User is not found.");
        return;
      }
    } on TimeoutException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  /// Execute when authentication is completed.
  ///
  /// Do not use from external class.
  ///
  /// [uid]: User / Universal ID.
  @override
  @protected
  void authorized(String uid) {
    PathTag.set("UID", uid);
    PathTag.set("UserID", uid);
    super.authorized(uid);
  }

  /// Get the protocol of the path.
  @override
  String get protocol {
    if (isEmpty(this.rawPath.scheme)) return "firestore";
    return this.rawPath.scheme;
  }
}
