part of masamune.firebase;

/// Firestore's documentation model.
///
/// You can get the data as a document by specifying the Firestore path.
class FirestoreDocumentModel extends DocumentModel {
  /// A key list to use as a counter.
  final List<String> keysAsCounter;

  /// Firestore's documentation model.
  ///
  /// You can get the data as a document by specifying the Firestore path.
  FirestoreDocumentModel(String path, {this.keysAsCounter}) : super(path);

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return FirestoreDocument.listen(this.path,
        keysAsCounter: this.keysAsCounter);
  }
}
