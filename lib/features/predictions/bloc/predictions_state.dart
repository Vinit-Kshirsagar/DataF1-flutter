part of 'predictions_bloc.dart';

abstract class PredictionsState {}

class PredictionsInitial extends PredictionsState {}
class PredictionsLoading extends PredictionsState {}
class PredictionsLoaded extends PredictionsState {}
class PredictionsError extends PredictionsState {
  final String message;
  PredictionsError(this.message);
}
