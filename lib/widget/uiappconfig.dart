part of masamune.firebase;

/// Displays the signin dialog.
///
/// Specify[providers]and select the authentication type to be displayed.
class UIAppConfig {
  /// Displays the signin dialog.
  ///
  /// Specify [providers] and select the authentication type to be displayed.
  ///
  /// [title]: Dialog title.
  /// [providers]: Provider type to authenticate.
  /// [actionAfterSignIn]: Specifies the action after a successful sign-in.
  static Future listen(BuildContext context,
      {String maintenanceKey = "maintenance",
      String iosRequiredVersionKey = "iosRequiredVersion",
      String androidRequiredVersionKey = "androidRequiredVersion",
      String iosStoreURL,
      String androidStoreURL,
      String officialURL}) {
    OverlayState overlay = context.navigator.overlay;
    return AppConfigDocument.listen().listen((value) async {
      if (value.getBool(maintenanceKey, false)) {
        UIDialog.show(overlay.context,
            defaultTitle: "Under maintenance".localize(),
            defaultText: "The app is currently under maintenance. "
                    "Detailed information on maintenance will be announced on the official website."
                .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(officialURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
        return value;
      }
      if (Config.isAndroid) {
        PackageInfo info = await PackageInfo.fromPlatform();
        String version =
            value.getString(androidRequiredVersionKey, info.version);
        if (version.compareTo(info.version) <= 0) return value;
        UIDialog.show(overlay.context,
            defaultTitle: "Please update".localize(),
            defaultText:
                "App update required. Get the latest version from the store."
                    .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(androidStoreURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
      } else if (Config.isIOS) {
        PackageInfo info = await PackageInfo.fromPlatform();
        String version = value.getString(iosRequiredVersionKey, info.version);
        if (version.compareTo(info.version) <= 0) return value;
        UIDialog.show(overlay.context,
            defaultTitle: "Please update".localize(),
            defaultText:
                "App update required. Get the latest version from the store."
                    .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(iosStoreURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
      }
      return value;
    }).then((value) async {
      if (value.getBool(maintenanceKey, false)) {
        return UIDialog.show(context,
            defaultTitle: "Under maintenance".localize(),
            defaultText: "The app is currently under maintenance. "
                    "Detailed information on maintenance will be announced on the official website."
                .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(officialURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
      }
      if (Config.isAndroid) {
        PackageInfo info = await PackageInfo.fromPlatform();
        String version =
            value.getString(androidRequiredVersionKey, info.version);
        if (version.compareTo(info.version) <= 0) return value;
        return UIDialog.show(context,
            defaultTitle: "Please update".localize(),
            defaultText:
                "App update required. Get the latest version from the store."
                    .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(androidStoreURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
      } else if (Config.isIOS) {
        PackageInfo info = await PackageInfo.fromPlatform();
        String version = value.getString(iosRequiredVersionKey, info.version);
        if (version.compareTo(info.version) <= 0) return value;
        return UIDialog.show(context,
            defaultTitle: "Please update".localize(),
            defaultText:
                "App update required. Get the latest version from the store."
                    .localize(),
            defaultSubmitText: "Open".localize(),
            defaultSubmitAction: () async {
          openURL(iosStoreURL);
          await SystemNavigator.pop();
        }, popOnPress: false, disableBackKey: true, willShowRepetition: true);
      }
      return value;
    });
  }
}
