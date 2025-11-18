import 'dart:io' if (dart.library.html) 'file_service_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import '../models/file_item.dart';
import 'firestore_service.dart';

class FileService {
  final FirestoreService _firestoreService = FirestoreService();

  // Guardar archivo
  Future<String> saveFile({
    required dynamic file,
    required String fileName,
    required List<String> tags,
  }) async {
    try {
      // Obtener tamaño del archivo
      int fileSizeBytes = 0;
      
      if (!kIsWeb && file is File) {
        fileSizeBytes = await file.length();
      } else if (file.runtimeType.toString().contains('XFile')) {
        // Para XFile de image_picker
        fileSizeBytes = await (file as dynamic).length();
      }
      
      double fileSizeMB = fileSizeBytes / (1024 * 1024);
      
      // Obtener extensión
      String extension = path.extension(fileName);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Crear FileItem
      FileItem fileItem = FileItem(
        id: timestamp,
        name: fileName,
        type: extension.replaceAll('.', '').toUpperCase(),
        size: double.parse(fileSizeMB.toStringAsFixed(2)),
        date: DateTime.now(),
        tags: tags,
        previewPath: null, // No guardamos path en web
        isSynced: true,
      );
      
      // Guardar en Firestore
      String fileId = await _firestoreService.addFile(fileItem);
      
      return fileId;
    } catch (e) {
      throw 'Error al guardar archivo: $e';
    }
  }

  // Obtener archivo local (solo funciona en móvil/desktop)
  Future<File?> getLocalFile(String? filePath) async {
    if (kIsWeb || filePath == null) {
      return null;
    }
    
    try {
      File file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Eliminar archivo local
  Future<void> deleteLocalFile(String? filePath) async {
    if (kIsWeb || filePath == null) {
      return;
    }
    
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignorar errores
    }
  }

  // Obtener tamaño total de archivos
  Future<double> getTotalStorageUsed() async {
    return 0.0;
  }

  // Limpiar almacenamiento local
  Future<void> clearLocalStorage() async {
    if (kIsWeb) {
      return;
    }
  }
}