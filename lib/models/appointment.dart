// lib/models/appointment.dart
// เทียบกับโค้ดเก่า (my_appointment.dart):
//  - เก่า: เก็บ isConfirmed เป็น bool ตรงๆ ใน toMap() -> sqflite ไม่รองรับ bool
//          จึง insert แล้ว error "Invalid argument true with type bool"
//    ใหม่: แปลง bool <-> int (true=1, false=0) ทั้งตอนเขียนและตอนอ่าน
//  - เก่า: durationMinutes เป็น double  | โจทย์สั่งให้เป็น int -> ใหม่ใช้ int
//  - เก่า: มีฟิลด์ type (enum clear/notclear) เพิ่มเอง ซึ่งโจทย์ไม่ได้ขอ
//          และซ้ำกับ isConfirmed -> ใหม่ลบออก
//  - เก่า: ชื่อคอลัมน์ camelCase | ใหม่ใช้ snake_case ตามที่โจทย์แนะนำ
class Appointment {
  final int? id;
  final String title;
  final String place;
  final int durationMinutes;
  final DateTime appointmentTime;
  final bool isConfirmed;

  Appointment({
    this.id,
    required this.title,
    required this.place,
    required this.durationMinutes,
    required this.appointmentTime,
    required this.isConfirmed,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'place': place,
      'duration_minutes': durationMinutes,
      'appointment_time': appointmentTime.toIso8601String(),
      'is_confirmed': isConfirmed ? 1 : 0, // SQLite ไม่มี bool (เก่าส่ง bool ตรงๆ จึงพัง)
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int,
      title: map['title'] as String,
      place: map['place'] as String,
      durationMinutes: map['duration_minutes'] as int,
      appointmentTime: DateTime.parse(map['appointment_time'] as String),
      isConfirmed: (map['is_confirmed'] as int) == 1, // เก่า: `as bool` -> cast error เพราะ DB คืน int
    );
  }
}
