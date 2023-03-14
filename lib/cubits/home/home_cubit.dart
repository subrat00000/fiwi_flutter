import 'package:fiwi/cubits/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  // void getTrendingMovies() async {
  //   try {
  //     emit(LoadingState());
  //     final movies = await repository.getMovies();
  //     emit(LoadedState(movies));
  //   } catch (e) {
  //     emit(ErrorState());
  //   }
  // }
}
