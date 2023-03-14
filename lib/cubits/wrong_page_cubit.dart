import 'package:flutter_bloc/flutter_bloc.dart';
enum WrongPageState {wrongPage}
class WrongPage extends Cubit<WrongPageState> {
  WrongPage():super(WrongPageState.wrongPage);
  
}