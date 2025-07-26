import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/Pages/LogIn%20Related/ProfilePage.dart';
import 'addTaskPage.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget buildTaskCards({
    required BuildContext context,
    required Color color,
    required String title,
    required String description,
    required String dueDate,
    required String dueTime,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Due Date: $dueDate',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(description, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
              ),
              SizedBox(width: 6),
              Text(
                dueTime,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(6.0),
          child: Image.asset('assets/logo.png'),
        ),
        title: Text(
          'To Do List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            icon: Icon(Icons.person, color: Colors.lightBlue),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Tasks').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks available'));
                  }

                  final taskDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: taskDocs.length,
                    itemBuilder: (context, index) {
                      final task = taskDocs[index];
                      final data = task.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'No Title';
                      final description =
                          data['description'] ?? 'No Description';
                      final dueDate = data['date'] ?? 'No Due Date';
                      final dueTime = data['time'] ?? '10:00 am';
                      final color = Color(data['color']);
                      final docId = task.id;

                      return Dismissible(
                        key: Key(docId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await FirebaseFirestore.instance
                              .collection('Tasks')
                              .doc(docId)
                              .delete();
                        },
                        background: Container(
                          padding: EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: buildTaskCards(
                          dueDate: dueDate,
                          context: context,
                          color: color,
                          title: title,
                          description: description,
                          dueTime: dueTime,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddTaskPage()));
          // No need for setState with StreamBuilder
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
