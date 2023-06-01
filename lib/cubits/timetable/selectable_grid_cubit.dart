import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class SelectableGridCubit extends Cubit<List<bool>> {
  SelectableGridCubit(int itemCount) : super(List.filled(itemCount, false));
  Box box = Hive.box('user');
  List selectable = [];
  void toggleItem(int index, item) {
    state[index] = !state[index];
    if (state[index]) {
      selectable.add(item[index]);
    } else if(!state[index]){
      selectable.remove(item[index]);
    }
    emit(List.from(state));
    box.put('courseList',selectable);
  }

  void clearSelection() {
    emit(List.filled(state.length, false));
  }
  pushCourseList(){
    
  }
}
