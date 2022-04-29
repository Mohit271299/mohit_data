import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestDatabase extends StatefulWidget {
  const TestDatabase({Key? key}) : super(key: key);

  @override
  _TestDatabaseState createState() => _TestDatabaseState();
}

class _TestDatabaseState extends State<TestDatabase> {
  DatabaseReference? _databaseReference;

  Query? ref;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.reference();
    ref = _databaseReference!.reference().child('User-Group');
  }

  String databasejson = '';
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController ageData = TextEditingController();
  TextEditingController jobData = TextEditingController();
  TextEditingController DoB = TextEditingController();
  TextEditingController searchUser = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: firstname,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your fname',
                  ),
                ),
                TextField(
                  controller: lastname,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your lnamre',
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: ageData,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'add your age',
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: jobData,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'job',
                  ),
                ),
                TextField(
                  controller: DoB,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'birth date',
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Counter++;
                      _createDatabase(
                          firstname.text,lastname.text, ageData.text, jobData.text,DoB.text);
                      print('Action performed');
                    },
                    child: const Text('create Database')),

                TextField(
                  controller: searchUser,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search user',
                  ),
                ),

                TextButton(
                    onPressed: () {
                      _getData(searchUser.text);
                      // _createDatabase(username.text, ageData.text,jobData.text);
                      // print('Action performed');
                    },
                    child: const Text('show Database')),

                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('user Details :'),
                      Text('ID : $searched_id'),
                      Text('name : $searched_name'),
                      Text('DOB : $searched_dob'),

                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  int Counter = 0;
  _createDatabase(String fname, String age, String job, String lname, String dob,) async {
    String key = _databaseReference!.child('Users').child("ListUsers").push().key;
    await _databaseReference!.child("Users").child('ListUsers').child(Counter.toString()).set({
      'id': Counter.toString(),
      'last-name': age,
      'DoB': job,

    });
    await _databaseReference!.child('UserDetails').child(Counter.toString()).set({
      'name': fname,
      'age': age,
      'job': job,
    });

    firstname.clear();
    lastname.clear();
    ageData.clear();
    jobData.clear();
    DoB.clear();
    searchUser.clear();
  }

  var data;
  String? searched_name;
  String? searched_dob;
  String? searched_id;

  _getData(String name) {
    _databaseReference!.child("Users").once().then((DataSnapshot dataSnapshot) {
      Map<dynamic, dynamic> values = dataSnapshot.value;
      print(values);
      values.forEach((key, value) {
        value.forEach((key1, value1) {
          if (value1["id"] == name) {
            setState(() {
              data = value1;
              searched_name = data["last-name"];
              searched_dob = data["DoB"];
              searched_id = data["id"];
            });
            print("innerdata");
            print(data);
          }
        });
        // print("data");
        // print(data);
        // print(key);
        // print(value);
      });
      // print(values);
    });
  }
}
