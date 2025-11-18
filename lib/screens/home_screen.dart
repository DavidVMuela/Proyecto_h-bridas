import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/file_item.dart';
import '../services/firestore_service.dart';
import '../services/file_service.dart';
import 'file_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FileService _fileService = FileService();
  
  String _selectedCategory = 'Todos';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mis Archivos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No hay notificaciones'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: StreamBuilder<List<FileItem>>(
        stream: _firestoreService.getFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error al cargar archivos'),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          List<FileItem> files = snapshot.data ?? [];
          
          return Column(
            children: [
              _buildCategoryList(files),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Archivos Recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${_getFilteredFiles(files).length} archivos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _getFilteredFiles(files).isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getFilteredFiles(files).length,
                        itemBuilder: (context, index) {
                          return _buildFileCard(_getFilteredFiles(files)[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isUploading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FloatingActionButton.extended(
              onPressed: _handleUpload,
              icon: Icon(Icons.add),
              label: Text('Subir'),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
    );
  }

  List<FileItem> _getFilteredFiles(List<FileItem> files) {
    if (_selectedCategory == 'Todos') return files;
    return files.where((f) => f.tags.contains(_selectedCategory)).toList();
  }

  Map<String, int> _getCategories(List<FileItem> files) {
    Map<String, int> cats = {'Todos': files.length};
    for (var file in files) {
      for (var tag in file.tags) {
        cats[tag] = (cats[tag] ?? 0) + 1;
      }
    }
    return cats;
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.folder_special,
                    size: 40,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Organizador de Archivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder, color: Colors.blue[700]),
            title: Text('Mis Archivos'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.storage, color: Colors.blue[700]),
            title: Text('Almacenamiento'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              _showStorageInfo();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[700]),
            title: Text('Configuración'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon('Configuración');
            },
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<FileItem> files) {
    Map<String, int> categories = _getCategories(files);
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: categories.entries.map((entry) {
          bool isSelected = entry.key == _selectedCategory;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${_getCategoryIcon(entry.key)} ${entry.key} (${entry.value})'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = entry.key;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Todos':
        return '📁';
      case 'Trabajo':
        return '💼';
      case 'Personal':
        return '👤';
      case 'Facturas':
        return '🧾';
      case 'Diseño':
        return '🎨';
      case 'Reportes':
        return '📊';
      default:
        return '🏷️';
    }
  }

  Widget _buildFileCard(FileItem file) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileDetailScreen(file: file),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              _buildFileIcon(file.type),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${file.size} MB • ${_formatDate(file.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: file.tags.take(2).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                file.isSynced ? Icons.cloud_done : Icons.cloud_off,
                color: file.isSynced ? Colors.green : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toUpperCase()) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'JPG':
      case 'PNG':
        icon = Icons.image;
        color = Colors.purple;
        break;
      case 'XLSX':
      case 'DOC':
      case 'DOCX':
        icon = Icons.description;
        color = Colors.blue;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No hay archivos en esta categoría',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          TextButton.icon(
            onPressed: _handleUpload,
            icon: Icon(Icons.add),
            label: Text('Subir archivo'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUpload() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Subir Archivo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue[700]),
                ),
                title: Text('Desde Galería'),
                subtitle: Text('Selecciona imágenes de tu galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.insert_drive_file, color: Colors.green[700]),
                ),
                title: Text('Desde Archivos'),
                subtitle: Text('Selecciona documentos del dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.orange[700]),
                ),
                title: Text('Tomar Foto'),
                subtitle: Text('Captura un documento con la cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await _uploadFile(File(image.path), image.name);
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        await _uploadFile(File(image.path), image.name);
      }
    } catch (e) {
      _showError('Error al tomar foto: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        await _uploadFile(file, result.files.single.name);
      }
    } catch (e) {
      _showError('Error al seleccionar archivo: $e');
    }
  }

  Future<void> _uploadFile(File file, String fileName) async {
    // Mostrar diálogo para agregar etiquetas
    List<String> tags = await _showTagsDialog() ?? [];
    
    if (tags.isEmpty) {
      tags = ['Sin etiqueta'];
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _fileService.saveFile(
        file: file,
        fileName: fileName,
        tags: tags,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo subido exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Error al subir archivo: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<List<String>?> _showTagsDialog() async {
    List<String> selectedTags = [];
    List<String> availableTags = ['Trabajo', 'Personal', 'Facturas', 'Diseño', 'Legal', 'Reportes'];
    
    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Agregar Etiquetas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...availableTags.map((tag) {
                      return CheckboxListTile(
                        title: Text(tag),
                        value: selectedTags.contains(tag),
                        activeColor: Colors.blue[700],
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedTags),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: Text('Continuar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente disponible'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStorageInfo() async {
    try {
      Map<String, dynamic> stats = await _firestoreService.getUserStats();
      double storageUsedMB = stats['storageUsed'] / (1024 * 1024);
      double storageLimitMB = stats['storageLimit'] / (1024 * 1024);
      double percentage = storageUsedMB / storageLimitMB;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.storage, color: Colors.blue[700]),
                SizedBox(width: 10),
                Text('Almacenamiento'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Espacio usado: ${storageUsedMB.toStringAsFixed(2)} MB'),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue[700],
                ),
                SizedBox(height: 8),
                Text(
                  'Espacio disponible: ${(storageLimitMB - storageUsedMB).toStringAsFixed(2)} MB de ${storageLimitMB.toStringAsFixed(0)} MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError('Error al obtener información de almacenamiento');
    }
  }
}