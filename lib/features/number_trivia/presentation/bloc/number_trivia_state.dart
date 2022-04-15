import 'package:equatable/equatable.dart';

import '../../domain/entities/number_trivia.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;
  const Loaded({required this.trivia});
}

class Error extends NumberTriviaState {
  final String message;
  const Error({required this.message});
}