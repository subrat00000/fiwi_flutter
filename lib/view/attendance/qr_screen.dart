
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/cubits/qr/qr_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QrScreen extends StatefulWidget {
  final String qrdata;
  const QrScreen({super.key,required this.qrdata});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: double.infinity,
        color: Colors.white70,
        child: BlocListener<QrCubit, QrState>(
          listener: (context, state) {
            if(state is QrErrorState){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.redAccent[400],
                  behavior: SnackBarBehavior.floating,
                ));
                Navigator.pop(context);
            }
          },
         
            child: Stack(
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.3,),
          Center(child: QrImage(data: widget.qrdata,size:250,)),
        ],
      ),
      Positioned(
        bottom: 20, // adjust the value to position the button as per your requirement
        left: 20,
        right: 20,
        child: CustomButton(text: 'Next',borderRadius: 50,icontext: false, onPressed: (){}),
      ),
    ],
  ),
          
        )
      ),
    );
  }
}
