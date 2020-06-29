part of masamune.firebase;

/// Process sign-in.
/// Perform an anonymous login.
class AnonymouslyAuth {
  /// Gets the options for the provider.
  static const AuthProviderOptions options = const AuthProviderOptions(
      id: "anonymous",
      provider: _provider,
      title: "Anonymous SignIn",
      text: "Sign in as a guest.");
  static Future<FirestoreAuth> _provider(
      BuildContext context, Duration timeout) {
    return FirestoreAuth.signInAnonymously(timeout: timeout);
  }

  /// Process sign-in.
  /// Perform an anonymous login.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signIn(
          {String protocol, Duration timeout = Const.timeout}) =>
      FirestoreAuth.signInAnonymously(protocol: protocol, timeout: timeout);
}
