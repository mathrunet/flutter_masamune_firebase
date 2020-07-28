part of masamune.firebase;

/// Utility for realizing folder structure.
class FirestoreFolderStructureUtility {
  /// Key to save the path.
  static const String pathKey = "@path";

  /// key to save all folders.
  static const String dirKey = "@dir";

  /// Create the data for the folder structure.
  ///
  /// [data]: Data to save.
  /// [path]: Folder path to save this document.
  static FirestoreDocument apply(FirestoreDocument data,
      {@required String path}) {
    assert(data != null);
    assert(isNotEmpty(path));
    if (data == null || isEmpty(path)) return data;
    path = path.trimString(Const.slash);
    data[pathKey] = path;
    List<String> out = [];
    List<String> paths = Paths.split(path);
    for (int i = 0; i < paths.length; i++) {
      out.add(paths.sublist(0, i + 1).join(Const.slash));
    }
    data[dirKey] = out;
    return data;
  }

  /// Create a query for the folder structure.
  ///
  /// [path]: Specify the folder path.
  /// [inccludeSubFolder]: True to search including subfolders.
  static FirestoreQuery query(String path, {bool includeSubFolder = false}) {
    assert(isNotEmpty(path));
    path = path.trimString(Const.slash);
    if (isEmpty(path)) return null;
    if (includeSubFolder) {
      return FirestoreQuery.equalTo(pathKey, path);
    } else {
      return FirestoreQuery.contains(dirKey, path);
    }
  }
}
