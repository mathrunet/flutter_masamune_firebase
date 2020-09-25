part of masamune.firebase;

/// Interface for detecting changes in Firestore.
///
/// Please implement and use.
abstract class IFirestoreChangeListener implements IPath, IObservable {
  /// True if communicating with the server for saving or deleting.
  bool get isUpdating;

  /// True if you are able to update.
  bool get isUpdatable;

  /// True if you always listen for changes.
  bool get isListenable;
}
