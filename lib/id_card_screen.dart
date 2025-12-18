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
  String userName = "Staff Member";
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('staff_qr_data');
    if (storedData != null) {
      try {
        Map<String, dynamic> decoded = jsonDecode(storedData);
        setState(() {
          qrData = storedData;
          userName = "Staff Member";
        });
      } catch (e) {
        setState(() {
          qrData = storedData;
        });
      }
    }
  }

  Future<void> _resetAndEdit() async {
    bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit Details?"),
          content: Text("This will delete your current ID pass."),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Edit", style: TextStyle(color: Color(0xFF1E88E5))),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ));
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('staff_qr_data');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SetupScreen()));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final Color brandColor = Color(0xFF1E88E5);
    final Color backgroundColor = Color(0xFFF5F7FA);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("My ID Pass", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: brandColor,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Reset ID",
            onPressed: _resetAndEdit,
          )
        ],
      ),
      body: qrData == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.business,
                                  color: Colors.grey[400], size: 40),
                              SizedBox(height: 5),
                              Text(
                                "STAFF ACCESS PASS",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: brandColor, width: 4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: qrData!,
                            version: QrVersions.auto,
                            size: 260.0,
                            backgroundColor: Colors.white,
                          ),
                        ),

                        SizedBox(height: 30),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            "ACTIVE STATUS",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Align QR code with the scanner",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}