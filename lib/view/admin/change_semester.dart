import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/change_semester/change_semester_cubit.dart';
import 'package:fiwi/cubits/change_semester/change_semester_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChangeSemesterScreen extends StatefulWidget {
  const ChangeSemesterScreen({super.key});

  @override
  State<ChangeSemesterScreen> createState() => _ChangeSemesterScreenState();
}

class _ChangeSemesterScreenState extends State<ChangeSemesterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  String? oldSemester;
  String? newSemester;
  bool validation = false;
  List users = [];
  bool unsubscribeSemester = false;
  bool changeSemester = false;
  bool subscribeSemester = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
        ),
        title: const Text(
          'Change Semester',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: BlocConsumer<ChangeSemesterCubit, ChangeSemesterState>(
            listener: (context, state) {
              if (state is SuccessFetchUserState) {
                users = state.data;
              } else if (state is NoUserFoundErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "No Student Exist for ${state.oldSemester.toString()}"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              } else if (state is UnSubscribeAllTopicSuccessState) {
                unsubscribeSemester = true;
              } else if (state is ChangeSemesterSuccessState) {
                changeSemester = true;
              } else if (state is SubscribeAllTopicSuccessState) {
                subscribeSemester = true;
              }
            },
            builder: (context, state) {
              return Form(
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('From',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 20)),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null && validation) {
                            return 'Please Select your Semester';
                          }
                          return null;
                        },
                        hint: const Text("Semester"),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintStyle: const TextStyle(color: Colors.black12),
                        ),
                        items:
                            items.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: oldSemester,
                        onChanged: (String? value) {
                          setState(() {
                            oldSemester = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('To',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 20)),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null && validation) {
                            return 'Please Select your Semester';
                          }
                          return null;
                        },
                        hint: const Text("Semester"),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintStyle: const TextStyle(color: Colors.black12),
                        ),
                        items:
                            items.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: newSemester,
                        onChanged: (String? value) {
                          setState(() {
                            newSemester = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      state is ChangeSemesterLoadingState
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              text: 'Submit',
                              onPressed: () {
                                validation = true; // set validation to true
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<ChangeSemesterCubit>(context)
                                      .changeSemester(
                                          oldSemester!, newSemester!);
                                }
                              },
                              borderRadius: 50,
                              icontext: false,
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Unsubscribe Old Semester',
                              style: TextStyle(fontSize: 18)),
                          unsubscribeSemester
                              ? const Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.green)
                              : Container(),
                          state is UnsubscribeFailedState
                              ? Text(state.error,
                                  style: const TextStyle(color: Colors.red))
                              : Container(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            'Changing Semester',
                            style: TextStyle(fontSize: 18),
                          ),
                          changeSemester
                              ? const Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.green)
                              : Container(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Subscribe New Semester',
                              style: TextStyle(fontSize: 18)),
                          subscribeSemester
                              ? const Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.green)
                              : Container(),
                          state is SubscribeFailedState
                              ? Text(state.error,
                                  style: const TextStyle(color: Colors.red))
                              : Container(),
                        ],
                      ),
                      state is ChangeSemesterErrorState
                          ? Text(state.error.toString())
                          : Container(),
                      StreamBuilder(
                          stream: FirebaseDatabase.instance.ref('logs').onValue,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                snapshot.data!.snapshot.value == null) {
                              return Container();
                            } else {
                              final itemsMap = snapshot.data!.snapshot.value
                                  as Map<dynamic, dynamic>;
                              final data = itemsMap.values.toList();
                              return ListView.builder(
                                  itemCount: data.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(
                                          'Updated On: ${DateFormat.jm().format(DateTime.parse(data[index]['updatedAt'].toString()))}'),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  'Old : ${data[index]['oldSemester']}')),
                                          Expanded(
                                              child: Text(
                                                  'New : ${data[index]['newSemester']}')),
                                        ],
                                      ),
                                      trailing: data[index]['success'] == true
                                          ? const Icon(Icons
                                              .check_circle_outline_rounded)
                                          : const Icon(
                                              Icons.close_rounded,
                                              color: Colors.red,
                                            ),
                                    );
                                  });
                            }
                          })
                    ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
