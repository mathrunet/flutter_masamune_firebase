part of masamune.firebase;

/// Options when creating a DynamicLink in Firestore.
class FirestoreDynamicLinkOptions {
  /// The URL prefix of the Dynamic Link.
  ///
  /// Add a prefix starting with https://~.
  final String uriPrefix;

  /// IOS AppStore ID (123456789)
  final String appStoreId;

  /// WebAPIKey for use on the Web.
  final String webAPIKey;

  /// The package name of the Android store.
  final String packageName;

  /// Worst Version.
  final int minimumVersion;

  /// The default description when posted on social networking sites.
  final String defaultSocialDescription;

  /// The URL of the default featured image
  /// when it is posted on social networking sites.
  final String defaultSocialImageURL;

  /// The default title when posted on social networking sites.
  final String defaultSocialTitle;

  /// Options when creating a DynamicLink in Firestore.
  const FirestoreDynamicLinkOptions({
    this.uriPrefix,
    this.appStoreId,
    this.webAPIKey,
    this.packageName,
    this.minimumVersion = 1,
    this.defaultSocialDescription,
    this.defaultSocialImageURL,
    this.defaultSocialTitle,
  });
}
