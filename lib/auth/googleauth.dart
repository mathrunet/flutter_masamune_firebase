part of masamune.firebase;

/// Sign in to Firebase using Google OAuth.
class GoogleAuth {
  /// Sign in to Firebase using Google OAuth.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signIn(
      {String protocol, Duration timeout = Const.timeout}) {
    return FirestoreAuth.signInWithProvider(
        providerCallback: (timeout) async {
          GoogleSignIn google = GoogleSignIn();
          GoogleSignInAccount googleCurrentUser = google.currentUser;
          if (googleCurrentUser == null) {
            googleCurrentUser = await google.signInSilently().timeout(timeout);
          }
          if (googleCurrentUser == null) {
            googleCurrentUser = await google.signIn().timeout(timeout);
          }
          if (googleCurrentUser == null) {
            Log.error("Google user could not get.");
            return Future.delayed(Duration.zero);
          }
          GoogleSignInAuthentication googleAuth =
              await googleCurrentUser.authentication;
          return GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
        },
        providerId: GoogleAuthProvider.providerId,
        protocol: protocol,
        timeout: timeout);
  }
}
