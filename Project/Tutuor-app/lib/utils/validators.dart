String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอก$fieldName';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอกเบอร์โทรศัพท์';
  }
  final trimmed = value.trim();
  if (!trimmed.startsWith('0')) {
    return 'เบอร์โทรศัพท์ต้องขึ้นต้นด้วย 0';
  }
  if (trimmed.length != 10) {
    return 'เบอร์โทรศัพท์ต้องเป็น 10 หลัก';
  }
  final isNumeric = trimmed.codeUnits.every((unit) => unit >= 48 && unit <= 57);
  if (!isNumeric) {
    return 'เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น';
  }
  return null;
}

String? validateLineId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอกไอดีไลน์';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอกอีเมล';
  }
  final trimmed = value.trim();
  if (!trimmed.contains('@')) {
    return 'รูปแบบอีเมลไม่ถูกต้อง';
  }
  final parts = trimmed.split('@');
  if (parts.length != 2 || !parts[1].contains('.')) {
    return 'รูปแบบอีเมลไม่ถูกต้อง';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอกรหัสผ่าน';
  }
  if (value.length < 6) {
    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  }
  return null;
}

bool validateAdminPassword(String password) {
  return password == '******';
}
