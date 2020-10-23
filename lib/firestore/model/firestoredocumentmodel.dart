part of masamune.firebase;

/// Data model for working with Firestore documents.
///
/// You can use the same data structure of your Firestore documents.
///
/// Fields are retrieved by [getString] and so on, documents are saved by [save] and deleted by [delete].
///
/// ```
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(
///       title: Text("Title"),
///     ),
///     body: ListView(
///       children: [
///         ListTile(
///           title: Text("Name: ${FitestoreDocumentModel("user")["name"]}")
///         ),
///         ListTile(
///           title: Text("Age: ${FitestoreDocumentModel("user")["age"]}")
///         ),
///         ListTile(
///           title: Text("Country: ${FitestoreDocumentModel("user")["country"]}")
///         )
///       ]
///     )
///     floatingActionButton: FloatingActionButton(
///       onPressed: () {
///         FitestoreDocumentModel("user").save(
///           data: {
///             "name": "Username",
///             "age": 18,
///             "address": "Japan"
///           }
///         );
///       },
///       child: Icon(Icons.add),
///     ),
///   );
/// }
/// ```
class FirestoreDocumentModel extends DocumentModel<FirestoreDocument> {
  final bool listenable;

  /// Data model for working with Firestore documents.
  ///
  /// You can use the same data structure of your Firestore documents.
  ///
  /// Fields are retrieved by [getString] and so on, documents are saved by [save] and deleted by [delete].
  ///
  /// Defines the data document of the specified [path].
  ///
  /// If [listenable] is set to true, updates will be monitored.
  FirestoreDocumentModel(String path, {this.listenable = false}) : super(path);
  @override
  Future<FirestoreDocument> build(ModelContext context) {
    if (this.listenable) {
      return FirestoreDocument.listen(this.path);
    } else {
      return FirestoreDocument.load(this.path);
    }
  }

  /// Save the document data.
  ///
  /// The [data] is the value to be saved in the document. If the data exists in the current document, it will be overwritten.
  ///
  /// The [builder] can handle the document as it is after the data is saved.
  @override
  Future<T> save<T extends IDataDocument>(
      {Map<String, dynamic> data, void builder(T document)}) async {
    FirestoreDocument state = await FirestoreDocument.listen(this.path);
    if (state == null || state.isDisposed) {
      state = FirestoreDocument.create(this.path);
    }
    await state.save(data: data, builder: builder);
    return this as T;
  }

  /// Increase the number.
  ///
  /// Increase the number in real time and
  /// make it consistent on the server side.
  ///
  /// [path]: Increment key.
  /// [value]: Increment value.
  Future increment(String key, int value) =>
      FirestoreUtility.increment(Paths.child(this.path, key), value);
}
