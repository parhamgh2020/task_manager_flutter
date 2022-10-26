import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _deviceWidth, _deviceHeight;

  Box? _box;

  // _HomePageState();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      floatingActionButton: _floatbuttonWidget(),
    );
  }

  FloatingActionButton _floatbuttonWidget() => FloatingActionButton(
        onPressed: _displayTaskPopup,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      );

  Widget _bodyWidget() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _taskList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      toolbarHeight: _deviceHeight * 0.15,
      centerTitle: true,
      backgroundColor: Colors.blue,
      title: const Text(
        'Task Manager',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.01,
            vertical: _deviceHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(color: Colors.black),
          ),
          child: ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              task.timestamp.toString(),
            ),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.blue,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(
                _index,
                task.toMap(),
              );
              setState(() {});
            },
            onLongPress: () {
              _box!.deleteAt(_index);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("add a task"),
          content: TextField(
            autocorrect: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                var task = Task(
                  content: value,
                  timestamp: DateTime.now(),
                  done: false,
                );
                _box!.add(task.toMap());
                setState(() {
                  Navigator.pop(context);
                });
              }
            },
          ),
        );
      },
    );
  }
}
