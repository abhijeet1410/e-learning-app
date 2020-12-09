import 'package:flutter/material.dart';
class PaymentSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Payment Successfull', style: TextStyle(color: Colors.green),),
      ),
    );
  }
}
