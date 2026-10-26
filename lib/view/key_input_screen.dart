import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_saver/repository/appSettings.dart';
import 'package:password_saver/view/password_listing.dart';

import '../repository/local_storage.dart';

class KeyInputScreen extends StatelessWidget {
  KeyInputScreen({super.key});

  final TextEditingController securityKey = TextEditingController();
  final TextEditingController securityIv = TextEditingController();

  Future<void> setValue(String key, String value) async {
    await LocalStorage.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: .10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.tealAccent.withValues(alpha: .35),
                        ),
                      ),
                      child: const Icon(
                        Icons.key_rounded,
                        color: Colors.tealAccent,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Secure your vault",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Enter the AES key and initialization vector used to protect your passwords.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      obscureText: true,
                      controller: securityIv,
                      maxLength: 16,
                      inputFormatters: [LengthLimitingTextInputFormatter(16)],
                      decoration: InputDecoration(
                        labelText: "Initialization vector (IV)",
                        hintText: "16 characters",
                        prefixIcon: const Icon(Icons.shield_outlined),
                        filled: true,
                        fillColor: const Color(0xFF171717),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: securityKey,
                      obscureText: true,
                      maxLength: 32,
                      inputFormatters: [LengthLimitingTextInputFormatter(32)],
                      decoration: InputDecoration(
                        labelText: "Security key",
                        hintText: "32 characters",
                        prefixIcon: const Icon(Icons.vpn_key_rounded),
                        filled: true,
                        fillColor: const Color(0xFF171717),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Keep these values safe. Existing passwords cannot be decrypted without the same key and IV.",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String iv = securityIv.text.trim();
                          String key = securityKey.text.trim();

                          if (iv.length == 16 && key.length == 32) {
                            await Future.wait([
                              setValue('security_iv', iv),
                              setValue('security_key', key),
                            ]);
                            AppSettings.securityIv = iv;
                            AppSettings.securityKey = key;
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => BeautifulList(),
                              ),
                              (_) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Use a 32-character key and a 16-character IV.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.lock_rounded),
                        label: const Text("Save and continue"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
