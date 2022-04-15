import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_architecture/features/core/errors/exceptions.dart';
import 'package:tdd_architecture/features/core/errors/failures.dart';
import 'package:tdd_architecture/features/core/network/network_info.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_architecture/features/number_trivia/data/repositories_impl/number_trivia_repository_impl.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfoImpl {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(
    () {
      mockRemoteDataSource = MockRemoteDataSource();
      mockLocalDataSource = MockLocalDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo,
      );
    },
  );

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      //arrange
      //Stub for mockRemoteDataSource.getConcreteNumberTrivia
      when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
          .thenAnswer((_) async => tNumberTriviaModel);
      //Stub for mockLocalDataSource.cacheNumberTrivia
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) async => Future.value());
      //Stub for mockNetworkInfo.isConnected
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {});

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, const Right(tNumberTrivia));
      });

      test(
          'should return remote data when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when then cached data is present',
          () async {
        //arrange
        // when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
        //     .thenAnswer((_) async => tNumberTriviaModel);
        // when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
        //     .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return cache failure when then is no cached data present',
          () async {
        //arrange
        // when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
        //     .thenAnswer((_) async => tNumberTriviaModel);
        // when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
        //     .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 123);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      //arrange
      //Stub for mockRemoteDataSource.getConcreteNumberTrivia
      when(() => mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTriviaModel);
      //Stub for mockLocalDataSource.cacheNumberTrivia
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) async => Future.value());
      //Stub for mockNetworkInfo.isConnected
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {});

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, const Right(tNumberTrivia));
      });

      test(
          'should return remote data when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when then cached data is present',
          () async {
        //arrange
        // when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
        //     .thenAnswer((_) async => tNumberTriviaModel);
        // when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
        //     .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return cache failure when then is no cached data present',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
