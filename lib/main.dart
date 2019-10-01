import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_test_drive/sign.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xffcd2024),
        accentColor: Color(0xff2f2f2f)
      ),
      
      home: HomePage()
    );
  }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference collectionReference = Firestore.instance.collection("users");




  void add(){
    Map<String,String> data = <String , String>{
      "date" : DateTime.now().toString(),
      "name" : fullname,
      "dob" : dob.toString(),
      "Address Line 1": address_1,
      "Address Line 2": address_2,
      "License Number": license_num,
      "Vehicle Model": vehicle_model,
      "State": _selectedState,
      "Image": imgurl,
      "Signature": SignState(fullname).signurl,
    };

collectionReference.add(data);

  }



  String fullname = "";

  String address_1 = "";
  String address_2 = "";
  String license_num = "";
  String vehicle_model = "";

  String imgurl;
  String _selectedState = "Select a State";
  DateTime dob;



  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    StorageReference ref =
    FirebaseStorage.instance.ref().child("$fullname.jpg");
    StorageUploadTask uploadTask = ref.putFile(image);
     imgurl  = (await uploadTask.onComplete).ref.getDownloadURL() as String;
  }


List<String> states = ['New South Wales','Queensland','South Australia','Tasmania','Victoria','Western Australia','Australian Capital Territory','Northern Territory'];

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2001),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          
          
          Padding(
              padding: EdgeInsets.all(20),
            child: Image(image: AssetImage("assests/logo.png")),
            
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: TextFormField(
              autofocus: false,
              onChanged: (text){fullname=text;},
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Full Name',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: TextFormField(
              autofocus: false,
              onChanged: (text){address_1=text;},
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Address Line 1',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: TextFormField(
              autofocus: false,
              onChanged: (text){address_2=text;},
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Address Line 2',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),



          Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: Column(
                children: <Widget>[
                  Text("${selectedDate.toLocal()}"),
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select DOB'),
                  ),
                ],
              )
          ),


          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: TextFormField(
              autofocus: false,
              onChanged: (text){license_num=text;},
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Driving License Number',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: new DropdownButton<String>(
              hint: Text(_selectedState),

              items: states.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String value) {setState(() {
                _selectedState = value;
              });},
            )

          ),


          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: TextFormField(
              autofocus: false,
              onChanged: (text){vehicle_model=text;},
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Vehicle Model',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),

          Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: Column(
                children: <Widget>[
                  Text("Driving License Image"),
                  FlatButton(onPressed: getImage, child: Text("Upload")),

                ],
              )
          ),


          Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: RaisedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Sign(fullname: fullname)));},child: Text("Signature"),)
          ),

          Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: RaisedButton(onPressed: (){add();},child: Text("Submit!"),)
          ),







        ],
      ),
    );
  }
}

