import 'package:hive/hive.dart';

part 'fruit.g.dart';

@HiveType(typeId: 0)
class Fruit extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double pricePerKg;

  Fruit({required this.name, required this.pricePerKg});
}
