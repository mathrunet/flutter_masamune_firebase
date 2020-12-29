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
  FirestoreQuery.equalTo(String key, dynamic value) {
    this._type = FirestoreQueryType.equalTo;
    this._key = key;
    if (value is String)
      this.value = value.applyTags();
    else
      this.value = value;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.lowerThan(String key, double max) {
    this._type = FirestoreQueryType.lowerThan;
    this._key = key;
    this.value = max;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.higherThan(String key, double min) {
    this._type = FirestoreQueryType.higherThan;
    this._key = key;
    this.value = min;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.range(String key, num min, num max) {
    this._type = FirestoreQueryType.range;
    this._key = key;
    this.value = Range(min, max);
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.contains(String key, dynamic value) {
    this._type = FirestoreQueryType.arrayContains;
    this._key = key;
    if (value is String)
      this.value = value.applyTags();
    else
      this.value = value;
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.containsAny(String key, Iterable values) {
    if (values == null || values.length <= 0) {
      this._type = FirestoreQueryType.empty;
      this._key = null;
    } else {
      this._type = FirestoreQueryType.arrayContainsAny;
      this._key = key;
      this.contains.addAll(values?.map((e) {
            if (e is String) return e.applyTags();
            return e;
          })?.distinct());
    }
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [value]: Value to query.
  FirestoreQuery.inArray(String key, Iterable values) {
    if (values == null || values.length <= 0) {
      this._type = FirestoreQueryType.empty;
      this._key = null;
    } else {
      this._type = FirestoreQueryType.inArray;
      this._key = key;
      this.contains.addAll(values?.map((e) {
            if (e is String) return e.applyTags();
            return e;
          })?.distinct());
    }
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  ///
  /// [key]: Key to query.
  /// [location]: Central Location.
  /// [radius]: Radius that includes.
  FirestoreQuery.withIn(String key, GeoData location, [double radius = 1.0]) {
    if (location == null || radius <= 0) {
      this._type = FirestoreQueryType.empty;
      this._key = null;
    } else {
      this._type = FirestoreQueryType.withIn;
      this._key = key;
      this._geoData = location is FirestoreGeoData
          ? location
          : FirestoreGeoData.fromGeoData(location);
      this._value = radius;
      int precision = _GeoUtility.setPrecision(radius);
      String centerHash = this._geoData.hash.substring(0, precision);
      this._contains = GeoFirePoint.neighborsOf(hash: centerHash)
        ..add(centerHash);
    }
  }

  /// Set up a Firestore query.
  ///
  /// It is possible to query the collection by setting this in FirestoreCollection.
  FirestoreQuery.empty() {
    this._type = FirestoreQueryType.empty;
    this._key = null;
  }

  /// Sort in order.
  ///
  /// You can specify a sort key,
  /// but if you want to use a different key from the query key,
  /// you need to create a composite index.
  ///
  /// [key]: Key for sorting.
  FirestoreQuery.orderBy({String key, OrderBy orderBy}) {
    this._orderBy = orderBy;
    this._orderByKey = key;
  }

  /// Sort in ascending order.
  ///
  /// You can specify a sort key,
  /// but if you want to use a different key from the query key,
  /// you need to create a composite index.
  ///
  /// [key]: Key for sorting.
  FirestoreQuery.orderByAsc([String key]) {
    this._orderBy = OrderBy.asc;
    this._orderByKey = key;
  }

  /// Sort in descending order.
  ///
  /// You can specify a sort key,
  /// but if you want to use a different key from the query key,
  /// you need to create a composite index.
  ///
  /// [key]: Key for sorting.
  FirestoreQuery.orderByDesc([String key]) {
    this._orderBy = OrderBy.desc;
    this._orderByKey = key;
  }

  /// Set a limit on the number of items that can be retrieved by query.
  ///
  /// [limit]: Limit number.
  FirestoreQuery.limitAt([int limit]) {
    this._limit = limit == null ? -1 : limit.limit(0, 10000);
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

  /// True if the values are equal.
  ///
  /// [query]: Other queries.
  bool equals(FirestoreQuery query) {
    if (query == null) return false;
    return this._key == query._key &&
        this._limit == query._limit &&
        this._orderBy == query._orderBy &&
        this._orderByKey == query._orderByKey &&
        this._range.equals(query._range) &&
        this._type == query._type &&
        this._value == query._value &&
        this._contains.equals(query._contains);
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
      case FirestoreQueryType.withIn:
        return this._geoData;
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
      case GeoData:
        this._type = FirestoreQueryType.withIn;
        this._geoData = value as GeoData;
        break;
      case Range:
        this._type = FirestoreQueryType.range;
        this._range = value as Range;
        break;
      default:
        this._value = value;
        break;
    }
  }

  FirestoreGeoData _geoData;
  Range _range = Range(0, 1);
  dynamic _value = 0;

  /// Set a limit on the number of items that can be retrieved by query.
  ///
  /// [limit]: Limit number.
  FirestoreQuery limitAt([int limit]) {
    this._limit = limit == null ? -1 : limit.limit(0, 10000);
    return this;
  }

  /// Get the maximum number of elements by query.
  int get limit {
    return this._limit.limit(-1, 10000);
  }

  int _limit = -1;

  /// Array used in [arrayContainsAny] or [inArray].
  List get contains => this._contains;
  List _contains = ListPool.get();

  /// The number of query attempts.
  int get length {
    switch (this.type) {
      case FirestoreQueryType.inArray:
      case FirestoreQueryType.arrayContainsAny:
        return (this.contains.length / 10).ceil();
      case FirestoreQueryType.withIn:
        return this.contains.length;
      default:
        return 1;
    }
  }
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
  num min = 0;

  /// Maximum value.
  num max = 1;

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
  Range(num min, num max) {
    this.min = min;
    this.max = max;
  }

  /// True if the values are equal.
  ///
  /// [query]: Other value.
  bool equals(Range other) {
    if (other == null) return false;
    return this.min == other.min && this.max == other.max;
  }
}
