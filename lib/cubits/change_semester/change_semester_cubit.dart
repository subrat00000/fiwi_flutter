import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:fiwi/cubits/change_semester/change_semester_state.dart';
import 'package:fiwi/repositories/notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ChangeSemesterCubit extends Cubit<ChangeSemesterState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference logref = FirebaseDatabase.instance.ref("logs");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  DateTime now = DateTime.now();
  ChangeSemesterCubit() : super(ChangeSemesterInitialState());

  // callSem(oldSemester) async {
  //   try {
  //     return await
  //   } catch (e) {
  //     emit(ChangeSemesterErrorState(e.toString()));
  //   }
  // }

  changeSemester(String oldSemester, String newSemester) async {
    emit(ChangeSemesterLoadingState());
    try {
      log('hello');
      final snapshot =
          await ref.orderByChild('semester').equalTo(oldSemester).get();

      if (snapshot.exists) {
        final data = (snapshot.value as Map).values.toList();
        emit(SuccessFetchUserState(data));
        var tokens = data
            .map(
              (e) => e['mtoken'].toString(),
            )
            .toList();
        log(data.toString());
        var unsubscribe = await unsubscribeToTopic(
            tokens, oldSemester.toLowerCase().replaceAll(' ', ''));
        if (unsubscribe['success']) {
          emit(UnSubscribeAllTopicSuccessState());
          log('success');
          var a = await Future.wait(data.map((key) async {
            try {
              logref
                  .child(now.millisecondsSinceEpoch.toString())
                  .child('uid')
                  .child(key['uid'])
                  .set("");
              ref.child(key['uid']).update({'semester': newSemester});
              return true;
            } catch (e) {
              logref.child(now.millisecondsSinceEpoch.toString()).set({
                'success': false,
                'error': e,
              });
              return e;
            }
          }).toList());
          emit(ChangeSemesterSuccessState(a));
          logref.child(now.millisecondsSinceEpoch.toString()).update({
            'updatedAt': now.toString(),
            'oldSemester': oldSemester,
            'newSemester': newSemester,
          });
          var subscribe = await subscribeToTopic(
              tokens, newSemester.toLowerCase().replaceAll(' ', ''));
          if (subscribe['success']) {
            emit(SubscribeAllTopicSuccessState());
            logref.child(now.millisecondsSinceEpoch.toString()).update({
              'success': true,
            });
          } else {
            emit(SubscribeFailedState(subscribe['error']));
            logref.child(now.millisecondsSinceEpoch.toString()).update({
              'success': false,
              'error': subscribe['error'],
            });
          }
        } else {
          emit(UnsubscribeFailedState(unsubscribe['error']));
          logref.child(now.millisecondsSinceEpoch.toString()).update({
            'success': false,
            'error': unsubscribe['error'],
          });
        }
      } else {
        emit(NoUserFoundErrorState(oldSemester));
      }
    } catch (e) {
      emit(ChangeSemesterErrorState(e.toString()));
      logref.child(now.millisecondsSinceEpoch.toString()).update({
        'success': false,
        'error': e.toString(),
      });
    }
  }
}
