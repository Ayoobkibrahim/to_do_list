import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> task = [];
  List<bool> isCompleted = [];

  final taskController = TextEditingController();
  final contentController = TextEditingController();

  final box = Hive.box("todo_box");

  @override
  void initState() {
    isCompleted.add(false);
    refreshUI();
    print(task);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(task);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade300,
        title: Text(
          "TO DO LIST",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.amber.shade800),
        ),
      ),
      body: task.isEmpty
          ? const Center(
        child: Text("No items here..."),
      )
          : ListView.builder(
        itemCount: task.length,
        itemBuilder: (context, index) => ListTile(
          leading: Checkbox(
              value: isCompleted![index],
              onChanged: (value) {
                setState(() {
                  isCompleted![index] = value!;
                });
              }),
          title: isCompleted[index] == false
              ? Text(task[index]["taskname"])
              : Text(
            task[index]["taskname"],
            style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey),
          ),
          subtitle: isCompleted[index] == false
              ? Text(task[index]["taskcontent"])
              : Text(
            task[index]["taskcontent"],
            style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey),
          ),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  try {
                    createOrUpdateTask(task[index]["id"]);
                  } catch (e) {
                    print(e);
                  }
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  deleteTask(task[index]["id"]);

                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => createOrUpdateTask(null),
        label: const Text("Add your todo"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void createOrUpdateTask(int? key) {
    if (key != null) {
      final existing_task = task.firstWhere((element) => element['id'] == key);
      taskController.text = existing_task["task_name"];
      contentController.text = existing_task["task_content"];
    }
    if (key == null) {
      showModalBottomSheet(
          isScrollControlled: true,
          elevation: 5,
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: "Enter your task here",
                    ),
                  ),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: "Enter your task decription",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (key == null) {
                        createTask({
                          "task_name": taskController.text.trim(),
                          "task_content": contentController.text.trim(),
                          "task_checked": isCompleted.last,
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Task created successfully")));
                      } else if (key != null) {
                        editTask(key, {
                          "task_name": taskController.text.trim(),
                          "task_content": contentController.text.trim(),
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: key == null
                        ? const Text("Create")
                        : const Text("Update"),
                  ),
                ],
              ),
            );
          });
    }
  }

  void createTask(Map<String, Object> newTask) async {
    await box.add(newTask);
    refreshUI();
  }

  void refreshUI() {
    final task_from_hive = box.keys.map((key) {
      final single_key = box.get(key);
      return {
        "id": key,
        "taskname": single_key["task_name"],
        "taskcontent": single_key["task_content"],
        "isCheck": single_key["task_checked"]
      };
    }).toList();

    setState(() {
      task = task_from_hive.reversed.toList();
      for (int index = 0; index < task.length; index++) {
        isCompleted!.add(task[index]["isCheck"]);
      }
    });
  }

  Future<void> editTask(int key, Map<String, dynamic> task) async {
    await box.put(key, task);
    refreshUI();
  }

  Future<void> deleteTask(int itemKey) async {
    await box.delete(itemKey);
    refreshUI();
  }
}