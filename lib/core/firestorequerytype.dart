part of masamune.firebase;

/// Defines the Firestore query type.
enum FirestoreQueryType {
  /// No type.
  none,

  /// Equals.
  equalTo,

  /// Lower, the same value is included.
  lowerThan,

  /// Higher, the same value is included.
  higherThan,

  /// Range.
  range,

  /// Whether or not the array contains the given value.
  arrayContains,

  /// Checks if a value is contained in an array in the given array.
  arrayContainsAny,

  /// All elements that match what is given in the list.
  inArray,

  /// Check to see if you are within range of the location.
  withIn,

  /// Empty query. The element is always empty.
  empty,
}
