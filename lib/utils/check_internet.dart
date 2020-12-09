import 'dart:io';

class NetworkUtils{
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 8), onTimeout: () {
        print('Time out error');
        List<InternetAddress> l = [InternetAddress('')];
        return Future.value(l);
      });
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (i) {
      print(i.toString());
      return Future.value(false);
    }
  }
}
