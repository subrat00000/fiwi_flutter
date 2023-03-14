import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable{ }

class InitialState extends HomeState {
  @override
  List<Object> get props => [];
}
class LoadingState extends HomeState {
  @override
  List<Object> get props => [];
}
class LoadedState extends HomeState {
  LoadedState(this.movies);
  
  final List<HomeState> movies;
  
  @override
  List<Object> get props => [movies];
}
class ErrorState extends HomeState {
  @override
  List<Object> get props => [];
}