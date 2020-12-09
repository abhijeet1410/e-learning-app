import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  storeCourseDocumentSnapshot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }
}