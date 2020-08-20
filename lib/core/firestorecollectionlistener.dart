part of masamune.firebase;

class _FirestoreCollectionListener {
  Query reference;
  StreamSubscription<QuerySnapshot> listener;
  QuerySnapshot snapshot;
  List<String> removed = [];
  DocumentSnapshot last;
  Map<String, Map<String, dynamic>> data;
  int index;
  Future reset() async {
    if (this.listener != null) await this.listener.cancel();
    this.reference = null;
    this.snapshot = null;
    this.last = null;
    this.data = null;
    this.removed.clear();
  }

  _FirestoreCollectionListener();
}
