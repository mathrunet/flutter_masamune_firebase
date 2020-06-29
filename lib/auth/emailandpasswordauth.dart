part of masamune.firebase;

/// Log in using your email and password.
class EmailAndPasswordAuth {
  /// Gets the options for the provider.
  static const AuthProviderOptions options = const AuthProviderOptions(
      id: "emailandpassword",
      provider: _provider,
      title: "Email & Password SignIn",
      text: "Enter your email and password to sign in.");
  static Future<FirestoreAuth> _provider(
      BuildContext context, Duration timeout) async {
    String email, password;
    await UILoginFormDialog.show(
      context,
      defaultSubmitAction: (m, p) {
        email = m;
        password = p;
      },
    );
    if (isEmpty(email) || isEmpty(password)) return null;
    return await FirestoreAuth.signInEmailAndPassword(
        email: email, password: password, timeout: timeout);
  }

  /// Log in using your email and password.
  ///
  /// [email]: Mail address.
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> signIn(
          {@required String email,
          @required String password,
          String protocol,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.signInEmailAndPassword(
          email: email,
          password: password,
          protocol: protocol,
          timeout: timeout);
}
