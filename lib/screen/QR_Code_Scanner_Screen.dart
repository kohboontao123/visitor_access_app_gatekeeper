
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:visitor_access_app_gatekeeper/class/class.dart';
import 'package:visitor_access_app_gatekeeper/screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'capture_screen.dart';
class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result = null;
  String _msg = "";
  final regExp = RegExp(
      r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
      "'" // <-- ' is added to the expression
          ']'
  );
  var startDateBeforeNow = null;
  var endDateBeforeNow   = null;
  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }
  @override
  Widget build(BuildContext context) {

      if( result == null){
          return buildQrView();
      }else{
        if ( regExp.hasMatch('${result!.code}')!=true){
          print('haha');
          print('${result!.code}');
          controller!.pauseCamera();
          FirebaseFirestore.instance
              .collection('invitation').doc('${result!.code}').get()
              .then((DocumentSnapshot documentSnapshot) async =>{
            if(documentSnapshot.exists){
              InvitationDetails.visitorID = documentSnapshot['visitorID'],
              InvitationDetails.residentID = documentSnapshot['residentID'],
              InvitationDetails.inviteDate = documentSnapshot['inviteDate'],
              InvitationDetails.startDate = documentSnapshot['startDate'],
              InvitationDetails.endDate = documentSnapshot['endDate'],
              InvitationDetails.checkInBy = documentSnapshot['checkInBy'],
              InvitationDetails.gatekeeperRespondDate= documentSnapshot['gatekeeperRespondDate'],
              InvitationDetails.checkInStatus =
              documentSnapshot['checkInStatus'],
              InvitationDetails.status = documentSnapshot['status'],
              InvitationDetails.invitationID = documentSnapshot.reference.id,
              startDateBeforeNow = DateTime.parse(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      InvitationDetails.startDate.toDate())).isBefore(
                  DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.now()))),
              endDateBeforeNow = DateTime.parse(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      InvitationDetails.endDate.toDate())).isBefore(
                  DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.now()))),
              print(startDateBeforeNow),
              print(endDateBeforeNow),
              if ((startDateBeforeNow == true && endDateBeforeNow == true)){
                updateInvitationInformation(),
                await controller!.resumeCamera(),
                setState(() {
                  _msg =
                  "The time for using this QR code to check in a visitor have already expired.";
                  result = null;
                }),
                Fluttertoast.showToast(
                    msg: "We apologize, but it seems that the time for using this QR code to check in a visitor have already expired. Please check with the event organizer or reception staff for the valid time period to check in. Thank you."),
              } else
                if ((startDateBeforeNow == false && endDateBeforeNow == false)){
                  await controller!.resumeCamera(),
                  setState(() {
                    _msg =
                    "The time for using this QR code to check in a visitor has not yet arrived.";
                    result = null;
                  }),
                  Fluttertoast.showToast(
                      msg: "We apologize, but it seems that the time for using this QR code to check in a visitor has not yet arrived. Please check with the event organizer or reception staff for the valid time period to check in. Thank you."),
                } else if (startDateBeforeNow ==true && endDateBeforeNow == false){
                    if (InvitationDetails.status == 'Accepted' &&
                        InvitationDetails.checkInStatus == '-' &&
                        InvitationDetails.checkInBy == '-'){
                      await controller!.pauseCamera(),
                      getVisitorInformation(),
                      getResidentInformation(),
                      Future.delayed(Duration.zero, () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => CaptureScreen()));
                      }),
                    } else
                      {
                        await controller!.resumeCamera(),
                        setState(() {
                          _msg =
                          "This QR code has already been used to check in a visitor.";
                          result = null;
                        }),
                        Fluttertoast.showToast(
                            msg: "We're sorry, but it appears that this QR code has already been used to check in a visitor. Please contact a staff member if you believe this is an error or if you need further assistance. Thank you."),
                      }
                  } else {
                      setState(() {
                      _msg = "Invalid QR Code";
                      result = null;
                      }),
                    }
            }
          });
           controller!.resumeCamera();
          return buildQrView();
        }else{
          setState(() {
            _msg = "Invalid QR Code";
            result = null;
          });
          return buildQrView();
        }
      }


  }
  Widget buildQrView(){
    return  WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.cyan,
                leading: GestureDetector(
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushAndRemoveUntil((context), MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,  // add custom icons also
                  ),
                ),
                title: Text('QR Code Scanner'),
                actions: [
                  Padding(padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() async {
                          await controller?.resumeCamera();
                        });
                      },
                      child:Icon(
                        Icons.refresh,
                        size: 26.0,
                      ),
                    ),
                  )
                ],
              ),
              body:GestureDetector(
                onTap: () {
                  setState(() async {
                    await controller?.resumeCamera();
                  }); },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    QRView(
                      key: _gLobalkey,
                      onQRViewCreated: onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderRadius:10,
                        borderColor:Colors.black,
                        borderLength: 20,
                        borderWidth: 10,
                        cutOutSize: MediaQuery.of(context).size.width*0.8,
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          SizedBox(
                              height:MediaQuery.of(context).size.height*0.7
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width*0.5 ,
                            height: MediaQuery.of(context).size.height*0.1 ,
                            decoration: BoxDecoration(
                                color: _msg==""? Colors.transparent :Colors.black,
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                _msg,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )

                        ],
                      ),
                    )
                  ],
                ),
              )

          ),
        ),

    );
  }

  void onQRViewCreated(QRViewController controller){
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
      });

    }
    );
  }

  updateInvitationInformation(){
    var collection = FirebaseFirestore.instance.collection('invitation');
    collection
        .doc(InvitationDetails.invitationID) // <-- Doc ID where data should be updated.
        .update({'checkInStatus':'Expired',
      'status':'Rejected'
    }); // <-- Nested value;
    }

  getVisitorInformation(){
    FirebaseFirestore.instance
        .collection('visitor').doc(InvitationDetails.visitorID).get()
        .then((DocumentSnapshot documentSnapshot) => {
      VisitorDetails.uid=documentSnapshot['uid'],
      VisitorDetails.userImage=documentSnapshot['userImage'],
      VisitorDetails.name=documentSnapshot['name'],
      VisitorDetails.icNumber=documentSnapshot['icNumber'],
      VisitorDetails.address=documentSnapshot['address'],
      VisitorDetails.phoneNumber=documentSnapshot['phoneNumber'],
      VisitorDetails.gender=documentSnapshot['gender'],
      VisitorDetails.email=documentSnapshot['email'],
      VisitorDetails.status=documentSnapshot['status'],
    }
    );
  }
  getResidentInformation(){
    FirebaseFirestore.instance
        .collection('resident').doc(InvitationDetails.residentID).get()
        .then((DocumentSnapshot documentSnapshot) => {
      ResidentDetails.uid=documentSnapshot['uid'],
      ResidentDetails.userImage=documentSnapshot['userImage'],
      ResidentDetails.name=documentSnapshot['name'],
      ResidentDetails.icNumber=documentSnapshot['icNumber'],
      ResidentDetails.address=documentSnapshot['address'],
      ResidentDetails.phoneNumber=documentSnapshot['phoneNumber'],
      ResidentDetails.gender=documentSnapshot['gender'],
      ResidentDetails.email=documentSnapshot['email'],
      ResidentDetails.status=documentSnapshot['status'],
    }
    );
  }
}
