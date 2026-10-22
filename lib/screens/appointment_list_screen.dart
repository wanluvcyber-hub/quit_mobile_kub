// lib/screens/appointment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import 'appointment_form_screen.dart';

// เทียบกับโค้ดเก่า (transaction_list_screen.dart):
//  - เก่า: ปุ่ม + เรียก addTransaction ข้อมูลตัวอย่างตายตัว ไม่เปิดฟอร์ม (โค้ดเปิดฟอร์มถูกคอมเมนต์)
//  - เก่า: แถวรายการกดแก้ไขไม่ได้ มีแต่ปุ่มลบ
//  - เก่า: ใช้ type (clear/notclear) แสดงสถานะ | ใหม่ใช้ isConfirmed ตามโจทย์
//  - เก่า: ข้อความพิมพ์ผิด ('ระยะเวลท') และ Row ใน trailing ยัดหลาย Text อาจล้นจอ
//  - ใหม่: กดแถว = แก้ไข, ปุ่ม + = เพิ่ม, ถังขยะ = ลบ, ข้อมูลอยู่ใน subtitle
class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('นัดหมาย')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) => provider.appointments.isEmpty
            ? const Center(child: Text('ไม่มีรายการ'))
            : ListView.builder(
                itemCount: provider.appointments.length,
                itemBuilder: (ctx, i) {
                  final a = provider.appointments[i];
                  return ListTile(
                    leading: Icon(
                      a.isConfirmed ? Icons.check_circle : Icons.schedule,
                      color: a.isConfirmed ? Colors.green : Colors.grey,
                    ),
                    title: Text(a.title),
                    subtitle: Text(
                      '${a.place} • ${a.durationMinutes} นาที\n'
                      '${DateFormat.yMMMd().add_Hm().format(a.appointmentTime)}',
                    ),
                    isThreeLine: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppointmentFormScreen(appointment: a),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => context
                          .read<AppointmentProvider>()
                          .deleteAppointment(a.id!),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AppointmentFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
