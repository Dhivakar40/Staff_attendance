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
    String id = _idController.text.trim().toUpperCase(); // e.g. "e_01" -> "E_01"

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter your Staff ID")));
      return;
    }

    // Create Simple Payload (ID Only)
    // No Name, No Validation. Admin App will handle the lookup.
    Map<String, dynamic> data = {
      "id": id,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staff_qr_data', jsonEncode(data));

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
              Text("STAFF\nEXAMPASS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo), textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("\"Efficiency is doing things right.\"", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey), textAlign: TextAlign.center),
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