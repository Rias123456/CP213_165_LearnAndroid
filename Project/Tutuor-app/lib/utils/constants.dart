class AppConstants {
  static const adminPassword = '******';

  static const scheduleStartHour = 8;
  static const scheduleEndHour = 21;
  static const scheduleIntervalMinutes = 30;

  static const scheduleDays = <String>[
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  static const displayDayNames = <String, String>{
    'saturday': 'เสาร์',
    'sunday': 'อาทิตย์',
    'monday': 'จันทร์',
    'tuesday': 'อังคาร',
    'wednesday': 'พุธ',
    'thursday': 'พฤหัส',
    'friday': 'ศุกร์',
  };

  static const subjects = <Map<String, dynamic>>[
    {
      'id': 'math',
      'name': 'คณิต',
      'levels': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    },
    {
      'id': 'science',
      'name': 'วิทย์',
      'levels': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    },
    {
      'id': 'english',
      'name': 'อังกฤษ',
      'levels': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    },
    {
      'id': 'thai',
      'name': 'ไทย',
      'levels': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    },
    {
      'id': 'social',
      'name': 'สังคม',
      'levels': ['ประถม', 'มัธยมต้น', 'มัธยมปลาย'],
    },
    {
      'id': 'physics',
      'name': 'ฟิสิกส์',
      'levels': <String>[],
    },
    {
      'id': 'chemistry',
      'name': 'เคมี',
      'levels': <String>[],
    },
    {
      'id': 'biology',
      'name': 'ชีวะ',
      'levels': <String>[],
    },
  ];

  static const successRegisterTutor = 'ลงทะเบียนติวเตอร์สำเร็จ';
  static const errorGeneric = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
}
