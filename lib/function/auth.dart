
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass{
  final storage =new FlutterSecureStorage();
  Future <void> storeTokenAndData(String uid) async{
    //await storage.write(key:"token",value: userCredential.credential?.token.toString());
    await storage.write(key:"uid",value: uid);
    print('storage');
    print(storage);
  }

  Future <void> logout() async{
    //await storage.write(key:"token",value: userCredential.credential?.token.toString());
    await storage.delete(key: "uid");
  }
  Future<String?> getToken() async{
    return await storage.read(key:"uid");
  }
}