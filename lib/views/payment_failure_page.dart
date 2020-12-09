import 'package:flutter/material.dart';
class PaymentFailurePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Payment Failure', style: TextStyle(color: Colors.red),),
      ),
    );
  }
}
