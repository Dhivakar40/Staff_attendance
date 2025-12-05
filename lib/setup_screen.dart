import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img; // Ensure you have image package in pubspec.yaml
import 'id_card_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();

  // Controller for the Signature Pad
  final SignatureController _sigController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<void> _saveAndGenerate() async {
    if (_nameController.text.isEmpty || _sigController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter name and sign!")));
      return;
    }

    try {
      // 1. Export Signature to Raw PNG Bytes
      final Uint8List? originalBytes = await _sigController.toPngBytes();

      if (originalBytes != null) {
        // 2. RESIZE LOGIC
        // Decode the image
        img.Image? originalImage = img.decodeImage(originalBytes);

        if (originalImage != null) {
          // Resize to a tiny thumbnail (Width: 80px)
          img.Image resizedImage = img.copyResize(originalImage, width: 80);

          // Encode back to PNG with compression
          List<int> compressedBytes = img.encodePng(resizedImage, level: 9);

          // 3. Convert to Base64
          String base64Signature = base64Encode(compressedBytes);

          // 4. Create Payload
          Map<String, dynamic> data = {
            "n": _nameController.text.trim(),
            "s": base64Signature,
          };

          String qrPayload = jsonEncode(data);

          // 5. Save and Navigate
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('staff_qr_data', qrPayload);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IdCardScreen())
          );
        }
      }
    } catch (e) {
      print("Error generating ID: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error creating ID. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the structure
    return Scaffold(
      appBar: AppBar(title: Text("Staff One-Time Setup")),
      // SafeArea keeps it away from the notch/status bar
      body: SafeArea(
        // SingleChildScrollView fixes the "Overflow" error
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  "Enter Your Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Name Input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                SizedBox(height: 30),
                Text("Digital Signature:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // The Drawing Pad
                Container(
                  height: 180, // Fixed height specifically for the box
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Signature(
                      controller: _sigController,
                      backgroundColor: Colors.white,
                      height: 180, // Match container height
                      width: double.infinity, // Fill width
                    ),
                  ),
                ),

                // Clear Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                      onPressed: () => _sigController.clear(),
                      icon: Icon(Icons.refresh, size: 16),
                      label: Text("Clear Signature")
                  ),
                ),

                SizedBox(height: 40), // Spacing instead of Spacer()

                // Generate Button
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveAndGenerate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("GENERATE ID CARD", style: TextStyle(fontSize: 18)),
                  ),
                ),

                // Extra padding at bottom so scrolling feels good
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}