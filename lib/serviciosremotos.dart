import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertar(Map<String, dynamic> cancion) async {
    return await baseRemota.collection("cancion").add(cancion);
  }

  static Future<List> mostrarTodos() async{
    List temporal = [];
    var query = await baseRemota.collection("cancion").get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });
    return temporal;
  }

  static Future eliminar(String id) async{
    return await baseRemota.collection("cancion").doc(id).delete();
  }

  static Future actualizar(Map<String, dynamic> cancion) async{
    String id = cancion['id'];
    cancion.remove(id);
    return await baseRemota.collection("cancion").doc(id).update(cancion);

  }
}