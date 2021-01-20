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

  /// Save the document data.
  ///
  /// The [data] is the value to be saved in the document. If the data exists in the current document, it will be overwritten.
  ///
  /// The [builder] can handle the document as it is after the data is saved.
  Future<T> save<T extends IDataDocument>(
      {Map<String, dynamic> data, void builder(T document)}) async {
    FirestoreDocument document = await FirestoreDocument.listen(this.path,
        keysAsCounter: this.keysAsCounter);
    if (document == null || document.isDisposed)
      document = FirestoreDocument.create(this.path);
    return await document.save(data: data, builder: builder);
  }
}
