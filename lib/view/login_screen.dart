import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_saver/repository/appSettings.dart';
import 'package:password_saver/view/key_input_screen.dart';
import 'package:password_saver/view/password_listing.dart';

import '../repository/local_storage.dart';

class DarkBiometricLoginScreen extends StatefulWidget {
  @override
  _DarkBiometricLoginScreenState createState() =>
      _DarkBiometricLoginScreenState();
}

class _DarkBiometricLoginScreenState extends State<DarkBiometricLoginScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulsating animation for fingerprint icon
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Trigger biometric authentication on screen load
  //  Future.delayed(Duration(milliseconds: 300), authenticate);
  }

  Future<void> authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to login',
        biometricOnly: true,
      );

      if (authenticated) {
        var iv = LocalStorage.getString('security_iv');
        var key = LocalStorage.getString('security_key');
        if(iv!=null&&iv.toString().isNotEmpty&&key!=null&&key.toString().isNotEmpty) {
          AppSettings.securityIv = iv;
          AppSettings.securityKey = key;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BeautifulList()),
                (Route<dynamic> route) => false, // Remove all previous screens
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KeyInputScreen()),
            // Remove all previous screens
          );
        }

      }
    } catch (e) {


      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark theme background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsating fingerprint icon

              Text(
                "Welcome Back _Sta",
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Use your fingerprint ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: authenticate,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                    ),
                    padding: EdgeInsets.all(24),
                    child: Icon(
                      Icons.fingerprint,
                      size: 80,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KeyInputScreen()));
                },
                child: Align(alignment: Alignment.topRight,
                child: Text("ChangeKey",style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),)),
              )


            ],
          ),
        ),
      ),
    );
  }
}