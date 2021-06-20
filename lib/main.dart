import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<User> _getUsers() async {
  http.Response response =
      await http.get(Uri.parse("https://fakeface.rest/face/json"));

  if (response.statusCode == 200) {
    print("CoNECCTIoN SECURED \n");
    print(response.body);
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to load");
  }
}

late final String img;

class User {
  final int age;
  final String gender;
  final String image_url;

  User({
    required this.age,
    required this.gender,
    required this.image_url,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      age: json['age'],
      gender: json['gender'],
      image_url: json['image_url'],
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
  late Future<User> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = _getUsers();
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Text("Savings", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Column(
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
                padding:
                    const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                child: TextField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(2),
                      border: UnderlineInputBorder(),
                      hintText: 'Enter UPI Number'),
                ),
              ),
                            SizedBox(height: 40.0),

              Transform.scale(
                scale: 1,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
              SizedBox(height: 75.0),
            ],
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.13,
              maxChildSize: 0.5,
              builder: (BuildContext context, s) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.only( 
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                      )
                    ),
                    child: FutureBuilder<User>(
                        future: futureUsers,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          return ListView.builder(
                              padding: EdgeInsets.all(8.0),
                              controller: s,
                              itemCount: 5,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  //img = snapshot.data!.image_url;
                                  return Column(
                                    children: [Padding(child: Text("Search Contact" ,style:TextStyle(color: Colors.black, fontWeight: FontWeight.bold,  ),),padding: EdgeInsets.all(10.0),  ),
                                      TextField(
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.book ),
                                          contentPadding: EdgeInsets.only(
                                              top: 15.0, left: 10.0),
                                          hintText: 'Select Number',
                                          hintStyle: TextStyle(fontSize: 17.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  if (snapshot.hasData) {
                                    return ListTile(
                                        contentPadding: EdgeInsets.all(8.0),
                                        title: Text("Naman Gupta"),
                                        subtitle: Text(snapshot.data.gender),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data!.image_url),
                                          radius: 30.0,
                                        ));
                                  } else
                                    return Container(
                                      child: Center(
                                        child: Text("LOADING ......."),
                                      ),
                                    );
                                }
                              });
                        }),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
