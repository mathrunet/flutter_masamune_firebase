part of masamune.firebase;

/// GeoData for Firestore.
class FirestoreGeoData extends GeoData {
  final GeoFirePoint _geoFirePoint;

  /// Location name.
  String get name {
    if (isNotEmpty(this._name)) return this._name;
    return "$latitude,$longitude";
  }

  final String _name;

  /// GeoData for Firestore.
  FirestoreGeoData({double latitude, double longitude, String name})
      : this._geoFirePoint = GeoFirePoint(latitude ?? 0, longitude ?? 0),
        this._name = name;

  /// GeoData for Firestore.
  FirestoreGeoData.fromGeoPoint(GeoPoint geoPoint, {String name})
      : this(
            latitude: geoPoint.latitude,
            longitude: geoPoint.longitude,
            name: name);

  /// GeoData for Firestore.
  FirestoreGeoData.fromGeoData(GeoData geoData, {String name})
      : this(
            latitude: geoData.latitude,
            longitude: geoData.longitude,
            name: name ?? geoData.name);

  /// Latitude.
  double get latitude => this._geoFirePoint.latitude ?? 0;

  /// Longitude.
  double get longitude => this._geoFirePoint.longitude ?? 0;

  /// Geographical distance between two Co-ordinates.
  static double distanceBetween(
      {@required Coordinates to, @required Coordinates from}) {
    return GeoFirePoint.distanceBetween(to: to, from: from);
  }

  /// Neighboring geo-hashes of [hash].
  static List<String> neighborsOf({@required String hash}) {
    return GeoFirePoint.neighborsOf(hash: hash);
  }

  /// Hash of [GeoData].
  @override
  String get hash {
    return this._geoFirePoint.hash;
  }

  /// All neighbors of [GeoData].
  @override
  List<String> get neighbors {
    return this._geoFirePoint.neighbors;
  }

  /// [GeoPoint] of [GeoData].
  GeoPoint get geoPoint {
    return this._geoFirePoint.geoPoint;
  }

  /// [Coorinates] of [GeoData].
  Coordinates get coords {
    return this._geoFirePoint.coords;
  }

  /// Calculate the distance between two points.
  ///
  /// [data]: GeoData.
  @override
  double distance(GeoData data) {
    return distanceBetween(
        from: coords, to: Coordinates(data.latitude, data.longitude));
  }

  /// Raw data.
  get data {
    return {'geopoint': this.geoPoint, 'geohash': this.hash};
  }
}
