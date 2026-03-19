part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // Will be populated in Block 2
  HomeLoaded();
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
