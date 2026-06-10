import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.hammer, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('En construction', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}