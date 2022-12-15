import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:database_todo/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:database_todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:database_todo/modules/new_tasks/new_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
{
  int currentIndex = 0;
  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  List<String> titles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
        ),
      ),
      body: ConditionalBuilder(
          condition: tasks.isNotEmpty,
          builder: (context) =>  screens[currentIndex],
          fallback: (context) => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(isBottomSheetShown)
          {
            if(formKey.currentState?.validate() != null)
              {
                insertToDatabase(
                  title: titleController.text,
                  date: dateController.text,
                  time: timeController.text,
                ).then((value)
                {
                  getDataFromDatabase(database).then((value)
                  {
                    Navigator.pop(context);
                    setState(()
                    {
                      isBottomSheetShown = false;
                      fabIcon = Icons.edit;
                      tasks = value;
                      print(tasks);
                    });
                  });

                });
              }

          } else
            {
              scaffoldKey.currentState!.showBottomSheet(
                    (context) => Container(
                color:  Colors.white,
                padding: const EdgeInsets.all(20.0,),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultFormField(
                        controller: titleController,
                        type: TextInputType.text,
                        validate: (String? value)
                          {
                            if(value!.isEmpty)
                              {
                                return 'title must not be empty';
                              }
                            return value;
                          },
                        label: 'Task Title',
                        prefix: Icons.title,
                      ),
                      const SizedBox(height: 15.0,
                      ),
                      defaultFormField(
                        controller: timeController,
                        type: TextInputType.datetime,
                        onTap: ()
                          {
                            showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                            ).then((value)
                            {
                              timeController.text = value!.format(context).toString();
                              print(value.format(context));
                            });
                          },
                        validate: (String? value)
                          {
                            if(value!.isEmpty)
                              {
                                return 'time must not be empty';
                              }
                            return value;
                          },
                        label: 'Task Time',
                        prefix: Icons.watch_later_outlined,
                        ),
                      const SizedBox(height: 15.0,
                      ),
                      defaultFormField(
                        controller: dateController,
                        type: TextInputType.datetime,
                        isClickable: false,
                        onTap: ()
                        {
                         showDatePicker(
                             context: context,
                             initialDate: DateTime.now(),
                             firstDate: DateTime.now(),
                             lastDate: DateTime.parse('2022-12-31'),
                         ).then((value)
                         {
                           dateController.text = DateFormat.yMMMd().format(value!);
                         });
                        },
                        validate: (String? value)
                        {
                          if(value == null || value.isEmpty)
                          {
                            return 'date must not be empty';
                          }
                          return value;
                        },
                        label: 'Task Date',
                        prefix: Icons.calendar_today,
                         ),
                      ],
                    ),
                  ),
                ),
                    elevation: 20.0,
              ).closed.then((value) {
                isBottomSheetShown = false;
                setState(() {
                  fabIcon = Icons.edit;
                });
              });
              isBottomSheetShown = true;
              setState(() {
                fabIcon = Icons.add;
              });
            }
          // getName().then((value){
          //   print(value);
          //   print('shady');
          // }).catchError((error){
          //   print('error is ${error.toString()}');
          // });
         // formKey.currentState!.save();
        },
          // onPressed: () async {
          //   try {
          //     var name = await getName();
          //     print(name);
          //   } catch(error) {
          //     print('error ${error.toString()}');
          //   }
          // },
          child: Icon(
            fabIcon,
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
          elevation: 0.0,
          currentIndex: currentIndex,
          onTap: (index)
          {
            setState(() {
              currentIndex = index;
            });
          },
          items:
          const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.menu,
                ),
                label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.check_circle_outline,
              ),
              label: 'Done',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.archive_outlined,
              ),
              label: 'Archived',
            ),
          ]
        ),
    );
  }

  Future<String> getName() async {
    return 'Sheko madrid';
  }

  void createDatabase() async {
    database = await openDatabase(
      'todoo.db',
      version: 1,
      onCreate: (database,version)
        {
          print('database created');
          database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value)
          {
            print('table created');
          }).catchError((error) {
            print('error while creating table ${error.toString()}');
          });
        },
      onOpen: (database)
        {
          getDataFromDatabase(database).then((value)
          {
            setState(()
            {
              tasks = value;
              // print(tasks);
            });
          });
          //print('database opened');
        },
    );
  }


  Future insertToDatabase({
      required String title,
      required String time,
      required String date,
    }) async {
  await database.transaction((txn)
  {
    return txn.rawInsert(
     'INSERT INTO tasks(title, time, date, status) VALUES("$title", "$time", "$date", "new")',
    ).then((value) {
      print('$value inserted successfully');
    }).catchError((error) {
      print('Error when Inserting New Record ${error.toString()}');
    });
  });
}

  Future<List<Map>> getDataFromDatabase(database) async
  {
    return await database.rawQuery('SELECT * FROM tasks');
  }

}
