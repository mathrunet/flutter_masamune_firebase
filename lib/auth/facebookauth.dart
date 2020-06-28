part of masamune.firebase;

/// Sign in to Firebase using Facebook Login.
class FacebookAuth {
  /// Sign in to Firebase using Facebook Login.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signIn(
      {String protocol, Duration timeout = Const.timeout}) {
    return FirestoreAuth.signInWithProvider(
        providerCallback: (timeout) async {
          FacebookLogin facebook = FacebookLogin();
          FacebookLoginResult result = await facebook.logIn(["email"]);
          switch (result.status) {
            case FacebookLoginStatus.cancelledByUser:
              Log.error("Login canceled");
              return Future.delayed(Duration.zero);
            case FacebookLoginStatus.error:
              Log.error("Login terminated with error: ${result.errorMessage}");
              return Future.delayed(Duration.zero);
            default:
              break;
          }
          return FacebookAuthProvider.getCredential(
              accessToken: result.accessToken.token);
        },
        providerId: FacebookAuthProvider.providerId,
        protocol: protocol,
        timeout: timeout);
  }
}
