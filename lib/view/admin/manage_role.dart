import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_role/manage_role_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageRoleScreen extends StatefulWidget {
  const ManageRoleScreen({super.key});

  @override
  State<ManageRoleScreen> createState() => _ManageRoleScreenState();
}

class _ManageRoleScreenState extends State<ManageRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<String> items = ['Admin', 'Faculty', 'Librarian'];
  String? roleValue;
  bool usePhone = true;
  bool validation = false;
  _bottomModal() {
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text("Create Special User",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          const SizedBox(height: 20),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty && validation) {
                                return 'Please enter a valid name';
                              }
                              return null;
                            },
                            controller: nameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Your Name',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              usePhone
                                  ? const Text('Phone Authentication')
                                  : const Text('Google Authentication'),
                              Switch(
                                value: usePhone,
                                onChanged: (value) {
                                  setState(() {
                                    usePhone = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Visibility(
                            visible: usePhone,
                            child: TextFormField(
                              cursorColor: Colors.purple,
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              validator: (value) {
                                if (phoneController.text.isEmpty &&
                                    validation) {
                                  return "Please enter a Phone number";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter phone number",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                prefixIcon: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: const Text("+91",
                                        style: TextStyle(fontSize: 17))),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: usePhone,
                            child: const SizedBox(
                              height: 20,
                            ),
                          ),
                          Visibility(
                            visible: !usePhone,
                            child: TextFormField(
                              validator: (value) {
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
                                if ((value!.isEmpty ||
                                    !emailRegex.hasMatch(value) &&
                                        validation)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              controller: emailController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Email Address',
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !usePhone,
                            child: const SizedBox(
                              height: 20,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            validator: (value) {
                              if (value == null && validation) {
                                return 'Please Select a Role';
                              }
                              return null;
                            },
                            hint: const Text("Role"),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              hintStyle: const TextStyle(color: Colors.black12),
                            ),
                            items: items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: roleValue,
                            onChanged: (String? value) {
                              setState(() {
                                roleValue = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          CustomButton(
                              text: "Submit",
                              icontext: false,
                              onPressed: () {
                                validation = true;
                                if (_formKey.currentState!.validate()) {
                                  if (phoneController.text.isNotEmpty) {
                                    BlocProvider.of<ManageRoleCubit>(context)
                                        .createSpecialUserWithPhone(
                                            '+91${phoneController.text.toString()}',
                                            nameController.text,
                                            roleValue!);
                                  } else if (emailController.text.isNotEmpty) {
                                    BlocProvider.of<ManageRoleCubit>(context)
                                        .createSpecialUserWithEmail(
                                            emailController.text,
                                            nameController.text,
                                            roleValue!);
                                  }
                                  Navigator.pop(context);
                                }
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        ),
        title: const Text(
          'Manage Role',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bottomModal();
        },
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocListener<ManageRoleCubit, ManageRoleState>(
        listener: (context, state) {
          if (state is ManageRoleAddSpecialUserSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User Created Successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is ManageRoleErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref('manageRole').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final itemsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List a = itemsMap.keys.toList();
                  List uid = [];
                  for (int i = 0; i < a.length; i++) {
                    if (itemsMap[a[i]]['uid'] != null) {
                      uid.add(itemsMap[a[i]]['uid']);
                    }
                  }
                  // return Text(itemsMap.keys.toList().toString());
                  return Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              margin: const EdgeInsets.only(left: 30),
                              child: const Text(
                                'Activated',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                                textAlign: TextAlign.start,
                              ))),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: uid.length,
                          itemBuilder: (context, index) {
                            return StreamBuilder(
                                stream: FirebaseDatabase.instance
                                    .ref('users/${uid[index]}')
                                    .onValue,
                                builder: (context, snap) {
                                  if (!snap.hasData || snap.data == null) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    final items = snap.data!.snapshot.value
                                        as Map<dynamic, dynamic>;

                                    final itemsList =
                                        Map.fromEntries(items.entries.toList());
                                    // return Text(itemsList.toString());
                                    return Card(
                                      child: ListTile(
                                        title: Text(itemsList['name']),
                                        subtitle: Text(toCamelCase(itemsList['role'])),
                                        leading: Container(
                                          width: 55,
                                          height: 55,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: itemsList['photo'] != null &&
                                                  itemsList['photo'] != ''
                                              ? CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: itemsList['photo'],
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                )
                                              : Image.asset(
                                                  'assets/no_image.png'),
                                        ),
                                        onTap: () {
                                          // Navigator.pushNamed(context, itemsMap[a]['route']);
                                        },
                                      ),
                                    );
                                  }
                                });
                          }),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              margin: const EdgeInsets.only(left: 30),
                              child: const Text(
                                'Not Activated',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                                textAlign: TextAlign.start,
                              ))),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: a.length,
                          itemBuilder: (context, index) {
                            if (itemsMap[a[index]]['uid'] == null) {
                              return Card(
                                child: ListTile(
                                  title: Text(itemsMap[a[index]]['name']),
                                  subtitle: Text(toCamelCase(itemsMap[a[index]]['role'])),
                                  leading: Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Image.asset(
                                        'assets/no_image.png',
                                      )),
                                  onTap: () {},
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
