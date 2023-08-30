import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final int price = 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stream builder'),
      ),
      body: StreamBuilder<int>(
        initialData: price,
        stream: addStreamValue(),
        builder: (context, snapshot) {
          final priceNumber = snapshot.data.toString();
          return Center(
            child: Text(
              priceNumber,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.blue),
            ),
          );
        },
      ),
    );
  }

  Stream<int> addStreamValue() {
    return Stream<int>.periodic(
      Duration(seconds: 1),
      (count) => price + count,
    );
  }
}
