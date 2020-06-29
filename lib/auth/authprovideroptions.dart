part of masamune.firebase;

/// Defines the authentication provider options.
///
/// Specify a callback that returns [FirestoreAuth] in [provider].
class AuthProviderOptions {
  /// Provider ID.
  final String id;

  /// Callback that returns [FirestoreAuth].
  final Future<FirestoreAuth> Function(BuildContext context, Duration timeout)
      provider;

  /// Provider title.
  final String title;

  /// Description of the provider.
  final String text;

  /// Defines the authentication provider options.
  ///
  /// Specify a callback that returns [FirestoreAuth] in [provider].
  ///
  /// [id]: Provider ID.
  /// [provider]: Callback that returns [FirestoreAuth].
  /// [title]: Provider title.
  /// [text]: Description of the provider.
  const AuthProviderOptions(
      {@required this.id,
      @required this.provider,
      @required this.title,
      this.text});
}
