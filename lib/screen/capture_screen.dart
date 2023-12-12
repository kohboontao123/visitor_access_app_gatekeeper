import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:visitor_access_app_gatekeeper/class/class.dart';
import 'package:visitor_access_app_gatekeeper/screen/QR_Code_Scanner_Screen.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:intl/intl.dart';
import '../function/face_detector_painter.dart';
import 'package:google_fonts/google_fonts.dart';
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  int direction =0;
  bool _isLoading= false;
  bool _isBtnDisable = false;
  CustomPaint? _customPaint;
  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  void startCamera(int direction) async{
    cameras = await availableCameras();
    cameraController =  CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize().then((value){
      if(!mounted){
        return;
      }
      setState(() {});
    }).catchError((e){
      print(e);
    });
  }
  void initState(){
    startCamera(0);
    super.initState();
  }
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  @override
  Widget build(BuildContext context) {
    if(cameraController.value.isInitialized){
      return WillPopScope(
        onWillPop: () async => false,
          child:Scaffold(
            backgroundColor:Colors.grey[300],
            appBar:AppBar(
              leading: GestureDetector(
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> QRCodeScannerScreen( )));
                  });
                },
                child: Icon(
                  Icons.arrow_back,  // add custom icons also
                ),
              ),
              backgroundColor: Colors.cyan,
              elevation: 0,
              title:  Text(
                  'Capture Visitor Photos'),
              actions: [
                Padding(padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        direction = direction == 0 ? 0 : 0;
                        startCamera(direction);
                        _isLoading=false;
                        _isBtnDisable=false;
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
            body:Stack(
              children:[
                Center(
                    child:Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(cameraController!),
                        //would be the Overlay Widget
                      ],
                    )
                ),
                SizedBox(height:60),
                /* GestureDetector(
                onTap: (){
                  setState(() {
                    direction = direction == 0 ? 0 : 0;
                    startCamera(direction);
                    _isLoading=false;
                  });
                },
               child:button(Icons.refresh,Alignment.bottomLeft)
           ),*/
                Positioned(
                    bottom: MediaQuery.of(context).size.height* 0.05,
                    width: MediaQuery.of(context).size.width,

                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 20),
                            minimumSize: Size.fromHeight(72),
                            shape: StadiumBorder(),
                            primary:Colors.cyan
                        ),
                        child: _isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white,),
                            SizedBox(width:24),
                            Text('Please wait...')
                          ],
                        )
                            :Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,size:30),
                            SizedBox(width:10),
                            Text('Capture')
                          ],
                        ) ,
                        onPressed:  _isBtnDisable? null:() async {
                          if(_isLoading)return;
                          setState(() {
                            _isLoading=true;
                            cameraController.takePicture().then((XFile? file) async {
                              if(mounted){
                                if(file !=null){
                                  processImage("${file.path}");
                                }
                              }
                            });
                          });

                        },
                      ),
                    )
                ),
              ],
            ),
          ),
      );
    }else{
      return Container(
        color: Colors.white,
        child: Text(
          'Camera Not Found !'
        ),
      );
    }
  }

  Future<void> processImage(String imagePath) async {
    final faces = await faceDetector.processImage(InputImage.fromFilePath(imagePath));
    int qtyFace =0;
    if (InputImage.fromFilePath(imagePath).inputImageData?.size != null &&
        InputImage.fromFilePath(imagePath).inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          InputImage.fromFilePath(imagePath).inputImageData!.size,
          InputImage.fromFilePath(imagePath).inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      //String text = 'Faces found: ${faces.length}\n\n';
      qtyFace = int.parse('${faces.length}');
      if ( qtyFace ==1) {
        matchFaces(imagePath);
      }else if ( qtyFace>=2){
      Fluttertoast.showToast(
      msg: "To many person detected by camera");
      setState(()=>_isLoading=false);
      }else{
        Fluttertoast.showToast(
            msg: "No person detected by camera");
        setState(()=>_isLoading=false);
      }

    }

    //Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
    //Fluttertoast.showToast(msg: name);


  }

  matchFaces(String imagePath) async {

    Uint8List bytes1 = (await NetworkAssetBundle(Uri.parse( VisitorDetails.userImage))
        .load( VisitorDetails.userImage))
        .buffer
        .asUint8List();
    _isBtnDisable=true;
    var request = new Regula.MatchFacesRequest();
    image1.bitmap = base64Encode((File(imagePath).readAsBytesSync()));
    image1.imageType=Regula.ImageType.PRINTED;
    image2.bitmap = base64Encode( bytes1);
    image2.imageType=Regula.ImageType.LIVE;
    request.images = [image1,image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(jsonEncode(response!.results), 0.75).then((str) async {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));

        if(split!.matchedFaces.length > 0  ){
          _showInvitationDetails();
          _isBtnDisable=false;
          setState(()=>_isLoading=false);

        }else{
          Fluttertoast.showToast(msg: "Mismatch between invited visitor and attendees");
          setState(()=>_isLoading=false);
          _isBtnDisable=false;
        }
      });
    });
  }

  Future<void> _showInvitationDetails() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            scrollable: true,
            title: Text(
              'Invitation Details',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 20,
                decoration: TextDecoration.none,
              ),),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: Image.network(VisitorDetails.userImage).image, //here
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text:VisitorDetails.name.toString()) ,
                      decoration: InputDecoration(
                        labelText: 'Visitor Name',
                        icon: Icon(Icons.account_box),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text:VisitorDetails.address.toString()) ,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text:VisitorDetails.phoneNumber.toString()),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        icon: Icon(Icons.phone ),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text: '${ ResidentDetails.name
                          .toString()}'),
                      decoration: InputDecoration(
                        labelText: 'Inviter Name',
                        icon: Icon(Icons.account_box ),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text: '${ ResidentDetails.phoneNumber
                          .toString()}'),
                      decoration: InputDecoration(
                        labelText: 'Inviter number',
                        icon: Icon(Icons.phone ),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text: '${ ResidentDetails.address
                          .toString()}'),
                      decoration: InputDecoration(
                        labelText: 'Inviter address',
                        icon: Icon(Icons.location_on ),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text: '${DateFormat('EEE, MMM d, ' 'yy').format(InvitationDetails.startDate.toDate())}'),
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        icon: Icon(Icons.access_time_outlined ),
                      ),
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      controller:TextEditingController(text: '${DateFormat('EEE, MMM d, ' 'yy').format(InvitationDetails.endDate.toDate())}'),
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        icon: Icon(Icons.access_time_outlined ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(Colors.greenAccent),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18.0),
                            ))),
                    onPressed: () {
                      updateInvitationStatus( 'CheckIn');
                    },
                    icon: Icon(
                      // <-- Icon
                      Icons.task_alt_outlined,
                      size: 24.0,
                    ),
                    label: Text('Accept'), // <-- Text
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(Colors.pink),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18.0),
                            ))),
                    onPressed: () {
                      updateInvitationStatus( 'Reject By Gatekeeper');
                    },
                    icon: Icon(
                      // <-- Icon
                      Icons.highlight_remove,
                      size: 24.0,
                    ),
                    label: Text('Reject'), // <-- Text
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(Colors.red),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18.0),
                            ))),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(
                          'dialog');
                    },
                    icon: Icon(
                      // <-- Icon
                      Icons.cancel,
                      size: 24.0,
                    ),
                    label: Text('Close'), // <-- Text
                  ),
                ],
              ),
            ],
          );
        }
    );
  }

  void updateInvitationStatus( String checkInStatus){
    var collection = FirebaseFirestore.instance.collection('invitation');
    collection
        .doc(InvitationDetails.invitationID) // <-- Doc ID where data should be updated.
        .update({'checkInStatus':checkInStatus,
                  'checkInBy': Gatekeeper.uid}) // <-- Nested value
        .then((_) => {
          if (checkInStatus=='CheckIn'){
            Fluttertoast.showToast(msg: "You have successfully Check-In visitor"),
          }else{
            Fluttertoast.showToast(msg: "You have successfully reject visitor"),
          },
          collection.
          doc(InvitationDetails.invitationID)
          .update({
              'gatekeeperRespondDate': DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())),
          }) .then((value) => print("Successfully")),
      Navigator.pushAndRemoveUntil((context), MaterialPageRoute(builder: (context) => QRCodeScannerScreen()), (route) => false),
    }

    )
        .catchError((error) =>  Fluttertoast.showToast(msg: 'Update failed: $error'));
    Navigator.of(context, rootNavigator: true).pop(
        'dialog');
  }
}
