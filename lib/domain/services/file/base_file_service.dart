import 'dart:convert';
import 'dart:io';

abstract class BaseFileService {
  Future<Map<String, dynamic>> readJson(String assetPath) async {
    final file = File(assetPath);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> init(String assetPath);
}
