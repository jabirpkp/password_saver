import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_saver/repository/appSettings.dart';
import 'package:password_saver/view/key_input_screen.dart';
import 'package:password_saver/view/password_listing.dart';

import '../repository/local_storage.dart';

class DarkBiometricLoginScreen extends StatefulWidget {
  const DarkBiometricLoginScreen({super.key});

  @override
  State<DarkBiometricLoginScreen> createState() =>
      _DarkBiometricLoginScreenState();
}

class _DarkBiometricLoginScreenState extends State<DarkBiometricLoginScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;
  bool _isAuthenticating = false;
  String? _errorMessage;

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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        _continueAfterAuthentication();
      } else {
        authenticate();
      }
    });
  }

  Future<void> authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final canAuthenticate =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          setState(
            () => _errorMessage =
                'Biometric authentication is not available on this device.',
          );
        }
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to unlock your password vault',
        biometricOnly: true,
      );
      if (authenticated) await _continueAfterAuthentication();
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Authentication was not completed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _continueAfterAuthentication() async {
    final iv = LocalStorage.getString('security_iv')?.trim();
    final key = LocalStorage.getString('security_key')?.trim();
    final hasSavedCredentials =
        iv != null && iv.isNotEmpty && key != null && key.isNotEmpty;

    if (hasSavedCredentials) {
      AppSettings.securityIv = iv;
      AppSettings.securityKey = key;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            hasSavedCredentials ? BeautifulList() : KeyInputScreen(),
      ),
      (_) => false,
    );
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

              const Text(
                "Welcome back",
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              const Text(
                "Authenticate to unlock your secure vault",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
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
                    child: _isAuthenticating
                        ? const SizedBox(
                            width: 80,
                            height: 80,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Colors.tealAccent,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.fingerprint,
                            size: 80,
                            color: Colors.tealAccent,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
              ],
              TextButton.icon(
                onPressed: _isAuthenticating ? null : authenticate,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Unlock vault'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
