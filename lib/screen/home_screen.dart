import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:visitor_access_app_gatekeeper/screen/QR_Code_Scanner_Screen.dart';
import 'package:visitor_access_app_gatekeeper/screen/capture_screen.dart';
import 'package:visitor_access_app_gatekeeper/screen/record_screen.dart';
import '../class/class.dart';
import '../function/auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    return Scaffold(
        backgroundColor:Colors.grey[300],
        body:Container(
          child: ListView(
            physics: ScrollPhysics(),
            children: [
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15,bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Welcome back',
                         style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.w500,
                             color: Colors.grey[700]
                         ),
                       ),
                       Text(
                         Gatekeeper.name,
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                             fontSize: 30,
                             fontWeight: FontWeight.w700,
                             color: Colors.black
                         ),
                       ),
                     ],
                   ),
                    Padding(
                        padding: EdgeInsets.only(left: 16,right: 16,top: 0),
                        child:GestureDetector(
                          onTap: () {
                            //Navigator.pushAndRemoveUntil((context), MaterialPageRoute(builder: (context) => EditVisitorScreen()), (route) => true);
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: Image.network(Gatekeeper.userImage).image, //here
                          ),
                        )
                    ),
                  ],
                ),
              ),
              SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height :25),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: InkWell(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.qr_code_scanner,
                                              size: 80,
                                              color: Colors.blue[300],
                                            ),
                                          ),
                                          SizedBox(width:20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Check In Visitor',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),
                                              ),
                                              SizedBox(height: 8,),
                                              Text('QR code and Face scanner',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color:Colors.grey[600]
                                                ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> QRCodeScannerScreen( )));
                              },
                            )
                        ),
                        SizedBox(height :25),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: InkWell(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.library_books,
                                              size: 80,
                                              color: Colors.green[300],
                                            ),
                                          ),
                                          SizedBox(width:20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Record',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),
                                              ),
                                              SizedBox(height: 8,),
                                              Text('Check-in and Check-out',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color:Colors.grey[600]
                                                ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> RecordScreen()));
                              },
                            )
                        ),
                        SizedBox(height :25),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: InkWell(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.logout,
                                              size: 80,
                                              color: Colors.red[300],
                                            ),
                                          ),
                                          SizedBox(width:20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Log out',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),
                                              ),
                                              SizedBox(height: 8,),
                                              Text('Log out application',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color:Colors.grey[600]
                                                ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                              onTap: (){
                                logout(context);
                              },
                            )
                        ),
                        SizedBox(height :25),
                      ],
                    ),
                  )
              )

            ],
          ),
        ),

    );
  }
  Future<void> logout(BuildContext context) async {
    AuthClass authclass=AuthClass();
    await authclass.logout();
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(msg: "You have been logged out");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
