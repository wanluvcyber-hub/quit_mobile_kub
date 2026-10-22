// lib/providers/appointment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  // เทียบกับโค้ดเก่า: เก่าใช้ไฟล์ 'expenses.db' ซึ่งเป็นไฟล์ของ lab/starter ที่มีตาราง
  // transactions อยู่แล้ว onCreate จึง "ไม่ทำงาน" (มันทำงานเฉพาะตอนสร้างไฟล์ครั้งแรก)
  // ผลคือไม่มีตาราง appointments -> error "no such table: appointments"
  // การแก้ version: 2 โดยไม่เขียน onUpgrade ก็ไม่ช่วย
  // ใหม่: ใช้ชื่อไฟล์ใหม่ 'appointments.db' ให้ onCreate สร้างตารางถูกต้องตั้งแต่แรก
  // (ถ้าแก้โครงตารางระหว่างพัฒนา: ถอนการติดตั้งแอปจากเครื่อง หรือเปลี่ยนชื่อ DB)
  static const String _dbName = 'appointments.db';
  static const String _tableName = 'appointments';
  Database? _database;
  List<Appointment> _appointments = [];

  AppointmentProvider() {
    fetchAndSetAppointments();
  }

  List<Appointment> get appointments => [..._appointments];

  Future<void> _initDatabase() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title TEXT, place TEXT, duration_minutes INTEGER, '
            'appointment_time TEXT, is_confirmed INTEGER)',
          );
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  // เก่า: addTransaction รับ 6 พารามิเตอร์แยกกัน ทำให้หน้าฟอร์มต้องเรียกยาว
  // และปุ่ม + แค่ insert ข้อมูลตัวอย่างตายตัว ('หมอนัด','home',12.0,...)
  // ใหม่: รับทั้งอ็อบเจ็กต์ Appointment ที่หน้าฟอร์มประกอบไว้แล้ว
  Future<void> addAppointment(Appointment appointment) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.insert(_tableName, appointment.toMap());
    await fetchAndSetAppointments();
  }

  Future<void> fetchAndSetAppointments() async {
    await _initDatabase();
    if (_database == null) return;
    final dataList =
        await _database!.query(_tableName, orderBy: 'appointment_time ASC');
    _appointments = dataList.map(Appointment.fromMap).toList();
    notifyListeners();
  }

  Future<void> updateAppointment(int id, Appointment appointment) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.update(
      _tableName,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await fetchAndSetAppointments();
  }
}
