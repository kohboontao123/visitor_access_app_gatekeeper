import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final resetPasswordButton = MaterialButton(
      onPressed: (){
        resetPassword();
      },
      child: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 25.0),
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Reset Password',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            )
        ),
      ),
    );
    final emailField =  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child:TextFormField(
          cursorColor: Colors.black,
          style: TextStyle(color: Colors.black.withOpacity(0.9)),
          autofocus:false,
          controller:  _emailTextController,
          keyboardType: TextInputType.emailAddress,
          validator: (value){
            if (value!.isEmpty){
              return ("Please Enter Your Email");
            }
            if (!RegExp("^[a-zA-Z0-9+.-]+@[a-zA-Z0-9+.-]+.[a-z]").hasMatch(value)){
              return ("Please Enter a valid email");
            }
            return null;
          },
          onSaved:(value){
            _emailTextController.text=value!;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText:"Email",
              filled: true,
              floatingLabelBehavior:FloatingLabelBehavior.never,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 0,style: BorderStyle.none)
              )

          ),
        ));
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child:Text(
              'Enter Your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 10,),
          emailField,
          SizedBox(height: 10,),
          resetPasswordButton



        ],
      ),
    );
  }
  Future resetPassword()async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailTextController.text.trim());
      Fluttertoast.showToast(msg: "Password Reset Email Sent");
    } on FirebaseAuthException catch (e) {
      print(e);
      Fluttertoast.showToast(msg: e.message.toString());
    }
  }
}
