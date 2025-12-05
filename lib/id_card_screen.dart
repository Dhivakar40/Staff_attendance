import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_screen.dart';

class IdCardScreen extends StatefulWidget {
  @override
  _IdCardScreenState createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  String? qrData;
  String displayId = "";
  bool isDataCorrupt = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('staff_qr_data');

    if (storedData != null) {
      // --- SAFETY CHECK: DETECT OLD BAD DATA ---
      // A valid ID payload {"id":"STF01"} is tiny (< 100 chars).
      // The old signature data was huge (> 20000 chars).
      if (storedData.length > 500) {
        print("Old/Corrupt data detected. Clearing it.");
        await prefs.remove('staff_qr_data');
        _goToSetup(); // Send user back to start
        return;
      }

      try {
        Map<String, dynamic> data = jsonDecode(storedData);
        setState(() {
          qrData = storedData;
          displayId = data['id'] ?? "UNKNOWN";
        });
      } catch (e) {
        _goToSetup();
      }
    } else {
      _goToSetup();
    }
  }

  void _goToSetup() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetupScreen())
    );
  }

  Future<void> _resetAndEdit() async {
    bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Reset ID?"),
          content: Text("Do you want to enter a different Staff ID?"),
          actions: [
            TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
            TextButton(child: Text("Reset"), onPressed: () => Navigator.pop(context, true)),
          ],
        )
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('staff_qr_data');
      _goToSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If data isn't loaded yet, show loader
    if (qrData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Gatepass", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _resetAndEdit,
            tooltip: "Reset ID",
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text("OFFICIAL EXAM ENTRY", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),

                  SizedBox(height: 40),

                  // QR CODE WRAPPED IN SAFETY CONTAINER
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12, width: 3),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 10))]
                    ),
                    child: QrImageView(
                      data: qrData!, // Now guaranteed to be short
                      version: QrVersions.auto,
                      size: 260.0,
                      errorStateBuilder: (ctx, err) {
                        return Center(child: Text("QR Generation Failed.\nPlease Reset ID."));
                      },
                    ),
                  ),

                  SizedBox(height: 30),

                  Text(
                    displayId,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 2),
                  ),
                  Text("STAFF ID", style: TextStyle(color: Colors.grey, fontSize: 12)),

                  SizedBox(height: 50),
                  Text("Show this QR to the Admin\nto get your Hall Allocation.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}