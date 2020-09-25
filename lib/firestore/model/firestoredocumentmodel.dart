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
  /// Data model for working with Firestore documents.
  ///
  /// You can use the same data structure of your Firestore documents.
  ///
  /// Fields are retrieved by [getString] and so on, documents are saved by [save] and deleted by [delete].
  ///
  /// Defines the data document of the specified [path].
  FirestoreDocumentModel(String path) : super(path);
  @override
  FutureOr<FirestoreDocument> build(ModelContext context) async {
    return FirestoreDocument.listen(this.path);
  }

  @override
  Future save(
      {Map<String, dynamic> data,
      void builder(FirestoreDocument document)}) async {
    FirestoreDocument state = this.state;
    if (state == null || state.isDisposed) {
      state = FirestoreDocument.create(this.path);
    }
    if (data != null) {
      for (MapEntry<String, dynamic> tmp in data.entries) {
        if (isEmpty(tmp.key) || tmp.value == null) continue;
        state[tmp.key] = tmp.value;
      }
    }
    if (builder != null) {
      builder(state);
    }
    await state.save();
  }
}
