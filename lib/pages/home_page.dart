import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/heatmap.dart';
import 'package:habit_tracker/database/habit_db.dart';
import 'package:habit_tracker/theme/themeProvider.dart';
import 'package:provider/provider.dart';

import '../components/theme_drawer.dart';
import '../models/habit.dart';
import '../util/habit_utilities.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController newHabit = TextEditingController();

  @override
  void initState() {
    // read existing habits
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: TextField(
            controller: newHabit,
            decoration: const InputDecoration(
              hintText: "Create a new habit"
            ),
          ),
          actions: [
            // save
            MaterialButton(
                onPressed: (){
                  // get controller value
                  String newHabitName = newHabit.text;
                  // save to db
                 context.read<HabitDatabase>().addHabit(newHabitName);

                 Navigator.pop(context);

                 newHabit.clear();
                },
                child: const Text("Save"),
            ),
            //cancel
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);

                newHabit.clear();
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
    );
  }

  void checkHabit(bool? value, Habit habit){
    // update status
    if(value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit){
    newHabit.text = habit.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: TextField(
          controller: newHabit,
          decoration: const InputDecoration(
              hintText: "Rename a habit"
          ),
        ),
        actions: [
          // save
          MaterialButton(
            onPressed: (){
              // get controller value
              String newHabitName = newHabit.text;
              // save to db
              context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);

              Navigator.pop(context);

              newHabit.clear();
            },
            child: const Text("Save"),
          ),
          //cancel
          MaterialButton(
            onPressed: (){
              Navigator.pop(context);

              newHabit.clear();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void deleteHabitBox(Habit habit){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text('You are about to delete this habit? Do you wish to proceed?'),
        actions: [
          // save
          MaterialButton(
            onPressed: (){
              context.read<HabitDatabase>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
          //cancel
          MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const ThemeDrawer(),
      floatingActionButton: FloatingActionButton(
          onPressed: createNewHabit,
        shape: const CircleBorder(),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
            Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          //heat map
          _buildHeatMap(),
          // list
          _habitList()
        ],
      ),
    );
  }

  Widget _buildHeatMap(){
    final habitDb = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDb.currentHabits;

    return FutureBuilder<DateTime?>(
        future: habitDb.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // once the data is available -> build hear map
          if(snapshot.hasData){
            return HeatMapCalendar(
                startDate: snapshot.data!,
                datasets: prepareHeatMapDataset(currentHabits)
            );
          } else {
            return Container();
          }
        },
    );
  }

  Widget _habitList(){
    final habitDB = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDB.currentHabits;

    return ListView.builder(
      shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          // get each habit
          final habit = currentHabits[index];

          // check if completed for the day or not
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          // return said habit in a tile
          return HabitTile(
            habit: habit,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabit(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        },
    );
  }
}
