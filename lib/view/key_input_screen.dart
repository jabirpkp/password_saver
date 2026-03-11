import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../repository/local_storage.dart';

class KeyInputScreen extends StatelessWidget {
   KeyInputScreen({super.key});

  TextEditingController securityKey = TextEditingController();
  TextEditingController securityIv = TextEditingController();

   Future<void> setValue(String key,String value)async{
     LocalStorage.setString(key, value);
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      //  mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Add Keys",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            obscureText: true,
            controller: securityIv,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: "Iv",
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: securityKey,
            obscureText: true,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: "Key",
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              ElevatedButton(
                onPressed: () async{

                  String iv = securityIv.text;
                  String key = securityKey.text;

                  if(iv.isNotEmpty &&key.isNotEmpty){
                    setValue('security_iv',iv);
                    setValue('security_key',key);
                    Navigator.pop(context);
                  }

                },
                child: const Text("SubmitKey"),
              )

            ],
          )

        ],
      ),
    );
  }
}
