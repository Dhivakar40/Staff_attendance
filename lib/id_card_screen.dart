import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'setup_screen.dart'; // <--- Import this so we can navigate back

class IdCardScreen extends StatefulWidget {
  @override
  _IdCardScreenState createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  String? qrData;

  @override
  void initState() {
    super.initState();
    _loadData();
    _maxBrightness();
  }

  Future<void> _maxBrightness() async {
    try {
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      print("Failed to set brightness");
    }
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      qrData = prefs.getString('staff_qr_data');
    });
  }

  // --- NEW FUNCTION: RESET DATA ---
  Future<void> _resetAndEdit() async {
    // 1. Confirm with user first (Optional, but good UX)
    bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit Details?"),
          content: Text("This will delete your current ID and let you create a new one."),
          actions: [
            TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
            TextButton(child: Text("Edit"), onPressed: () => Navigator.pop(context, true)),
          ],
        )
    );

    if (confirm == true) {
      // 2. Clear saved data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('staff_qr_data');

      // 3. Go back to Setup Screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetupScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Staff ID"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Option A: Edit button in top corner
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _resetAndEdit,
            tooltip: "Edit Details",
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: qrData == null
                  ? CircularProgressIndicator()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text("OFFICIAL EXAM PASS",
                      style: TextStyle(fontSize: 18, color: Colors.grey, letterSpacing: 1.5)
                  ),
                  SizedBox(height: 30),

                  // The QR Code
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12, width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 280.0,
                      errorStateBuilder: (cxt, err) {
                        return Center(child: Text("Data Error. Please Reset."));
                      },
                    ),
                  ),

                  SizedBox(height: 20),
                  Text("Show this to the Admin", style: TextStyle(fontWeight: FontWeight.bold)),

                  SizedBox(height: 40),

                  // Option B: A dedicated button at the bottom
                  TextButton.icon(
                    onPressed: _resetAndEdit,
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text("Wrong Name? Edit Details"),
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}