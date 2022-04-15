import 'dart:convert';

import 'package:tdd_architecture/features/core/errors/exceptions.dart';

import '../models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl extends NumberTriviaRemoteDataSource {
  final http.Client client;
  NumberTriviaRemoteDataSourceImpl({required this.client});
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTriviaFromUrl('http://numbersapi.com/$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getTriviaFromUrl('http://numbersapi.com/random/trivia');

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final result = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (result.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(result.body));
    } else {
      throw ServerException();
    }
  }
}
