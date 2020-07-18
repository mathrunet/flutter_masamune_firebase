part of masamune.firebase;

/// Set up a Firestore query.
///
/// It is possible to query the collection by setting this in FirestoreCollection.
///
/// ```
/// FirestoreQuery.equalTo( "Name", "mathru" );
/// ```
class FirestoreQuery {
  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  FirestoreQuery() {
    this._key = null;
    this._type = FirestoreQueryType.none;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.equalTo(String key, dynamic value,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.equalTo;
    this._key = key;
    this.value = value;
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.lowerThan(String key, double max,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.lowerThan;
    this._key = key;
    this.value = max;
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.higherThan(String key, double min,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.higherThan;
    this._key = key;
    this.value = min;
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.range(String key, double min, double max,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.range;
    this._key = key;
    this.value = Range(min, max);
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.contains(String key, dynamic value,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.arrayContains;
    this._key = key;
    this.value = value;
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.containsAny(String key, Iterable values,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.arrayContainsAny;
    this._key = key;
    this.contains.addAll(values);
    this.limit = limit;
    this.index = index;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  /// [limit]: Maximum number to get.
  /// [index]: Number of acquired pages.
  FirestoreQuery.inArray(String key, Iterable values,
      {int limit = -1, int index = 0}) {
    this._type = FirestoreQueryType.inArray;
    this._key = key;
    this.contains.addAll(values);
    this.limit = limit;
    this.index = index;
  }

  /// Set the query type.
  FirestoreQueryType get type => this._type;
  FirestoreQueryType _type = FirestoreQueryType.none;

  /// Query key.
  String get key => this._key;
  String _key;

  /// Sort in ascending order.
  ///
  /// You can specify a sort key,
  /// but if you want to use a different key from the query key,
  /// you need to create a composite index.
  ///
  /// [key]: Key for sorting.
  FirestoreQuery orderByAsc([String key]) {
    this._orderBy = OrderBy.asc;
    this._orderByKey = key;
    return this;
  }

  /// Sort in descending order.
  ///
  /// You can specify a sort key,
  /// but if you want to use a different key from the query key,
  /// you need to create a composite index.
  ///
  /// [key]: Key for sorting.
  FirestoreQuery orderByDesc([String key]) {
    this._orderBy = OrderBy.desc;
    this._orderByKey = key;
    return this;
  }

  /// Order by.
  OrderBy get orderBy => this._orderBy;
  OrderBy _orderBy = OrderBy.none;

  /// Order by key.
  String get orderByKey => this._orderByKey;
  String _orderByKey;

  /// The actual value to query.
  ///
  /// The contents change depending on the type.
  ///
  /// [Range] class if [type] is [FirestoreQueryType.range].
  ///
  /// Otherwise a string or number is returned.
  dynamic get value {
    switch (this.type) {
      case FirestoreQueryType.range:
        return this._range;
      default:
        return this._value;
    }
  }

  /// The actual value to query.
  ///
  /// The contents change depending on the type.
  ///
  /// [value] is [Range], [type] will be changed to [FirestoreQueryType.range].
  ///
  /// [value]: The actual value to query.
  set value(dynamic value) {
    switch (value.runtimeType) {
      case Range:
        this._type = FirestoreQueryType.range;
        this._range = value as Range;
        break;
      default:
        this._value = value;
        break;
    }
  }

  Range _range = Range(0, 1);
  dynamic _value = 0;

  /// Get the maximum number of elements by query.
  int get limit {
    return this._limit.limit(-1, 10000);
  }

  /// Set the maximum number of elements by query.
  ///
  /// Automatically set to -1 if less than 0.
  set limit(int value) {
    this._limit = value.limit(-1, 10000);
  }

  int _limit = -1;

  /// Array used in [arrayContainsAny] or [inArray].
  List get contains => this._contains;
  List _contains = ListPool.get();

  /// Number of pages obtained by limiting the query.
  int get index => this._index;

  /// Number of pages obtained by limiting the query.
  ///
  /// [index]: Index.
  set index(int index) => this._index = index.limitLow(0);
  int _index = 0;
}

/// Range class.
///
/// Enter minimum and maximum values to define.
///
/// ```
/// var range = Range( 0, 5 );
/// ```
class Range {
  /// Minimum value.
  double min = 0;

  /// Maximum value.
  double max = 1;

  /// Range class.
  ///
  /// Enter minimum and maximum values to define.
  ///
  /// ```
  /// var range = Range( 0, 5 );
  /// ```
  ///
  /// [min]: Minimum value.
  /// [max]: Maximum value.
  Range(double min, double max) {
    this.min = min;
    this.max = max;
  }
}
