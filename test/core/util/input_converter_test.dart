import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_architecture/features/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInteger', () {
    test(
        'should return an integer when the string represents an unsigned integer',
        () async {
      //arrange
      const str = '123';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(const Right(123)));
    });

    test('should return Failure when the String is not an integer', () async {
      //arrange
      const str = 'abc';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, Left(InvalidInputFailure()));
    });
  });
}
