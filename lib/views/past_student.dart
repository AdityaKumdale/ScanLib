import 'package:flutter/material.dart';
import 'package:library_qr/model/database.dart';
import 'package:library_qr/Api/calculate_total_time.dart';

class PastStudent extends StatefulWidget {
  const PastStudent({super.key});
  @override
  PastStudentState createState() => PastStudentState();
}

class PastStudentState extends State<PastStudent> {
  late Future<List<ArchiveStudent>> paststudent;
  int count = 0;
  late AppDb db;
  late TotalTime _totalTime;

  @override
  void initState() {
    super.initState();
    db = AppDb.instance;
    _totalTime = TotalTime();
    fetchstudent();  // Initialize fetching students
  }

  Future<void> fetchstudent() async {
    final pastList = await db.archiveStudentDao.fetchStudents();
    setState(() {
      paststudent = Future.value(pastList);
      count = pastList.length;
    });
  }

  void _deleteAllEntries() async {
    await db.archiveStudentDao.deleteall();
    fetchstudent();  // Refresh the list after deletion
  }

  @override
  void dispose() {
    // Clean up resources here if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAllEntries,
          ),
        ],
      ),
      body: FutureBuilder<List<ArchiveStudent>>(
        future: paststudent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Student'),);
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final archiveStudent = snapshot.data![index];
                final totalTimeString = _totalTime.calculateTotalTime(
                    archiveStudent.intime,
                    archiveStudent.outtime
                );
                return Card(
                  child: ListTile(
                    title: Text(archiveStudent.name ),
                    subtitle: Text('Roll No: ${archiveStudent.rollno}\nIntime: ${archiveStudent.intime}\nOuttime: ${archiveStudent.outtime}\nDep: ${archiveStudent.department}\nTotal Time: $totalTimeString'),
                  ));
              },
            );
          }
        },
      ));
  }
}