import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  // init db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // save first date of app startup
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // CRUD OPERATIONS

  // habits list
  final List<Habit> currentHabits = [];

  // create - add a new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  // read - read saved habits from db
  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  // update - check habit on and off - if it's completed or not
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final currentHabit = await isar.habits.get(id);
    if (currentHabit != null) {
      await isar.writeTxn(() async {
        // if habit true -> add current date  to the list
        if (isCompleted &&
            !currentHabit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          currentHabit.completedDays
              .add(DateTime(today.year, today.month, today.day));
        } else {
          // remove current date from list
          currentHabit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        await isar.habits.put(currentHabit);
      });
    }

    readHabits();
  }

  // update - edit the name of the habit
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }

    readHabits();
  }

  // delete - delete habit
  Future<void> deleteHabit(int id) async{
    await isar.writeTxn(() async{
      await isar.habits.delete(id);
    });
    readHabits();
  }

}
