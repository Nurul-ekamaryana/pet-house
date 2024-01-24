import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_petshop/controller/usersContoller.dart';
import 'package:e_petshop/model.dart/log.dart';
import 'package:get/get.dart';

class LogController {
  final CollectionReference logsCollection =
      FirebaseFirestore.instance.collection('logs');
  final UsersController _usersController = Get.find<UsersController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLog(String activity) async {
    try {
      String username = _usersController.userName.value;

      await logsCollection.add({
        'activity': activity,
        'created_at': DateTime.now().toString(),
        'username': username,
      });
    } catch (e) {
      throw Exception('Failed to add log: $e');
    }
  }

  Stream<List<Log>> getLogsStream() {
    return logsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Log.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<int> countLog() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('logs').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error counting books: $e');
      return 0;
    }
  }
}
