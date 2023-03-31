import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/repositories/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreenHelper extends StatefulWidget {
  const HomeScreenHelper({super.key});

  @override
  State<HomeScreenHelper> createState() => HomeScreenHelperState();
}

class ChartData {
  ChartData(this.month, this.totalClass, this.attendedClass);

  final String month;
  final double totalClass;
  final double attendedClass;
}

class HomeScreenHelperState extends State<HomeScreenHelper> {
  late TrackballBehavior _trackballBehavior;
  int? todayAsDay;
  String chartValue = 'Day';
  List<String> items = ['Semester', 'Month', 'Week', 'Day'];
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

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    todayAsDay = DateTime.now().weekday;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    
        return Column(children: [
          Card(
            color: Colors.grey[200],
            elevation: 6,
            child: Column(children: <Widget>[
              const InkWell(
                
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Text(
                          'Today\'s Time Table',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                      ),
                    )),
              ),
              (todayAsDay == 7)
                  ? Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height:
                            150, //MediaQuery.of(context).size.height * 0.3,
                        child: const Center(
                          child: Text('Sunday is fun day',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    )
                  : Card(
                      color: Colors.white,
                      elevation: 6,
                      child: Column(children: <Widget>[
                        Container(
                          height:
                              150, //MediaQuery.of(context).size.height * 0.3,
                          child: StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .ref('timetable/sem1/${todayAsDay}')
                                .onValue,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data == null ||
                                  snapshot.data!.snapshot.value == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                final itemsMap = snapshot.data!.snapshot.value
                                    as Map<dynamic, dynamic>;
                                final itemsList = itemsMap.entries.toList();
                                return ListView.builder(
                                  padding: const EdgeInsets.all(10.0),
                                  itemBuilder: (context, index) {
                                    return showPeriod(
                                        context, itemsList[index]);
                                  },
                                  itemCount: itemsList.length,
                                  scrollDirection: Axis.horizontal,
                                );
                              }
                            },
                          ),
                        ),
                      ]),
                    ),
            ]),
          ),
          SizedBox(height: height*0.02,),
          Container(
              margin:
                  EdgeInsets.only(left: width * 0.02, right: width * 0.02),
              // height: height * 0.2,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 226, 226, 226),
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  SizedBox(height: height*0.02,),
                  const Align(alignment: Alignment.topCenter,child: Text('Attendance Report'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: width * 0.3,
                      height: height * 0.05,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text("Semester"),
                          items: items
                              .map<DropdownMenuItem<String>>((String value) {
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
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
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
        ]);
      
  }

  Widget showPeriod(BuildContext context, document) {
    // DateTime showStartTime =
    //     DateTime.parse(document.value['startTime'].toDate().toString());
    // DateTime showEndTime =
    //     DateTime.parse(document.value['endTime'].toDate().toString());

    String showStartTime = document.value['startTime'].toString();
    String showEndTime = document.value['endTime'].toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 5),
      width: 220,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.fromLTRB(
          10.0, 5.0, 0.0, 5.0), //MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showStartTime)
              // ),
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showEndTime)
              // ),
              myText(Colors.black, showStartTime),
              myText(Colors.black, showEndTime),
            ],
          ),
          myText(
            Colors.black,
            document.value['subject'],
          ),
          myText(
            Colors.black,
            document.value['faculty'],
          ),
        ],
      ),
    );
  }

  Widget myText(tColor, textValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textValue,
        style: TextStyle(color: tColor),
      ),
    );
  }
}