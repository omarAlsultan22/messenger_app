import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class HiveOperations {
  static Box<List<QuestionsData>>? _box;//how to change type in every time


  static Box get box {
    if (_box == null) {
      throw Exception('HiveOperations not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QuestionModelAdapter());
    _box = await Hive.openBox<List<QuestionsData>>('article');
    print('Box is opened..................');
  }

  static Future<void> putLocalData({
    required QuestionsData result,
  }) async {
    try {
      await box.put(result.lastDocument, result);
      await box.flush();
      print("Data is done.........................");
    } catch (e) {
      print("Error saving local data: $e");
    }
  }

  static Future<QuestionsData?> getLocalData(DocumentSnapshot? lastDocument) async {
    return await box.get(lastDocument);
  }

  static Future<void> clearData() async {
    await box.clear();
  }

  static Future<void> deleteData(DocumentSnapshot lastDocument) async {
    await box.delete(lastDocument);
  }

  static Future<void> closeBox() async {
    await box.flush();
    await _box?.close();
    await Hive.close();
  }
}