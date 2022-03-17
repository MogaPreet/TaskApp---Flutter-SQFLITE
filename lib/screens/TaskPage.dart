import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/database_helper.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/widgets.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  TaskPage({required this.task});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  DatabaseHelper _dbhelper = DatabaseHelper();
  String _taskTitle = "";
  String _taskDescription = "";

  int? _taskId = 0;
  FocusNode? _titleFocus;
  FocusNode? _descriptionFocus;
  FocusNode? _todoFocus;

  bool _contentVisibility = false;

  @override
  void initState() {
    if (widget.task != null) {
      _taskTitle = widget.task!.title;
      _taskId = widget.task!.id;
      _taskDescription = widget.task!.description;
      _contentVisibility = true;
    }
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _titleFocus?.dispose();
    _descriptionFocus?.dispose();
    _todoFocus?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 6.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/back_arrow_icon.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              if (value != "") {
                                if (widget.task == null) {
                                  Task _newTask =
                                      Task(title: value, description: "");
                                  _taskId = await _dbhelper.insetTask(_newTask);
                                  setState(() {
                                    _contentVisibility = true;
                                    _taskTitle = value;
                                  });
                                  print('New Task Id: ${_taskId}');
                                } else {
                                  await _dbhelper.updateTaskTitle(
                                      _taskId!, value);
                                  print('Task is Updated');
                                }
                                _descriptionFocus?.requestFocus();
                              }
                            },
                            controller: TextEditingController()
                              ..text = _taskTitle,
                            decoration: InputDecoration(
                              hintText: 'Enter Task Title',
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                                fontSize: 24.0,
                                color: Color(0xFF211551),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _contentVisibility,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        focusNode: _descriptionFocus,
                        onSubmitted: (value) {
                          if (value != "") {
                            if (_taskId != 0) {
                              _dbhelper.updateTaskDescription(_taskId!, value);
                              _taskDescription = value;
                            }
                          }
                          _todoFocus?.requestFocus();
                        },
                        controller: TextEditingController()
                          ..text = _taskDescription,
                        decoration: InputDecoration(
                            hintText: 'Enter Description for the Task',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            )),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    initialData: [],
                    future: _dbhelper.getTodo(_taskId!),
                    builder: (context, AsyncSnapshot snapshot) {
                      return Expanded(
                        child: ScrollConfiguration(
                          behavior: NoScrollBehavior(),
                          child: ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    if (snapshot.data[index].isDone == 0) {
                                      await _dbhelper.updateTodoDone(
                                          snapshot.data[index].id, 1);
                                    } else {
                                      await _dbhelper.updateTodoDone(
                                          snapshot.data[index].id, 0);
                                    }
                                    setState(() {});
                                  },
                                  child: TodoWidget(
                                    text: snapshot.data[index].title,
                                    isDone: snapshot.data[index].isDone == 0
                                        ? false
                                        : true,
                                  ),
                                );
                              }),
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: _contentVisibility,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            margin: EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                    color: Color(0xFF868290), width: 1.5)),
                            child: Image(
                              image: AssetImage('assets/images/check_icon.png'),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            focusNode: _todoFocus,
                            controller: TextEditingController()..text = "",
                            onSubmitted: (value) async {
                              if (value != "") {
                                if (_taskId != null) {
                                  DatabaseHelper _dbhelper = DatabaseHelper();
                                  Todo _newTodo = Todo(
                                    title: value,
                                    isDone: 0,
                                    taskId: _taskId,
                                  );
                                  await _dbhelper.insetTodo(_newTodo);
                                  setState(() {});
                                  _todoFocus?.requestFocus();
                                } else {
                                  print('Task Doesnot exist');
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter Todo Item...',
                              border: InputBorder.none,
                            ),
                          ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                visible: _contentVisibility,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (_taskId != 0) {
                        await _dbhelper.deleteTask(_taskId!);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFFE3572),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Image(
                        image: AssetImage('assets/images/delete_icon.png'),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
