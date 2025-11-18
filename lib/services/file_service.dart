import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/file_item.dart';
import 'firestore_service.dart';

class FileService {
  final FirestoreService _firestoreService = FirestoreService();

  // Guardar archivo localmente y registrar en Firestore
  Future<String> saveFile({
    required File file,
    required String fileName,
    required List<String> tags,
  }) async {
    try {
      // Obtener directorio local de la app
      Directory appDir = await getApplicationDocumentsDirectory();
      String localPath = '${appDir.path}/files';
      
      // Crear carpeta si no existe
      Directory(localPath).createSync(recursive: true);
      
      // Guardar archivo localmente
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String extension = path.extension(fileName);
      String uniqueFileName = '${timestamp}_$fileName';
      String filePath = '$localPath/$uniqueFileName';
      
      await file.copy(filePath);
      
      // Obtener tamaño del archivo
      int fileSizeBytes = await file.length();
      double fileSizeMB = fileSizeBytes / (1024 * 1024);
      
      // Crear FileItem
      FileItem fileItem = FileItem(
        id: timestamp,
        name: fileName,
        type: extension.replaceAll('.', '').toUpperCase(),
        size: double.parse(fileSizeMB.toStringAsFixed(2)),
        date: DateTime.now(),
        tags: tags,
        previewPath: filePath,
        isSynced: false,
      );
      
      // Guardar en Firestore
      String fileId = await _firestoreService.addFile(fileItem);
      
      return fileId;
    } catch (e) {
      throw 'Error al guardar archivo: $e';
    }
  }

  // Obtener archivo local
  Future<File?> getLocalFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      throw 'Error al obtener archivo: $e';
    }
  }

  // Eliminar archivo local
  Future<void> deleteLocalFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw 'Error al eliminar archivo: $e';
    }
  }

  // Obtener tamaño total de archivos locales
  Future<double> getTotalStorageUsed() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String localPath = '${appDir.path}/files';
      
      Directory dir = Directory(localPath);
      if (!await dir.exists()) return 0;
      
      int totalBytes = 0;
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
      
      return totalBytes / (1024 * 1024); // Convertir a MB
    } catch (e) {
      return 0;
    }
  }

  // Limpiar archivos locales
  Future<void> clearLocalStorage() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String localPath = '${appDir.path}/files';
      
      Directory dir = Directory(localPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw 'Error al limpiar almacenamiento: $e';
    }
  }
}