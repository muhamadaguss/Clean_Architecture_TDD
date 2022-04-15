import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_architecture/features/core/errors/failures.dart';
import 'package:tdd_architecture/features/core/usecases/usecase.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository numberTriviaRepository;
  GetConcreteNumberTrivia(this.numberTriviaRepository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return await numberTriviaRepository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  final int number;
  const Params({required this.number});

  @override
  List<Object?> get props => [number];
}
