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

  /// Register using your email and password.
  ///
  /// [email]: Mail address.
  /// [locale]: Specify the language of the confirmation email.
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> register(
          {@required String email,
          @required String password,
          String protocol,
          String locale,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.registerInEmailAndPassword(
          email: email, password: password, protocol: protocol, locale: locale);

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

  /// Re-authenticate using your email address and password.
  ///
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> reauth(
          {@required String password,
          String protocol,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.reauthInEmailAndPassword(
          password: password, protocol: protocol, timeout: timeout);

  /// Resend the email for email address verification.
  ///
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> sendEmailVerification(
          {String protocol, Duration timeout = Const.timeout, String locale}) =>
      FirestoreAuth.sendEmailVerification(
          protocol: protocol, timeout: timeout, locale: locale);

  /// Send you an email to reset your password.
  ///
  /// [email]: Email.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> sendPasswordResetEmail(
          {@required String email,
          String protocol,
          String locale,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.sendPasswordResetEmail(
          email: email, protocol: protocol, locale: locale, timeout: timeout);

  /// Change your email address.
  ///
  /// It is necessary to execute [reauthInEmailAndPassword]
  /// in advance to re-authenticate.
  ///
  /// [email]: Mail address.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> changeEmail(
          {@required String email,
          String protocol,
          String locale,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.changeEmail(
          email: email, protocol: protocol, locale: locale, timeout: timeout);

  /// Change your password.
  ///
  /// It is necessary to execute [reauthInEmailAndPassword]
  /// in advance to re-authenticate.
  ///
  /// [password]: The changed password.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirestoreAuth> changePassword(
          {@required String password,
          String protocol,
          String locale,
          Duration timeout = Const.timeout}) =>
      FirestoreAuth.changePassword(
          password: password,
          protocol: protocol,
          locale: locale,
          timeout: timeout);
}
