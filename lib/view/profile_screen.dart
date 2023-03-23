import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/google_signin/google_signin_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class ChartData {
  ChartData(this.month, this.totalClass, this.attendedClass);

  final String month;
  final double totalClass;
  final double attendedClass;
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TrackballBehavior _trackballBehavior;
  String chartValue='Day';
  List<String> items = ['Semester','Month','Week','Day'];
  final List<ChartData> data = <ChartData>[
    ChartData('Jan', 15, 10),
    ChartData('Feb', 20, 13),
    ChartData('Mar', 25, 25),
    ChartData('May', 13, 10),
    ChartData('Apr', 21, 21),
    ChartData('Jun', 18, 18),
    ChartData('Jul', 24, 24),
    ChartData('Aug', 23, 23),
    ChartData('Sep', 19, 19),
    ChartData('Oct', 31, 31),
    ChartData('Nov', 39, 39),
    ChartData('Dec', 50, 30),
  ];
  var internet = true;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: height * 0.17,
                color: Colors.purple[400],
              ),
              // Container( child:,
              //           // width: width * 0.28,
              //           ),
              Container(
                // height: height * 0.2,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                    ),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Container(
                  margin: EdgeInsets.only(left: width * 0.05),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: width * 0.28,
                          height: height * 0.04,
                          margin: const EdgeInsets.all(6),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 226, 226, 226),
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          child: TextButton(
                              onPressed: () {},
                              child: const Text("Edit Profile",
                                  style: TextStyle(color: Colors.black))),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Subrat Meher",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Text("Software engineer with 2+ years of experience in developing and integrating software solutions. Possesses strong analytical, problem-solving and time-management skills. Adept at developing software solutions for various platforms with a focus on efficiency, user-friendliness and performance. Experienced in coding, testing, debugging and designing programs according to requirements. Developed multiple successful projects under tight deadlines",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                            SizedBox(height: 8),
                            Text("Titilagarh, Odisha, India",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                )),
                            SizedBox(height: 10),

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: height*0.02,),
              Container(
                margin: EdgeInsets.only(left: width * 0.02,right:width*0.02),
                  // height: height * 0.2,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 226, 226, 226),
                      ),
                      borderRadius:BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      
                      Align(alignment: Alignment.centerRight,child: 
                      Container(
                        width:width*0.3,
                        height: height*0.05,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Semester"),
                            
                            items:
                                items.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: chartValue,
                            onChanged: (value) {
                              setState(() {
                                chartValue = value!;
                              });
                            },
                          ),
                        ),
                      ),),
                      SizedBox(height: height*0.02,),
                      Container(
                        height: height * 0.2,
                        child: SfCartesianChart(
                          enableAxisAnimation: true,
                            primaryXAxis: CategoryAxis(),
                            trackballBehavior: _trackballBehavior,
                            series: <LineSeries<ChartData, String>>[
                              LineSeries<ChartData, String>(
                                dataSource: data,
                                markerSettings: MarkerSettings(isVisible: true),
                                name: 'Total No. of class',
                                xValueMapper: (ChartData sales, _) => sales.month,
                                yValueMapper: (ChartData sales, _) =>
                                    sales.totalClass,
                              ),
                              LineSeries<ChartData, String>(
                                dataSource: data,
                                markerSettings: MarkerSettings(isVisible: true),
                                name: 'Attended Class',
                                xValueMapper: (ChartData sales, _) => sales.month,
                                yValueMapper: (ChartData sales, _) =>
                                    sales.attendedClass,
                              ),
                            ]),
                      ),
                    ],
                  ))
            ],
          ),
          Transform.translate(
              offset: Offset(width * 0.66, height * 0.04),
              child: Container(
                width: width * 0.12,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(45, 255, 255, 255),
                    offset: Offset(0.001, 0.001), //(x,y)
                    blurRadius: 0.05,
                  ),
                ], shape: BoxShape.circle),
                height: height * 0.12,
                child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,color: Colors.white,),
          onSelected: (value){},
          itemBuilder: (BuildContext context) {
            return items.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
              )),
          Transform.translate(
              offset: Offset(width * 0.82, height * 0.04),
              child: Container(
                width: width * 0.12,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(45, 255, 255, 255),
                    offset: Offset(0.001, 0.001), //(x,y)
                    blurRadius: 0.05,
                  ),
                ], shape: BoxShape.circle),
                height: height * 0.12,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    )),
              )),
          Transform.translate(
            offset: Offset(width * 0.03, -height * 0.013),
            child: Container(
              width: width * 0.28,
              height: height * 0.28,
              margin: const EdgeInsets.all(6),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.001, 0.001), //(x,y)
                  blurRadius: 0.05,
                ),
              ], shape: BoxShape.circle),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                      ),
                    ], shape: BoxShape.circle),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: "http://via.placeholder.com/350x150",
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
