part of masamune.firebase;

/// Provider of the firestore data document.
///
/// You can store and
/// use data fields there by describing the path as it is.
///
/// ```dart
/// final document = FirestoreDocumentProvider("user");
/// ```
class FirestoreDocumentProvider extends PathProvider<FirestoreDocument> {
  /// Provider of the firestore data document.
  ///
  /// You can store and
  /// use data fields there by describing the path as it is.
  ///
  /// ```dart
  /// final document = FirestoreDocumentProvider("user");
  /// ```
  ///
  /// [path]: Document path.
  FirestoreDocumentProvider(
    String path,
  ) : super((_) => FirestoreDocument.listen(path));
}
