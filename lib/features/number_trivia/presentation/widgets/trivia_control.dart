import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            dispatchConcrete();
          },
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
                onPressed: dispatchConcrete,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.grey,
                ),
                onPressed: dispatchRandom,
                child: const Text('Get random trivia'),
              ),
            ),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputStr));
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
