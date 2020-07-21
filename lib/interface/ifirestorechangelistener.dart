part of masamune.firebase;

/// Interface for detecting changes in Firestore.
///
/// Please implement and use.
abstract class IFirestoreChangeListener implements IPath, IObservable {
  /// True if communicating with the server for saving or deleting.
  bool get isUpdating;
}
