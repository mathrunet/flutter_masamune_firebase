part of masamune.firebase;

/// Callback for converting with metadata.
typedef FirestoreMetaFilter = dynamic Function(
    String key, dynamic value, Map<String, dynamic> data);
