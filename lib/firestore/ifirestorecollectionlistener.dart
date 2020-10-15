part of masamune.firebase;

abstract class IFirestoreCollectionListener
    implements ICollection<FirestoreDocument> {
  // ignore: unused_element
  void _removeChildInternal(FirestoreDocument document);
  // ignore: unused_element
  void _addChildInternal(FirestoreDocument document);
}
