part of masamune.firebase;

/// Displays the signin dialog.
///
/// Specify [providers] and select the authentication type to be displayed.
class UIAuth extends StatelessWidget {
  /// Dialog title.
  final String text;

  /// Provider type to authenticate.
  final List<String> providers;

  /// Specifies the action after a successful sign-in.
  final VoidAction actionAfterSignIn;

  /// Action on timeout.
  final VoidAction actionOnTimeout;

  /// The action in case of other errors.
  final VoidAction actionOnError;

  /// Twitter API key.
  final String twitterAPIKey;

  /// Twitter API secret.
  final String twitterAPISecret;

  /// Dialog title at guest login.
  final String dialogTitleWhenAnonymousSignIn;

  /// Dialog text for guest login.
  final String dialogTextWhenAnonymousSignIn;

  /// Force login.
  final bool forceLogin;

  /// Timeout for login.
  final Duration timeout;

  /// Google sign-in text.
  final String googleSignInText;

  /// Twitter sign-in text.
  final String twitterSignInText;

  /// Facebook sign-in text.
  final String facebookSignInText;

  /// Apple sign-in text.
  final String appleSignInText;

  /// Email and Password sign-in text.
  final String emailAndPasswordSignInText;

  /// Anonymous sign-in text.
  final String anonymousSignInText;

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
        "google",
        "twitter",
        "facebook",
        "apple",
        "emailandpassword",
        "anonymous"
      ],
      this.actionAfterSignIn,
      this.actionOnTimeout,
      this.actionOnError,
      this.twitterAPIKey,
      this.twitterAPISecret,
      this.dialogTitleWhenAnonymousSignIn = Const.empty,
      this.dialogTextWhenAnonymousSignIn = Const.empty,
      this.forceLogin = false,
      this.timeout = Const.timeout,
      this.googleSignInText = "Google SignIn",
      this.twitterSignInText = "Twitter SignIn",
      this.facebookSignInText = "Facebook SignIn",
      this.appleSignInText = "Apple SignIn",
      this.emailAndPasswordSignInText = "Email & Password SignIn",
      this.anonymousSignInText = "Anonymous SignIn"});

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
      if (isNotEmpty(twitterAPIKey) && isNotEmpty(twitterAPISecret)) {
        FirestoreAuth.options(
            twitterAPIKey: twitterAPIKey, twitterAPISecret: twitterAPISecret);
      }
      List<Widget> options = ListPool.get();
      for (String provider in providers) {
        switch (provider) {
          case ("google"):
            options.add(ListTile(
                onTap: () async {
                  FirestoreAuth auth =
                      await FirestoreAuth.signInToGoogle(timeout: timeout);
                  if (auth == null || auth.isTimeout) {
                    if (actionOnTimeout != null) actionOnTimeout();
                  } else if (auth.isError || auth.isAbort) {
                    if (actionOnError != null) actionOnError();
                  } else {
                    if (actionAfterSignIn != null) actionAfterSignIn();
                  }
                },
                title: Text(googleSignInText.localize())));
            break;
          case ("twitter"):
            if (Config.isWeb) continue;
            if (isEmpty(twitterAPIKey) || isEmpty(twitterAPISecret)) continue;
            options.add(ListTile(
                onTap: () async {
                  FirestoreAuth auth =
                      await FirestoreAuth.signInToTwitter(timeout: timeout);
                  if (auth == null || auth.isTimeout) {
                    if (actionOnTimeout != null) actionOnTimeout();
                  } else if (auth.isError || auth.isAbort) {
                    if (actionOnError != null) actionOnError();
                  } else {
                    if (actionAfterSignIn != null) actionAfterSignIn();
                  }
                },
                title: Text(twitterSignInText.localize())));
            break;
          case ("facebook"):
            if (Config.isWeb) continue;
            options.add(ListTile(
                onTap: () async {
                  FirestoreAuth auth =
                      await FirestoreAuth.signInToFacebook(timeout: timeout);
                  if (auth == null || auth.isTimeout) {
                    if (actionOnTimeout != null) actionOnTimeout();
                  } else if (auth.isError || auth.isAbort) {
                    if (actionOnError != null) actionOnError();
                  } else {
                    if (actionAfterSignIn != null) actionAfterSignIn();
                  }
                },
                title: Text(facebookSignInText.localize())));
            break;
          case ("apple"):
            if (!Config.isIOS) continue;
            options.add(ListTile(
                onTap: () async {}, title: Text(appleSignInText.localize())));
            break;
          case ("emailandpassword"):
            options.add(ListTile(
                onTap: () async {
                  UILoginFormDialog.show(
                    context,
                    defaultSubmitAction: (email, password) async {
                      FirestoreAuth auth =
                          await FirestoreAuth.signInEmailAndPassword(
                              email: email,
                              password: password,
                              timeout: timeout);
                      if (auth == null || auth.isTimeout) {
                        if (actionOnTimeout != null) actionOnTimeout();
                      } else if (auth.isError || auth.isAbort) {
                        if (actionOnError != null) actionOnError();
                      } else {
                        if (actionAfterSignIn != null) actionAfterSignIn();
                      }
                    },
                  );
                },
                title: Text(emailAndPasswordSignInText.localize())));
            break;
          case ("anonymous"):
            options.add(ListTile(
                onTap: () async {
                  FirestoreAuth auth =
                      await FirestoreAuth.signInAnonymously(timeout: timeout);
                  if (auth == null || auth.isTimeout) {
                    if (actionOnTimeout != null) actionOnTimeout();
                  } else if (auth.isError || auth.isAbort) {
                    if (actionOnError != null) actionOnError();
                  } else {
                    UIDialog.show(context,
                        title: dialogTitleWhenAnonymousSignIn,
                        text: dialogTextWhenAnonymousSignIn, submitAction: () {
                      if (actionAfterSignIn != null) actionAfterSignIn();
                    });
                  }
                },
                title: Text(anonymousSignInText.localize())));
            break;
        }
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
