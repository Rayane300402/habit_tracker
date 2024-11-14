// given a habit list of completion days
// is the habit completed today

import '../models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays){
  final today = DateTime.now();
  return completedDays.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
  );
}

// prepare heat map datasets

Map<DateTime, int> prepareHeatMapDataset(List<Habit> habits){
  Map<DateTime,int> dataset = {};

  for (var habit in habits){
    for (var date in habit.completedDays){
      // normalize date to avoid time mismatch
      final normalizeDate = DateTime(date.year,date.month, date.day);

      // if the date already exists in dataset, increment count
      if(dataset.containsKey(normalizeDate)){
        dataset[normalizeDate] = dataset[normalizeDate]! + 1;
      } else {
        // else initialize it at 1
        dataset[normalizeDate] = 1;
      }
    }
  }

  return dataset;
}