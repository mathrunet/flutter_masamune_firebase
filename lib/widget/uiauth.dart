part of masamune.firebase;

/// Displays the signin dialog.
///
/// Specify [providers] and select the authentication type to be displayed.
class UIAuth extends StatelessWidget {
  /// Dialog title.
  final String text;

  /// Provider type to authenticate.
  final List<AuthProviderOptions> providers;

  /// Specifies the action after a successful sign-in.
  final VoidAction actionAfterSignIn;

  /// Action on timeout.
  final VoidAction actionOnTimeout;

  /// The action in case of other errors.
  final VoidAction actionOnError;

  /// Dialog title at guest login.
  final String dialogTitleWhenAnonymousSignIn;

  /// Dialog text for guest login.
  final String dialogTextWhenAnonymousSignIn;

  /// Force login.
  final bool forceLogin;

  /// Timeout for login.
  final Duration timeout;

  /// Displays the signin widget.
  ///
  /// Specify [providers] and select the authentication type to be displayed.
  ///
  /// [title]: Dialog title.
  /// [providers]: Provider type to authenticate.
  /// [actionAfterSignIn]: Specifies the action after a successful sign-in.
  /// [actionOnTimeout]: Action on timeout.
  /// [actionOnError]: The action in case of other errors.
  /// [twitterAPIKey]: Twitter API key.
  /// [twitterAPISecret]: Twitter API secret.
  /// [dialogTitleWhenAnonymousSignIn]: Dialog title at guest login.
  /// [dialogTextWhenAnonymousSignIn]: Dialog text for guest login.
  /// [forceLogin]: Force login.
  /// [timeout]: Timeout for login.
  /// [googleSignInText]: Google sign-in text.
  /// [twitterSignInText]: Twitter sign-in text.
  /// [facebookSignInText]: Facebook sign-in text.
  /// [appleSignInText]: Apple sign-in text.
  /// [emailAndPasswordSignInText]: Email and Password sign-in text.
  /// [anonymousSignInText]: Anonymous sign-in text.
  UIAuth(
      {this.text,
      this.providers = const [
        EmailAndPasswordAuth.options,
        AnonymouslyAuth.options
      ],
      this.actionAfterSignIn,
      this.actionOnTimeout,
      this.actionOnError,
      this.dialogTitleWhenAnonymousSignIn = Const.empty,
      this.dialogTextWhenAnonymousSignIn = Const.empty,
      this.forceLogin = false,
      this.timeout = Const.timeout});

  /// Build method.
  ///
  /// [BuildContext]: Build Context.
  @override
  Widget build(BuildContext context) {
    if (context == null || text == null) return Container();
    try {
      if (!forceLogin && FirestoreAuth.isSignedIn()) {
        if (actionAfterSignIn != null) {
          Future.delayed(Duration.zero, () => actionAfterSignIn());
        }
        return Container();
      }
      List<Widget> options = ListPool.get();
      for (AuthProviderOptions provider in providers) {
        if (provider == null) continue;
        options.add(ListTile(
            onTap: () async {
              FirestoreAuth auth =
                  await provider.provider(context, this.timeout);
              if (auth == null) return;
              if (auth.isTimeout) {
                if (actionOnTimeout != null) actionOnTimeout();
              } else if (auth.isError || auth.isAbort) {
                if (actionOnError != null) actionOnError();
              } else {
                if (provider.id == AnonymouslyAuth.options.id) {
                  UIDialog.show(context,
                      title: dialogTitleWhenAnonymousSignIn,
                      text: dialogTextWhenAnonymousSignIn, submitAction: () {
                    if (actionAfterSignIn != null) actionAfterSignIn();
                  });
                } else {
                  if (actionAfterSignIn != null) actionAfterSignIn();
                }
              }
            },
            title: Text(provider.title.localize())));
      }
      return ListView(
          children: options.insertFirst(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                    color: context.theme.dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.theme.dividerColor)),
                child: Text(text),
              ))));
    } on TimeoutException {
      if (actionOnTimeout != null) {
        Future.delayed(Duration.zero, () => actionOnTimeout());
      }
    } catch (e) {
      if (actionOnError != null) {
        Future.delayed(Duration.zero, () => actionOnError());
      }
    }
    return Container();
  }
}
