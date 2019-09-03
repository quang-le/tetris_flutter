import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.blue,
          child: Center(
              child: Column(
            children: <Widget>[
              Spacer(),
              Expanded(
                  child: Container(
                      child: Text(
                'Tetris',
                style: (TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 45)),
              ))),
              RawMaterialButton(
                child: Text('Start'),
                onPressed: () {
                  //print(Grid.grid);
                },
              ),
              SizedBox(height: 8),
              RawMaterialButton(
                child: Text('Credits'),
                onPressed: () {},
              ),
              Spacer(),
            ],
          )),
        ),
      ),
    );
  }
}
