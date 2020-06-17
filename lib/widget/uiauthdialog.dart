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
  static Future show(BuildContext context,
      {String title,
      List<String> providers = const [
        "google",
        "twitter",
        "facebook",
        "apple",
        "emailandpassword",
        "anonymous"
      ],
      VoidAction actionAfterSignIn,
      VoidAction actionOnTimeout,
      VoidAction actionOnError,
      String twitterAPIKey,
      String twitterAPISecret,
      String dialogTitleWhenAnonymousSignIn = Const.empty,
      String dialogTextWhenAnonymousSignIn = Const.empty,
      bool forceLogin = false,
      Duration timeout = Const.timeout,
      String googleSignInText = "Google SignIn",
      String twitterSignInText = "Twitter SignIn",
      String facebookSignInText = "Facebook SignIn",
      String appleSignInText = "Apple SignIn",
      String emailAndPasswordSignInText = "Email & Password SignIn",
      String anonymousSignInText = "Anonymous SignIn"}) async {
    if (context == null || title == null) return;
    try {
      if (!forceLogin && await FirestoreAuth.tryRestoreAuth(timeout: timeout)) {
        if (actionAfterSignIn != null) actionAfterSignIn();
        return;
      }
      if (isNotEmpty(twitterAPIKey) && isNotEmpty(twitterAPISecret)) {
        FirestoreAuth.options(
            twitterAPIKey: twitterAPIKey, twitterAPISecret: twitterAPISecret);
      }
      List<SimpleDialogOption> options = ListPool.get();
      for (String provider in providers) {
        switch (provider) {
          case ("google"):
            options.add(SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
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
                child: Text(googleSignInText.localize())));
            break;
          case ("twitter"):
            if (Config.isWeb) continue;
            if (isEmpty(twitterAPIKey) || isEmpty(twitterAPISecret)) continue;
            options.add(SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
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
                child: Text(twitterSignInText.localize())));
            break;
          case ("facebook"):
            if (Config.isWeb) continue;
            options.add(SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
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
                child: Text(facebookSignInText.localize())));
            break;
          case ("apple"):
            if (!Config.isIOS) continue;
            options.add(SimpleDialogOption(
                onPressed: () async {},
                child: Text(appleSignInText.localize())));
            break;
          case ("emailandpassword"):
            if (!Config.isIOS) continue;
            options.add(SimpleDialogOption(
                onPressed: () async {
                  UILoginFormDialog.show(
                    context,
                    defaultSubmitAction: (email, password) async {
                      FirestoreAuth auth =
                          await FirestoreAuth.signInEmailAndPassword(
                                  email: email,
                                  password: password,
                                  timeout: timeout)
                              .showIndicatorAndDialog(context);
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
                child: Text(emailAndPasswordSignInText.localize())));
            break;
          case ("anonymous"):
            options.add(SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
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
                child: Text(anonymousSignInText.localize())));
            break;
        }
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
