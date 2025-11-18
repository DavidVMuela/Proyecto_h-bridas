import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/file_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener referencia a la colección de archivos del usuario
  CollectionReference _getUserFilesCollection() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('files');
  }

  // Crear/Agregar archivo
  Future<String> addFile(FileItem file) async {
    try {
      DocumentReference docRef = await _getUserFilesCollection().add({
        'name': file.name,
        'type': file.type,
        'size': file.size,
        'date': Timestamp.fromDate(file.date),
        'tags': file.tags,
        'isSynced': file.isSynced,
        'previewPath': file.previewPath,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar espacio usado del usuario
      await _updateStorageUsed(file.size);

      return docRef.id;
    } catch (e) {
      throw 'Error al agregar archivo: $e';
    }
  }

  // Obtener todos los archivos del usuario
  Stream<List<FileItem>> getFiles() {
    try {
      return _getUserFilesCollection()
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return FileItem(
            id: doc.id,
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            size: (data['size'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            tags: List<String>.from(data['tags'] ?? []),
            previewPath: data['previewPath'],
            isSynced: data['isSynced'] ?? false,
          );
        }).toList();
      });
    } catch (e) {
      throw 'Error al obtener archivos: $e';
    }
  }

  // Obtener archivo por ID
  Future<FileItem?> getFileById(String fileId) async {
    try {
      DocumentSnapshot doc = await _getUserFilesCollection().doc(fileId).get();
      
      if (!doc.exists) return null;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return FileItem(
        id: doc.id,
        name: data['name'] ?? '',
        type: data['type'] ?? '',
        size: (data['size'] ?? 0).toDouble(),
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        tags: List<String>.from(data['tags'] ?? []),
        previewPath: data['previewPath'],
        isSynced: data['isSynced'] ?? false,
      );
    } catch (e) {
      throw 'Error al obtener archivo: $e';
    }
  }

  // Actualizar archivo
  Future<void> updateFile(String fileId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _getUserFilesCollection().doc(fileId).update(data);
    } catch (e) {
      throw 'Error al actualizar archivo: $e';
    }
  }

  // Actualizar tags de un archivo
  Future<void> updateFileTags(String fileId, List<String> tags) async {
    try {
      await _getUserFilesCollection().doc(fileId).update({
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al actualizar etiquetas: $e';
    }
  }

  // Marcar archivo como sincronizado
  Future<void> markAsSynced(String fileId) async {
    try {
      await _getUserFilesCollection().doc(fileId).update({
        'isSynced': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al sincronizar archivo: $e';
    }
  }

  // Eliminar archivo
  Future<void> deleteFile(String fileId, double fileSize) async {
    try {
      await _getUserFilesCollection().doc(fileId).delete();
      
      // Actualizar espacio usado del usuario (restar el tamaño)
      await _updateStorageUsed(-fileSize);
    } catch (e) {
      throw 'Error al eliminar archivo: $e';
    }
  }

  // Buscar archivos por nombre
  Stream<List<FileItem>> searchFilesByName(String query) {
    try {
      return _getUserFilesCollection()
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return FileItem(
            id: doc.id,
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            size: (data['size'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            tags: List<String>.from(data['tags'] ?? []),
            previewPath: data['previewPath'],
            isSynced: data['isSynced'] ?? false,
          );
        }).toList();
      });
    } catch (e) {
      throw 'Error al buscar archivos: $e';
    }
  }

  // Filtrar archivos por tipo
  Stream<List<FileItem>> getFilesByType(String type) {
    try {
      return _getUserFilesCollection()
          .where('type', isEqualTo: type)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return FileItem(
            id: doc.id,
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            size: (data['size'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            tags: List<String>.from(data['tags'] ?? []),
            previewPath: data['previewPath'],
            isSynced: data['isSynced'] ?? false,
          );
        }).toList();
      });
    } catch (e) {
      throw 'Error al filtrar archivos: $e';
    }
  }

  // Filtrar archivos por etiqueta
  Stream<List<FileItem>> getFilesByTag(String tag) {
    try {
      return _getUserFilesCollection()
          .where('tags', arrayContains: tag)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return FileItem(
            id: doc.id,
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            size: (data['size'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            tags: List<String>.from(data['tags'] ?? []),
            previewPath: data['previewPath'],
            isSynced: data['isSynced'] ?? false,
          );
        }).toList();
      });
    } catch (e) {
      throw 'Error al filtrar por etiqueta: $e';
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Obtener datos del usuario
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Contar archivos
      QuerySnapshot filesSnapshot = await _getUserFilesCollection().get();
      int totalFiles = filesSnapshot.docs.length;

      // Contar etiquetas únicas
      Set<String> uniqueTags = {};
      for (var doc in filesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> tags = List<String>.from(data['tags'] ?? []);
        uniqueTags.addAll(tags);
      }

      return {
        'totalFiles': totalFiles,
        'totalTags': uniqueTags.length,
        'storageUsed': userData['storageUsed'] ?? 0,
        'storageLimit': userData['storageLimit'] ?? 104857600,
      };
    } catch (e) {
      throw 'Error al obtener estadísticas: $e';
    }
  }

  // Actualizar espacio usado
  Future<void> _updateStorageUsed(double sizeChange) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference userDoc = _firestore.collection('users').doc(uid);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);
        
        if (!snapshot.exists) {
          throw 'Usuario no encontrado';
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        double currentStorage = (data['storageUsed'] ?? 0).toDouble();
        double newStorage = currentStorage + (sizeChange * 1024 * 1024); // Convertir MB a bytes

        transaction.update(userDoc, {'storageUsed': newStorage});
      });
    } catch (e) {
      throw 'Error al actualizar almacenamiento: $e';
    }
  }

  // Obtener todas las etiquetas únicas del usuario
  Future<List<String>> getAllTags() async {
    try {
      QuerySnapshot snapshot = await _getUserFilesCollection().get();
      Set<String> tags = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> fileTags = List<String>.from(data['tags'] ?? []);
        tags.addAll(fileTags);
      }

      return tags.toList()..sort();
    } catch (e) {
      throw 'Error al obtener etiquetas: $e';
    }
  }
}