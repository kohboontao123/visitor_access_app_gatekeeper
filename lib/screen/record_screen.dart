import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../class/class.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  TextEditingController _searchTextController = TextEditingController();
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(

        title:  Text( "Today's entry record"),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16,right: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection(
                          'invitation')
                          .where("checkInBy", isEqualTo: Gatekeeper.uid)
                          .orderBy('startDate', descending: true)
                          .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot){
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance.collection(
                                'visitor').snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
                              return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index){
                              for (int i = 0; i < streamSnapshot.data!.docs.length; i++) {
                               /* print(1111111111);
                                print( DateTime.parse(
                                    DateFormat('yyyy-MM-dd').format(
                                        snapshot.data!.docs[index]['GatekeeperRespondDate'].toDate()
                                    )
                                ));
                                print(
                                    DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()))
                                );
                                */
                                if(streamSnapshot.data!.docs[i]['uid'] == snapshot.data!.docs[index]['visitorID']){
                                  if (  DateTime.parse(
                                      DateFormat('yyyy-MM-dd').format(
                                          snapshot.data!.docs[index]['gatekeeperRespondDate'].toDate()
                                      )
                                  ).isAtSameMomentAs(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))){
                                    return GestureDetector(
                                      onTap:(){
                                        _showInvitationDetails(snapshot.data!.docs[index]['visitorID'],snapshot.data!.docs[index].id,);
                                      },
                                      child: Column(
                                          children: [
                                            SizedBox(height:10),
                                            ListTile(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .only(
                                                      topLeft: Radius
                                                          .circular(25),
                                                      topRight: Radius
                                                          .circular(25),
                                                      bottomRight: Radius
                                                          .circular(25),
                                                      bottomLeft: Radius
                                                          .circular(25))),
                                              tileColor: snapshot.data!.docs[index]['checkInStatus'] == 'CheckIn' ? Colors.green :
                                              snapshot.data!.docs[index]['checkInStatus'] == 'Reject' ? Colors.red:
                                              Colors.grey,
                                              textColor: Colors.white,
                                              contentPadding: EdgeInsets
                                                  .only(top: 4,
                                                  bottom: 10,
                                                  left: 0,
                                                  right: 6),
                                              title: Text(
                                                streamSnapshot.data!.docs![i]['name'],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .phone,
                                                          color: Colors
                                                              .white,
                                                          size: 15,),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          "Phone Number:",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      streamSnapshot.data!.docs[i]['phoneNumber'],
                                                      style: GoogleFonts
                                                          .montserrat(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 12),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .access_time_sharp,
                                                          color: Colors
                                                              .white,
                                                          size: 15,),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          "Start Date:",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      '${DateFormat
                                                          .yMMMMEEEEd()
                                                          .format(
                                                          snapshot.data!
                                                              .docs[i]['startDate']
                                                              .toDate())}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 12),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .access_time_sharp,
                                                            color: Colors
                                                                .white,
                                                            size: 15),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          "End Date:",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      '${DateFormat
                                                          .yMMMMEEEEd()
                                                          .format(
                                                          snapshot.data!
                                                              .docs[i]['endDate']
                                                              .toDate())}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 12),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .access_time_sharp,
                                                            color: Colors
                                                                .white,
                                                            size: 15),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          snapshot.data!.docs[index]['checkInStatus'] == 'CheckIn' ?  'Check-In Date':
                                                          snapshot.data!.docs[index]['checkInStatus'] == 'Reject' ? 'Reject Date':
                                                          '',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      '${DateFormat
                                                          .yMMMMEEEEd()
                                                          .format(
                                                          snapshot.data!
                                                              .docs[i]['gatekeeperRespondDate']
                                                              .toDate())}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 12),
                                                    ),
                                                  ]
                                              ),
                                              leading: CircleAvatar(
                                                radius: 45.0,
                                                backgroundImage: Image
                                                    .network(
                                                    streamSnapshot.data!.docs![i]['userImage'])
                                                    .image, //here
                                              ),
                                            ),
                                            SizedBox(height: 10,)
                                          ]
                                      ),
                                    );
                                  }
                                }

                              }


                                return Row();
                                }
                              );
                            }
                        );
                      }
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  _showInvitationDetails(String visitorID,String invitationID)async{
    var collection = FirebaseFirestore.instance.collection('visitor') .where("uid", isEqualTo: visitorID);
    var querySnapshot = await collection.get();
    Map<String, dynamic> data;
    FirebaseFirestore.instance
        .collection('invitation').doc(invitationID).get()
        .then((DocumentSnapshot documentSnapshot) =>{
          if(documentSnapshot.exists){
            for(var queryDocumentSnapshot in querySnapshot.docs){
              data = queryDocumentSnapshot.data(),
              if(data['uid'].toString()== documentSnapshot['visitorID'].toString()){
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
                                  backgroundImage: Image.network(data['userImage'].toString()).image, //here
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text:data['name'].toString()) ,
                                  decoration: InputDecoration(
                                    labelText: 'Visitor Name',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text:data['icNumber'].toString()) ,
                                  decoration: InputDecoration(
                                    labelText: 'IC Number',
                                    icon: Icon(Icons.switch_account),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text:data['address'].toString()) ,
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    icon: Icon(Icons.location_on),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text:data['phoneNumber'].toString()),
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    icon: Icon(Icons.phone ),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text: '${DateFormat('EEE, MMM d, ' 'yy').format(documentSnapshot['startDate'].toDate())}'),
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    icon: Icon(Icons.access_time_outlined ),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text: '${DateFormat('EEE, MMM d, ' 'yy').format(documentSnapshot['endDate'].toDate())}'),
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    icon: Icon(Icons.access_time_outlined ),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text: '${ documentSnapshot['status'].toString()}'),
                                  decoration: InputDecoration(
                                    labelText: 'Visitor Respond',
                                    icon: Icon(Icons.list ),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text: '${DateFormat('EEE, MMM d, ' 'yy').format(documentSnapshot['gatekeeperRespondDate'].toDate())}'),
                                  decoration: InputDecoration(
                                    labelText:  documentSnapshot['checkInStatus'].toString()=='CheckIn'? 'Check-In Date': 'Reject Date',
                                    icon: Icon(Icons.access_time_outlined ),
                                  ),
                                ),
                                TextFormField(
                                  minLines: 1,
                                  maxLines: 3,
                                  enabled: false,
                                  controller:TextEditingController(text: '${ documentSnapshot['checkInStatus'].toString()}'),
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    icon: Icon(Icons.list ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [

                        ],
                      );
                    }
                )
              }
            }
          }

    });
  }
}
