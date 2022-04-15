import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_header.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test('should be a subclass NumberTrivia entity', () {
    //assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when then JSON number is an integer',
        () async {
      //arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //assert
      expect(result, tNumberTriviaModel);
    });

    test(
        'should return a valid model when then JSON number is regarded a double',
        () async {
      //arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //assert
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test('should return to JSON map containing the proper data', () async {
      //act
      final result = tNumberTriviaModel.toJson();
      //assert
      final expectMap = {
        "text": "Test Text",
        "number": 1,
      };
      expect(result, expectMap);
    });
  });
}
