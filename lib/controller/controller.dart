import 'package:get/get.dart';
import 'package:password_saver/model/password.dart';
import 'package:password_saver/repository/repository.dart';
import 'package:password_saver/controller/cryptoHelper.dart';

class PasswordController extends GetxController {

  Repository repository = Repository();

  RxList<PasswordModel> data = <PasswordModel>[].obs;
  RxList<PasswordModel> filteredList = <PasswordModel>[].obs;

  @override
  void onInit() {
    loadPasswords();
    super.onInit();
  }

  Future<void> loadPasswords() async {
    var response = await repository.fetchList();
    data.value = response;
    filteredList.value = response;
  }

  void searchPassword(String query) {
    if (query.isEmpty) {
      filteredList.value = data;
    } else {
      filteredList.value = data
          .where((item) =>
          item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<bool> addPassword(String password, String title) async {
    password = CryptoHelper.encryptText(password);

    final response = await repository.addToDb(password, title);

    if (response) {
      loadPasswords();
    }

    return response;
  }

  Future<bool> updatePassword(PasswordModel model) async {
    var password = CryptoHelper.encryptText(model.password);

    final response =
    await repository.update(password, model.title, model.id);

    if (response) {
      loadPasswords();
    }

    return response;
  }
}