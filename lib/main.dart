import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<List<User>> fetchpp(http.Client client) async {
  final response =
      await client.get(Uri.parse('https://fakeface.rest/face/json'));

  return compute(parser, response.body);
}

List<User> parser(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<User>((json) => User.fromJson(json)).toList();
}

class User {
  final int age;
  final String gender;
  final String imageUrl;

  User({
    required this.age,
    required this.gender,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      age: json['age'] as int,
      gender: json['title'] as String,
      imageUrl: json['url'] as String,
    );
  }
}

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MaterialApp(home: CameraApp()));
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Text("Savings", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            child: Text(
              "Pay Through UPI",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            ),
            alignment: Alignment.centerLeft,
            widthFactor: 2.9,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
            child: TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(2),
                  border: UnderlineInputBorder(),
                  hintText: 'Enter UPI Number'),
            ),
          ),
          // Transform.scale(
          //   scale: 1,
          //   child: Center(
          //     child: AspectRatio(
          //       aspectRatio: 1,
          //       child: CameraPreview(controller),
          //     ),
          //   ),
          // ),

          SizedBox(height: 75.0),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.book),
                      //contentPadding: EdgeInsets.only(top: 0, left: 25),
                      hintText: 'Select Number',
                      hintStyle: TextStyle(fontSize: 17.0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: FutureBuilder<List<User>>(
                    future: fetchpp(http.Client()),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      if (snapshot.hasData) print("FJHSBZFHBJHCBJHCBHSHJV");

                      return snapshot.hasData
                          ? UserList(photos: snapshot.data!)
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final List<User> photos;

  UserList({Key? key, required this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Column(children: [
          Text("$photos[index].age"),
          Text(photos[index].imageUrl),
          Text(photos[index].gender)
        ]);
      },
    );
  }
}
