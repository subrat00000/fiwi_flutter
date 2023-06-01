import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/create_batch/create_batch_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBatchCubit extends Cubit<CreateBatchState> {
  CreateBatchCubit() : super(CreateBatchInitialState());

  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference bref = FirebaseDatabase.instance.ref('batch');

  Future getStudents() async {
    DatabaseEvent users =
        await ref.orderByChild('role').equalTo('student').once();
    final itemsMap = users.snapshot.value as Map;
    final itemsList = itemsMap.values.toList();
    return itemsList
        .map((e) => Student(
            email: e['email'],
            name: e['name'],
            phone: e['phone'],
            photo: e['photo'],
            selected: false,
            uid: e['uid'],
            session: e['session'],
            semester: e['semester']))
        .toList();
  }

  Future createBatch(
      String sessionValue, bool update, List<String> value) async {
    try {
      DatabaseReference sessionRef = bref.child(sessionValue);
      DataSnapshot batch = await sessionRef.get();
      if (!batch.exists) {
        await sessionRef.set({'session':sessionValue});
        TransactionResult result = await sessionRef.runTransaction((post) {
          if (post == null) {
            return Transaction.abort();
          }
          Map<String, dynamic> data = Map<String, dynamic>.from(post as Map);
          Map<String, dynamic> uids = {};
          for (int i = 0; i < value.length; i++) {
            uids[value[i]]= '';
          }
          data['session']=sessionValue;
          data['uid'] = uids;
          log(data.toString());
          return Transaction.success(data);
        });
        log(result.committed.toString());
        if (result.committed) {
          emit(CreateBatchSuccessState());
        } else {
          await sessionRef.remove();
          emit(CreateBatchErrorState('Something Went Worng! Please try again'));
        }
      } else {
        if (update) {
          //update
          TransactionResult result = await sessionRef.runTransaction((post) {
            if (post == null) {
              return Transaction.abort();
            }
            Map<String, dynamic> data = Map<String, dynamic>.from(post as Map);
            Map<String, dynamic> uids = {};
            for (int i = 0; i < value.length; i++) {
              uids[value[i]]= '';
            }
            data['uid'] = uids;
            log(data.toString());
            return Transaction.success(data);
          });
          if (result.committed) {
            emit(UpdateBatchSuccessState());
          } else {
            emit(CreateBatchErrorState(
                'Something Went Worng! Please try again'));
          }
        } else {
          emit(CreateBatchErrorState('A batch with same value already exist'));
        }
      }
    } catch (e) {
      emit(CreateBatchErrorState(e.toString()));
    }
  }

  deleteBatch(sessionValue) {
    try {
      bref.child(sessionValue).remove();
      emit(DeleteBatchSuccessState());
    } catch (e) {
      emit(CreateBatchErrorState(e.toString()));
    }
  }
}
