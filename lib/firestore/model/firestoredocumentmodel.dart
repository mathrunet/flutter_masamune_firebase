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

  Future saveAll(
      {Map<String, dynamic> data,
      void builder(FirestoreDocument document)}) async {
    FirestoreDocument state = await FirestoreDocument.listen(this.path);
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
