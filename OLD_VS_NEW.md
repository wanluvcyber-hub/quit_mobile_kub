# โค้ดเก่า (ตอนสอบ) vs โค้ดใหม่ — ทำไมของเก่าไม่ทำงาน

โค้ดเก่า: `~/Desktop/mobile maysa/mobile final/mad-quiz-flutter-starter` (commit `quit__final`)

| # | ปัญหาในโค้ดเก่า | ผล | แก้ในโค้ดใหม่ |
|---|---|---|---|
| 1 | ใช้ DB ไฟล์เดิม `expenses.db` + `version: 2` แต่ไม่มี `onUpgrade` | `onCreate` ไม่รันเพราะไฟล์มีอยู่แล้ว -> `no such table: appointments` | ใช้ `appointments.db` |
| 2 | `toMap()` ส่ง `isConfirmed` เป็น bool | sqflite throw ตอน insert | แปลงเป็น 1/0 |
| 3 | `fromMap()` ใช้ `as bool` | cast error ตอนอ่าน (DB คืน int) | `== 1` |
| 4 | `durationMinutes` เป็น `double` | ผิดโจทย์ (ต้อง int) | `int` + `int.tryParse` |
| 5 | เพิ่มฟิลด์ `type` (enum) ที่โจทย์ไม่ขอ | ซ้ำกับ `isConfirmed` ทำให้โค้ดซับซ้อน | ลบทิ้ง |
| 6 | หน้าฟอร์มถูกคอมเมนต์ปิดทั้งไฟล์ และมีข้อผิดพลาดคอมไพล์หลายจุด | ไม่มีฟอร์มเพิ่ม/แก้ไข | เขียนใหม่ `appointment_form_screen.dart` |
| 7 | ปุ่ม + insert ข้อมูลตัวอย่างตายตัว, ไม่มีทางแก้ไขรายการ | UI ไม่ครบตามโจทย์ | ปุ่ม + เปิดฟอร์ม, กดแถวเพื่อแก้ไข |
| 8 | ยังใช้ชื่อ `Transaction*` ทั้งที่เป็น Appointment | อ่านยาก | เปลี่ยนชื่อเป็น `Appointment*` |

หมายเหตุ: ข้อ 1 ผมอนุมานจากโค้ด (ไม่ได้รันโค้ดเก่า) ส่วนข้อ 2-3 เป็นพฤติกรรมที่ทราบของ sqflite
