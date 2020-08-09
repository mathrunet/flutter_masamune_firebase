part of masamune.firebase;

abstract class IFirestoreCollectionListener
    implements ICollection<FirestoreDocument> {
  void _removeChildInternal(FirestoreDocument document);
  void _addChildInternal(FirestoreDocument document);
}
