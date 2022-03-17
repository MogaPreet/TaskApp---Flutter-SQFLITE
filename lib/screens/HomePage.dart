import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/database_helper.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/screens/TaskPage.dart';
import 'package:todo_app/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _dbhelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Color(0xFFF6F6F6),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 24.0,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 32.0, top: 32.0),
                    child: Row(children: [
                      Image(
                        image: AssetImage('assets/images/logo.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text(
                          "Fast Tasks",
                          style: TextStyle(
                              fontSize: 34.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B54FA)),
                        ),
                      ),
                    ])),
                Expanded(
                  child: FutureBuilder(
                    future: _dbhelper.getTasks(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Task>> snapshot) {
                      return ScrollConfiguration(
                        behavior: NoScrollBehavior(),
                        child: ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TaskPage(
                                              task: snapshot.data![index],
                                            ))).then((value) {
                                  setState(() {});
                                });
                              },
                              child: TaskCardWidget(
                                  title: snapshot.data![index].title,
                                  description:
                                      snapshot.data![index].description),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 24.0,
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskPage(
                          task: null,
                        ),
                      )).then((value) {
                    setState(() {});
                  });
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF7349FE), Color(0xFF643FD8)],
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image(
                    image: AssetImage('assets/images/add_icon.png'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
