import 'package:flutter/material.dart';

class PhysicalGoldScreen extends StatelessWidget {
  const PhysicalGoldScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emas Fisik',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'Physical Gold Screen - Coming Soon',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
      ),
    );
  }
}
