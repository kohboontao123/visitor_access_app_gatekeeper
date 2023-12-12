import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visitor_access_app_gatekeeper/class/class.dart';
import 'package:visitor_access_app_gatekeeper/screen/home_screen.dart';
import 'package:visitor_access_app_gatekeeper/screen/login_screen.dart';

import 'function/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  /*WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: const FirebaseOptions(
    apiKey: "AAAA8eTjZ2c:APA91bEW1bmGlZIP59wnFfyVAUCfAb1e-6677HEo7WvVCTMUGrYOgeN18bSyWpiKiSvhsvSnGRNJ7OwNREGUbXK12dPACGrsJ-pihDzV3WHeSmK1r-ANafx0aCiKpLGjYLaazUPZfr3P", // Your apiKey
    appId: "1:1038927226727:android:227c7e95bd5301f59771c2", // Your appId
    messagingSenderId: "1038927226727", // Your messagingSenderId
    projectId: "fypproject-42f8d", // Your projectId
  ));*/
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState(){
    super.initState();
    checkLogin();
  }
  Widget currentPage =LoginScreen();
  AuthClass authclass=AuthClass();
  void checkLogin() async{

    String? token=await authclass.getToken();
    print(token);
    if (token!=null){
      Fluttertoast.showToast(msg:'logging...');
      FirebaseFirestore.instance
          .collection('gatekeeper').doc(token).get()
          .then((DocumentSnapshot documentSnapshot) =>{
        Gatekeeper.uid=documentSnapshot['uid'],
        Gatekeeper.email=documentSnapshot['email'],
        Gatekeeper.name=documentSnapshot['name'],
        Gatekeeper.userImage=documentSnapshot['userImage'],
        Gatekeeper.icNumber=documentSnapshot['icNumber'],
        Gatekeeper.address=documentSnapshot['address'],
        Gatekeeper.phoneNumber=documentSnapshot['phoneNumber'],
        Gatekeeper.gender=documentSnapshot['gender'],
        Gatekeeper.status=documentSnapshot['status'],
        if(documentSnapshot['status']=='active'){
          setState((){
            currentPage=HomeScreen();
          }),
        }else{
          Fluttertoast.showToast(msg: 'Your account has been deactivated, please contact admin'),
          setState((){
            currentPage=LoginScreen();
          }),
        }


      }).catchError((error) =>
      {
        Fluttertoast.showToast(msg: error.toString()),
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: 'Visitor Application',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home://LoginScreen(),
        currentPage,
        //IDTypeScreen(),
        //ScanFaceScreen(),
        //RegisterScreen(),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

}

