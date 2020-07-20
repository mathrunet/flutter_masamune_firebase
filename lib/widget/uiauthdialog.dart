part of masamune.firebase;

/// Displays the signin dialog.
///
/// Specify [providers] and select the authentication type to be displayed.
class UIAuthDialog {
  /// Displays the signin dialog.
  ///
  /// Specify [providers] and select the authentication type to be displayed.
  ///
  /// [title]: Dialog title.
  /// [providers]: Provider type to authenticate.
  /// [actionAfterSignIn]: Specifies the action after a successful sign-in.
  /// [actionOnTimeout]: Action on timeout.
  /// [actionOnError]: The action in case of other errors.
  /// [dialogTitleWhenAnonymousSignIn]: Dialog title at guest login.
  /// [dialogTextWhenAnonymousSignIn]: Dialog text for guest login.
  /// [forceLogin]: Force login.
  /// [timeout]: Timeout for login.
  static Future show(BuildContext context,
      {@required String title,
      List<AuthProviderOptions> providers = const [
        EmailAndPasswordAuth.options,
        AnonymouslyAuth.options
      ],
      VoidAction actionAfterSignIn,
      VoidAction actionOnTimeout,
      VoidAction actionOnError,
      String dialogTitleWhenAnonymousSignIn = Const.empty,
      String dialogTextWhenAnonymousSignIn = Const.empty,
      bool forceLogin = false,
      Duration timeout = Const.timeout}) async {
    if (context == null || title == null) return;
    try {
      if (!forceLogin && await FirestoreAuth.tryRestoreAuth(timeout: timeout)) {
        if (actionAfterSignIn != null) actionAfterSignIn();
        return;
      }
      List<SimpleDialogOption> options = ListPool.get();
      for (AuthProviderOptions provider in providers) {
        if (provider == null) continue;
        options.add(SimpleDialogOption(
            onPressed: () async {
              FirestoreAuth auth = await provider.provider(context, timeout);
              if (auth == null) return;
              if (auth.isTimeout) {
                if (actionOnTimeout != null) actionOnTimeout();
              } else if (auth.isError || auth.isAbort) {
                if (actionOnError != null) actionOnError();
              } else {
                if (provider.id == AnonymouslyAuth.options.id) {
                  UIDialog.show(context,
                      title: dialogTitleWhenAnonymousSignIn,
                      text: dialogTextWhenAnonymousSignIn, onSubmit: () {
                    if (actionAfterSignIn != null) actionAfterSignIn();
                  });
                } else {
                  if (actionAfterSignIn != null) actionAfterSignIn();
                }
              }
            },
            child: Text(provider.title.localize())));
      }
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
                onWillPop: () async => null,
                child: SimpleDialog(title: Text(title), children: options));
          });
    } on TimeoutException {
      if (actionOnTimeout != null) actionOnTimeout();
    } catch (e) {
      if (actionOnError != null) actionOnError();
    }
  }
}
