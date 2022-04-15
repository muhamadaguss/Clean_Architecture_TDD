import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_architecture/features/core/errors/failures.dart';
import 'package:tdd_architecture/features/core/usecases/usecase.dart';
import 'package:tdd_architecture/features/core/util/input_converter.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_architecture/features/number_trivia/presentation/bloc/bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(
    () {
      mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
      mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
      mockInputConverter = MockInputConverter();
      bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );
    },
  );

  test('initialState should be Empty', () {
    //assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(const Right(tNumberParsed));
    test(
        'should call the InputConverter to validate and convert the string to an unsigned string',
        () async* {
      //arrange
      setUpMockInputConverterSuccess();
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()));
      //assert
      verify(
        () => mockInputConverter.stringToUnsignedInteger(tNumberString),
      );
    });

    test('should emit [Error] when the inpus is invalid.', () async* {
      //arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));

      final expected = [
        Empty(),
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      //assert later
      expectLater(bloc, emitsInOrder(expected));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete usecase', () async* {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetRandomNumberTrivia(any()));

      //assert
      verify(() =>
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      //assert later
      final expeted = [Empty(), Loading(), const Loaded(trivia: tNumberTrivia)];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emits [Loading, Error] when getting data fails', () async* {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emits [Loading, Error] with a proper message for the error when getting data fails',
        () async* {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from the random usecase', () async* {
      //arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));

      //assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });
    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      //arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      //assert later
      final expeted = [Empty(), Loading(), const Loaded(trivia: tNumberTrivia)];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
    test('should emits [Loading, Error] when getting data fails', () async* {
      //arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emits [Loading, Error] with a proper message for the error when getting data fails',
        () async* {
      //arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
