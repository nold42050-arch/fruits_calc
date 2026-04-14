import 'package:hive/hive.dart';
import '../models/fruit.dart';

class FruitService {
  static const String _boxName = 'fruits';

  static Future<Box<Fruit>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Fruit>(_boxName);
    }
    return Hive.box<Fruit>(_boxName);
  }

  static Future<List<Fruit>> getAllFruits() async {
    final box = await _getBox();
    return box.values.toList();
  }

  static Future<void> addFruit(Fruit fruit) async {
    final box = await _getBox();
    await box.add(fruit);
  }

  static Future<void> updateFruit(Fruit fruit) async {
    await fruit.save();
  }

  static Future<void> deleteFruit(Fruit fruit) async {
    await fruit.delete();
  }

  static Future<Box<Fruit>> getBox() async {
    return await _getBox();
  }
}
