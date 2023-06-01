import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewBatchScreen extends StatefulWidget {
  final String session;
  final List<String> uids;
  const ViewBatchScreen({
    super.key,
    required this.session,
    required this.uids,
  });

  @override
  State<ViewBatchScreen> createState() => _ViewBatchScreenState();
}

class _ViewBatchScreenState extends State<ViewBatchScreen> {
  List<Student> student = [];
  List<String> uidsvalue=[];

  selectedStudent(List<String> uids) async {
    if(uids.isEmpty){
      setState(() {
        uids = widget.uids;
      });
    }
    List<Student> a =
        await BlocProvider.of<CreateBatchCubit>(context).getStudents();

    List<Student> ur = a.where((e) => uids.contains(e.uid)).toList();
    setState(() {
      student = ur;
      uidsvalue = uids;
    });
    log(uidsvalue.toString());
    log(widget.uids.toString());
    
  }

  @override
  void initState() {
    super.initState();
    selectedStudent(widget.uids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/createbatch',
                  arguments: {'session': widget.session, 'uids': uidsvalue})
              .then((result) =>
                  selectedStudent(List<String>.from(result as List<String>))),
          child: const Icon(Icons.edit_rounded),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
          ),
          title: Text(
            'Session ${widget.session}',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: student.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: student.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${student[index].name}(${student[index].semester})',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      leading: Container(
                        width: 55,
                        height: 55,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: student[index].photo != null &&
                                student[index].photo != ''
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: student[index].photo!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Image.asset('assets/no_image.png'),
                      ),
                      subtitle: student[index].email != null
                          ? Text(student[index].email!)
                          : Text(student[index].phone!),
                      // onTap: () {
                      //   // Navigator.pushNamed(context, itemsMap[a]['route']);
                      // },
                    );
                  })
              : Container(),
        ));
  }
}
