import 'package:flutter/material.dart';

class WordCloud extends StatelessWidget {
  final Map<String, int> data;



  WordCloud({required this.data});



  @override
  Widget build(BuildContext context) {
    List<Widget> words = [];
    data.forEach((word, weight) {
      words.add(
        Padding(
          padding: EdgeInsets.all(1.0),  // Reduced padding for more space
          child: Text(
            word,
            style: TextStyle(
              fontSize: weight * 6.0,  // Reduced scaling factor to mitigate overflow
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              overflow: TextOverflow.clip,  // Using clip to prevent any visual overflow
            ),
          ),
        ),
      );
    });



    return Wrap(
      alignment: WrapAlignment.center,
      children: words,
    );
  }
}

