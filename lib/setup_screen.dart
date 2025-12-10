import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'id_card_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _idController = TextEditingController();

  Future<void> _generatePass() async {
    String id = _idController.text.trim().toUpperCase();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter your Staff ID")));
      return;
    }

    // --- FIX: Store ONLY the ID string ---
    // Instead of JSON, we just save "E_01"
    // This is the simplest, most robust format.
    String qrPayload = id;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staff_qr_data', qrPayload);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IdCardScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Icon(Icons.shield_outlined, size: 80, color: Colors.indigo),
              SizedBox(height: 20),
              Text("OFFICIAL\nEXAM PASS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo), textAlign: TextAlign.center),
              SizedBox(height: 60),

              TextField(
                controller: _idController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: InputDecoration(
                  labelText: "ENTER STAFF ID",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _generatePass,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  child: Text("GENERATE QR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}