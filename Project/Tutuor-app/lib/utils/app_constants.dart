import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const adminPassword = '******';

  static const scheduleStartHour = 8;
  static const scheduleEndHour = 21;
  static const scheduleInteractiveEndHour = 20;
  static const scheduleIntervalMinutes = 30;

  static const scheduleDaysTh = <String>[
    'เสาร์',
    'อาทิตย์',
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
  ];

  static const scheduleDaysEn = <String>[
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  static const subjectLevels = <String, List<String>>{
    'คณิต': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    'วิทย์': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    'อังกฤษ': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    'ไทย': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    'สังคม': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    'ฟิสิกส์': <String>[],
    'เคมี': <String>[],
    'ชีวะ': <String>[],
  };

  static const primaryPurple = Color(0xFFFFC8DD);
  static const lightPurple = Color(0xFFFFF1F5);
  static const darkPurple = Colors.black;
  static const lightPink = Color(0xFFFFE4E8);
  static const appBackground = Color(0xFFFFE2DC);
  static const backgroundPurplePink = Color(0xFFFFEDF3);
  static const adminDashboardBackground = appBackground;
  static const teachingBlockBg = Color(0xFFFFE4E1);
  static const teachingBlockBorder = Color(0xFFB71C1C);
  static const busyBlockBg = Color(0xFFDDDDDD);
  static const busyBlockBorder = Color(0xFF777777);
  static const highlightBg = Color(0xFFD6D6D6);
  static const highlightBorder = Color(0xFF777777);
  static const gridBackground = Colors.white;
  static const gridLineMain = Colors.black;
  static const gridLineSub = Color(0x44000000);
  static const scheduleGridBackground = Color(0xFFFFF8F4);
  static const scheduleGridHeaderBackground = Color(0xFFFFEEE4);
  static const scheduleGridLabelBackground = Color(0xFFFFF5ED);
  static const scheduleGridBorder = Colors.black;
  static const scheduleGridMinorLine = Color(0x44000000);
  static const deleteButtonPink = Color(0xFFFFB6C1);
  static const logoutGradient1 = Color(0xFFFF6B6B);
  static const logoutGradient2 = Color(0xFFFF8E53);

  static const adminButtonColor = Color(0xFF1976D2);
  static const registerButtonColor = Color(0xFF4CAF50);
  static const tutorLoginButtonColor = Color(0xFFFF9800);
}
