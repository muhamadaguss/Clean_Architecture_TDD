import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_architecture/features/core/errors/exceptions.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_header.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  late MockHttpClient mockHttpClient;

  setUp(
    () {
      registerFallbackValue(FakeUri());
      mockHttpClient = MockHttpClient();
      dataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    },
  );

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET Request on URL with number
    being the endpoint and with application/json header''', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      verify(
        () => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    });

    test('should return NumberTrivia when then response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = dataSourceImpl.getConcreteNumberTrivia;
      //assert
      expect(
          () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET Request on URL with number
    being the endpoint and with application/json header''', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      dataSourceImpl.getRandomNumberTrivia();
      //assert
      verify(
        () => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/random/trivia'),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    });

    test('should return NumberTrivia when then response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSourceImpl.getRandomNumberTrivia();
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = dataSourceImpl.getRandomNumberTrivia;
      //assert
      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
