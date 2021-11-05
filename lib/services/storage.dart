import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  final _storage = FlutterSecureStorage();

  void add({String? key, String? value}) async {
    if (key == null) return;
    await _storage.write(
      key: key,
      value: value,
    );
  }

  void remove(String key) async {
    await _storage.delete(key: key);
  }

  Future<dynamic> get(String key) async {
    return await _storage.read(key: key);
  }

}