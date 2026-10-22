# โปรเจกต์ตั้งต้น Quiz Flutter — Provider + SQLite

รายวิชา 273387 Mobile Application Development (MAD) ภาคเรียนที่ 1/2569

โปรเจกต์นี้คือผลลัพธ์ของ **ปฏิบัติการบทที่ 13: แอปบัญชีรายรับ-รายจ่ายด้วย Provider และ SQLite** (กระบวนการที่ 1–6)
ใช้เป็นจุดตั้งต้นของ Quiz ให้ศึกษาโครงสร้างแล้วสร้าง model, provider และ UI ของ entity ที่ได้รับมอบหมายให้ทำ CRUD กับ SQLite ได้

## โครงสร้าง

```
lib/
├── main.dart                              ChangeNotifierProvider ครอบ MyApp
├── models/
│   └── my_transaction.dart                Model + toMap() / fromMap()
├── providers/
│   └── transaction_provider.dart          เปิดฐานข้อมูล + CRUD + notifyListeners()
└── screens/
    └── transaction_list_screen.dart       Consumer แสดงรายการ, ปุ่มลบ, ปุ่ม + เพิ่มรายการตัวอย่าง
```

| การทำงาน | เมธอดใน `TransactionProvider` | คำสั่ง sqflite |
|---|---|---|
| Create | `addTransaction()` | `insert` |
| Read | `fetchAndSetTransactions()` | `query` |
| Update | `updateTransaction()` | `update` |
| Delete | `deleteTransaction()` | `delete` |

## วิธีรัน

ต้องรันบน Android emulator หรือเครื่องจริง (sqflite ไม่รองรับ Web และ Windows)

```bash
flutter pub get
flutter run
```

## ตัวช่วยสำหรับ Quiz

โค้ดในหัวข้อนี้ไม่มีตัวอย่างในเอกสารประกอบการสอน จึงให้ไว้ที่นี่ นำไปใช้ได้

### 1. รับค่าวันที่ (ฟิลด์ `DateTime`)

**รับวันที่ได้ทุกวิธีต่อไปนี้ คะแนนเต็มเท่ากัน**

| วิธี | สิ่งที่ทำ |
|---|---|
| ก. กำหนดอัตโนมัติ | ใช้ `DateTime.now()` ตอนบันทึก ไม่ต้องมีช่องกรอก |
| ข. พิมพ์เป็นข้อความ | ใช้ `TextFormField` ให้กรอกรูปแบบ `2026-10-12` แล้วแปลงด้วย `DateTime.parse(...)` (บทที่ 13) |
| ค. เลือกจากปฏิทิน | ใช้ `showDatePicker` ตามตัวอย่างด้านล่าง |

ตัวอย่างวิธี ค. (ภายใน `State` ของหน้าฟอร์มที่เป็น `StatefulWidget`)

```dart
DateTime _selectedDate = DateTime.now();

Future<void> _pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,   // วันที่ที่เลือกไว้ตอนเปิดปฏิทิน
    firstDate: DateTime(2000),    // วันแรกที่เลือกได้ DateTime(ปี, เดือน, วัน)
    lastDate: DateTime(2100),     // วันสุดท้ายที่เลือกได้
  );
  if (picked != null) {           // ผู้ใช้กด Cancel จะได้ null
    setState(() {
      _selectedDate = picked;
    });
  }
}

// ภายในเมธอด build
Row(
  children: [
    Expanded(child: Text('วันที่: ${DateFormat.yMMMd().format(_selectedDate)}')),
    TextButton(onPressed: _pickDate, child: const Text('เลือกวันที่')),
  ],
),
```

### 2. แปลงข้อความเป็นจำนวนเต็ม (ฟิลด์ `int`)

ใช้แบบเดียวกับ `double.parse` / `double.tryParse` ในบทที่ 11

```dart
int.tryParse('25');    // 25
int.tryParse('2.5');   // null  (ไม่ใช่จำนวนเต็ม)
int.tryParse('abc');   // null
int.parse('25');       // 25    (ถ้าแปลงไม่ได้จะเกิด FormatException)

// ใน validator
validator: (value) {
  if (value == null || value.isEmpty) return 'กรุณากรอกจำนวน';
  if (int.tryParse(value) == null) return 'กรุณากรอกจำนวนเต็ม';
  return null;
},
```

## การส่งงาน Quiz

1. สร้าง repository ของตนเองบน GitHub ตั้งค่าเป็น **Private**
   (กดปุ่ม **Use this template → Create a new repository** ที่หน้านี้ หรือ clone แล้ว push ขึ้น repository ใหม่)
2. ทำงานและ push ขึ้น repository ของตนเองภายในเวลาสอบ
3. ไปที่ **Settings → Collaborators → Add people** แล้วเพิ่ม `nattaponk@nu.ac.th`

ข้อปฏิบัติ: เปิดได้เฉพาะเอกสารประกอบการสอน ห้ามใช้ AI
