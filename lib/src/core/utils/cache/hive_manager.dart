import 'package:general/src/core/index.dart';

class HiveManager {
  static final HiveManager instance = HiveManager._internal();

  factory HiveManager() => instance;

  HiveManager._internal();

  /// Open a Hive box if not already open
  Future<Box> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  /// Save data into Hive box
  Future<void> saveData<T>(String boxName, String key, T value) async {
    try {
      Box box = await openBox(boxName);
      await box.put(key, value);
      // Methods.printLog("Data saved in $boxName with key $key");
    } catch (e) {
      Methods.printLog("Error saving data in $boxName: $e");
    }
  }

  /// Get data from Hive box
  T? getData<T>(String boxName, String key, {T? defaultValue}) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        return box.get(key, defaultValue: defaultValue);
      } else {
        Methods.printLog("Box $boxName is not open.");
      }
    } catch (e) {
      Methods.printLog("Error retrieving data from $boxName: $e");
    }
    return defaultValue;
  }

  /// Delete data from Hive box
  Future<void> deleteData(String boxName, String key) async {
    try {
      Box box = await openBox(boxName);
      await box.delete(key);
      Methods.printLog("Data deleted in $boxName with key $key");
    } catch (e) {
      Methods.printLog("Error deleting data in $boxName: $e");
    }
  }

  /// Close a Hive box if it is open
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all open Hive boxes
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}
