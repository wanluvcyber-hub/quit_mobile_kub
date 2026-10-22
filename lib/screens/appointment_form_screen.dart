// lib/screens/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';

// เทียบกับโค้ดเก่า (add_edit_transaction.screen.dart) ซึ่ง "ถูกคอมเมนต์ปิดทั้งไฟล์"
// และถ้าเปิดคอมเมนต์ก็คอมไพล์ไม่ผ่านเพราะ:
//  1. `_selectedDate = tx?.durationMinutes ?? DateTime.now()`  ชนิดผิด (ใส่นาทีลงช่องวันที่)
//  2. `_selectedMin = tx.durationMinutes ?`  ประโยคไม่จบ (syntax error)
//  3. `place = _titleController.text`  ผิดช่อง ควรเป็น _placeController
//  4. ใช้ตัวแปร durationMinutes / appointmentTime / isConfirmed ที่ไม่เคยประกาศ
//  5. ยังอ้าง TransactionType, _amountController, _noteController, note: ของเก่าอยู่
//  6. ไม่มีช่องกรอกระยะเวลา และไม่มี Switch ยืนยัน
//  7. ชื่อไฟล์ `.screen.dart` (มีจุด) ควรเป็น `_screen.dart`
//  และในหน้ารายการเก่า ปุ่ม + / แถวรายการ ไม่ได้ push มาหน้าฟอร์มนี้เลย (ถูกคอมเมนต์ไว้)
//  จึงไม่มีทางเพิ่ม/แก้ไขจากฟอร์มได้ ตรงกับโจทย์ข้อ UI ที่ขาดไป
// ใหม่: ฟอร์มเดียวใช้ทั้งเพิ่ม (appointment == null) และแก้ไข เหมือนแนวคิดของไฟล์เก่า
class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment; // null = เพิ่ม, ไม่ null = แก้ไข
  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _durationController;
  late DateTime _selectedTime;
  late bool _isConfirmed;

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _titleController = TextEditingController(text: a?.title ?? '');
    _placeController = TextEditingController(text: a?.place ?? '');
    _durationController =
        TextEditingController(text: a?.durationMinutes.toString() ?? '');
    _selectedTime = a?.appointmentTime ?? DateTime.now();
    _isConfirmed = a?.isConfirmed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time == null) return;
    setState(() {
      _selectedTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppointmentProvider>();
    final existing = widget.appointment;
    final appointment = Appointment(
      title: _titleController.text.trim(),
      place: _placeController.text.trim(),
      durationMinutes: int.parse(_durationController.text.trim()),
      appointmentTime: _selectedTime,
      isConfirmed: _isConfirmed,
    );
    if (existing == null) {
      await provider.addAppointment(appointment);
    } else {
      await provider.updateAppointment(existing.id!, appointment);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไขนัดหมาย' : 'เพิ่มนัดหมาย')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'หัวข้อนัด'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'กรุณากรอกหัวข้อ' : null,
            ),
            TextFormField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: 'สถานที่'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'กรุณากรอกสถานที่' : null,
            ),
            TextFormField(
              controller: _durationController,
              decoration:
                  const InputDecoration(labelText: 'ระยะเวลา (นาที)'),
              keyboardType: TextInputType.number,
              // int.tryParse ตามตัวช่วยใน README: '2.5' และ 'abc' ได้ null -> แจ้ง error
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณากรอกระยะเวลา';
                final n = int.tryParse(v.trim());
                if (n == null) return 'กรุณากรอกจำนวนเต็ม';
                if (n <= 0) return 'ต้องมากกว่า 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'วันเวลา: ${DateFormat.yMMMd().add_Hm().format(_selectedTime)}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('เลือกวันเวลา'),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('ยืนยันแล้ว'),
              value: _isConfirmed,
              onChanged: (v) => setState(() => _isConfirmed = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('บันทึก')),
          ],
        ),
      ),
    );
  }
}
