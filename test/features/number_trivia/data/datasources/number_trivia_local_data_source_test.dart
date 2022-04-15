import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_architecture/features/core/errors/exceptions.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_header.dart';

class MockSharedPreference extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedPreference mockSharedPreference;
  setUp(() {
    mockSharedPreference = MockSharedPreference();
    dataSourceImpl = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreference);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPrefences when there is on in the cache',
        () async {
      // arrange
      when(() => mockSharedPreference.getString(any()))
          .thenReturn(fixture('trivia_cached.json'));
      // act
      final result = await dataSourceImpl.getLastNumberTrivia();
      // assert
      verify(() => mockSharedPreference.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException there is not a cached value', () async {
      // arrange
      when(() => mockSharedPreference.getString(any())).thenReturn(null);
      // act
      final call = dataSourceImpl.getLastNumberTrivia;
      // assert
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 1);
    test('should call SharedPreferences to cache the data', () async {
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      //arrange
      when(() => mockSharedPreference.setString(
              CACHED_NUMBER_TRIVIA, expectedJsonString))
          .thenAnswer((_) async => true);
      //act
      dataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      verify(() => mockSharedPreference.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
