
import 'package:flutter/material.dart';
import 'package:pkcoin/screen1.dart';

void main(){
  runApp(PkCoin());
}

class PkCoin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage() ,
    );
  }
}
