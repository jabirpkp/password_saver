import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_saver/model/password.dart';
import '../controller/controller.dart';
import '../controller/cryptoHelper.dart';

class BeautifulList extends StatelessWidget {

  final PasswordController controller = Get.put(PasswordController());
  final TextEditingController searchController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  BeautifulList({super.key});

  void showAddDialog(BuildContext context) {

    TextEditingController titleController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Container(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Add Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),

                    ElevatedButton(
                      onPressed: () async{

                        String title = titleController.text;
                        String password = passwordController.text;

                        if(title.isNotEmpty &&
                            password.isNotEmpty &&
                            password.length > 4){

                          await controller.addPassword(password, title);

                          Navigator.pop(context);
                        }

                      },
                      child: const Text("Save"),
                    )

                  ],
                )

              ],
            ),
          ),
        );

      },
    );
  }

  void showEditDialog(BuildContext context, PasswordModel model) {

    TextEditingController titleController =
    TextEditingController(text: model.title);

    TextEditingController passwordController =
    TextEditingController(text: model.password);

    bool allowEdit = false;

    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(builder: (context,setState){

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Container(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Show Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    readOnly: !allowEdit,
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    readOnly: !allowEdit,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      const Text("Edit"),

                      Checkbox(
                        value: allowEdit,
                        onChanged: (value){

                          setState(() {
                            allowEdit = !allowEdit;
                          });

                        },
                      )

                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      ElevatedButton(
                        onPressed: () async{

                          String title = titleController.text;
                          String password = passwordController.text;

                          if(title.isNotEmpty &&
                              password.isNotEmpty &&
                              password.length > 4){

                            model.title = title;
                            model.password = password;

                            await controller.updatePassword(model);

                            Navigator.pop(context);
                          }

                        },
                        child: const Text("Save"),
                      ),

                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text("Back"),
                      ),

                    ],
                  )

                ],
              ),
            ),
          );

        });

      },
    );
  }

  Future<void> authenticate(
      BuildContext context,
      PasswordModel model) async {

    try {

      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint',
        biometricOnly: true,
      );

      if (authenticated) {

        var password = CryptoHelper.decryptText(model.password);

        model.password = password;

        showEditDialog(context, model);

      }

    } catch (e) {

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: TextFormField(
          controller: searchController,

          decoration: InputDecoration(
            hintText: "Search password...",
            prefixIcon: const Icon(Icons.search),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          onChanged: (value){
            controller.searchPassword(value);
          },
        ),
      ),

      body: Obx(() {

        return ListView.builder(

          padding: const EdgeInsets.all(12),

          itemCount: controller.filteredList.length,

          itemBuilder: (context,index){

            var item = controller.filteredList[index];

            return Card(

              color: const Color(0xFF1E1E1E),

              elevation: 6,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(

                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.lock,color: Colors.white),
                ),

                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  item.password,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                trailing: ElevatedButton(
                  onPressed: (){
                    authenticate(context,item);
                  },
                  child: const Text("View"),
                ),

              ),
            );

          },
        );

      }),

      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.add),
        onPressed: (){
          showAddDialog(context);
        },
      ),

    );

  }

}