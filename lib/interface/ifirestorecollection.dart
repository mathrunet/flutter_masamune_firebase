part of masamune.firebase;

/// Interface for working with Firestore collections.
abstract class IFirestoreCollection {
  /// Set the query.
  ///
  /// After setting the query, execute [reload()] to reflect the setting.
  FirestoreQuery query;
}
