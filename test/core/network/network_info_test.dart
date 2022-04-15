import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tdd_architecture/features/core/network/network_info.dart';

class MockDataConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    test('should forward call to InternetConnectionChecker.hasConnection',
        () async {
      //arrange
      final tHasConnectionFuture = Future.value(true);
      when(() => mockDataConnectionChecker.hasConnection)
          .thenAnswer((_) => tHasConnectionFuture);
      //act
      final result = networkInfo.isConnected;
      //assert
      verify(() => mockDataConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}
