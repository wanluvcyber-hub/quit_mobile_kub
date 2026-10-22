// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/appointment_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppointmentProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Appointments',
      home: AppointmentListScreen(),
    );
  }
}
