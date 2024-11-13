import 'package:isar/isar.dart';

// to generate: dart run build_runner build
part 'habit.g.dart';

@Collection()
class Habit {
  //id
  Id id = Isar.autoIncrement;

  //name
  late String name;

  // list of completed days
  List<DateTime> completedDays = [
    // DateTime(year, month, day)
  ];



}