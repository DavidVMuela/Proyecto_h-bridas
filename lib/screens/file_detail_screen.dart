import 'package:flutter/material.dart';
import 'dart:io';
import '../models/file_item.dart';
import '../services/firestore_service.dart';
import '../services/file_service.dart';

class FileDetailScreen extends StatefulWidget {
  final FileItem file;

  FileDetailScreen({required this.file});

  @override
  _FileDetailScreenState createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FileService _fileService = FileService();
  
  late List<String> _tags;
  late bool _isSynced;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.file.tags);
    _isSynced = widget.file.isSynced;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.file.name),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compartir - En desarrollo'),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            SizedBox(height: 8),
            _buildInfoSection(),
            _buildTagsSection(),
            _buildSyncSection(),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      height: 300,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(),
              size: 100,
              color: _getFileColor(),
            ),
            SizedBox(height: 16),
            Text(
              'Vista Previa ${widget.file.type}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openFile,
              icon: Icon(Icons.open_in_new),
              label: Text('Abrir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFile() async {
    if (widget.file.previewPath != null) {
      try {
        File? file = await _fileService.getLocalFile(widget.file.previewPath!);
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo encontrado: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
          // Aquí podrías usar un paquete como open_file para abrir el archivo
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo no encontrado en el almacenamiento local'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon() {
    switch (widget.file.type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'JPG':
      case 'PNG':
        return Icons.image;
      case 'XLSX':
        return Icons.table_chart;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (widget.file.type.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'JPG':
      case 'PNG':
        return Colors.purple;
      case 'XLSX':
        return Colors.green;
      case 'DOC':
      case 'DOCX':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              SizedBox(width: 8),
              Text(
                'Información',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          Divider(height: 24),
          _buildInfoRow(Icons.text_fields, 'Nombre', widget.file.name),
          SizedBox(height: 12),
          _buildInfoRow(Icons.storage, 'Tamaño', '${widget.file.size} MB'),
          SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Fecha', _formatDate(widget.file.date)),
          SizedBox(height: 12),
          _buildInfoRow(Icons.insert_drive_file, 'Tipo', widget.file.type),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTagsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: Colors.blue[700], size: 24),
              SizedBox(width: 8),
              Text(
                'Etiquetas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIcon: Icon(Icons.close, size: 18),
                    deleteIconColor: Colors.blue[700],
                    onDeleted: () => _removeTag(tag),
                  )),
              ActionChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.blue[700]),
                    SizedBox(width: 4),
                    Text('Agregar'),
                  ],
                ),
                onPressed: _showAddTagDialog,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _removeTag(String tag) async {
    setState(() {
      _tags.remove(tag);
    });

    try {
      await _firestoreService.updateFileTags(widget.file.id, _tags);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Etiqueta eliminada'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _tags.add(tag);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar etiqueta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSyncSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isSynced ? Icons.cloud_done : Icons.cloud_off,
            color: _isSynced ? Colors.green : Colors.orange,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSynced ? 'Sincronizado' : 'Sin sincronizar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _isSynced ? Colors.green : Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _isSynced
                      ? 'Tu archivo está guardado'
                      : 'Esperando sincronización',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!_isSynced)
            ElevatedButton(
              onPressed: _syncFile,
              child: Text('Sincronizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _syncFile() async {
    try {
      await _firestoreService.markAsSynced(widget.file.id);
      setState(() {
        _isSynced = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo sincronizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildActionsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          _buildActionButton(
            Icons.download,
            'Descargar',
            Colors.blue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Descargando archivo...')),
              );
            },
          ),
          SizedBox(height: 8),
          _buildActionButton(
            Icons.edit,
            'Renombrar',
            Colors.orange,
            () => _showRenameDialog(),
          ),
          SizedBox(height: 8),
          _buildActionButton(
            Icons.delete,
            'Eliminar',
            Colors.red,
            () => _showDeleteDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Etiqueta'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nombre de la etiqueta',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.label),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && !_tags.contains(controller.text)) {
                  String newTag = controller.text;
                  Navigator.pop(context);
                  
                  setState(() {
                    _tags.add(newTag);
                  });

                  try {
                    await _firestoreService.updateFileTags(widget.file.id, _tags);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Etiqueta agregada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    setState(() {
                      _tags.remove(newTag);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al agregar etiqueta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameDialog() {
    TextEditingController controller = TextEditingController(text: widget.file.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Renombrar Archivo'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nuevo nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Funcionalidad en desarrollo'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('Renombrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Eliminar Archivo'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${widget.file.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFile() async {
    try {
      // Eliminar archivo local si existe
      if (widget.file.previewPath != null) {
        await _fileService.deleteLocalFile(widget.file.previewPath!);
      }

      // Eliminar de Firestore
      await _firestoreService.deleteFile(widget.file.id, widget.file.size);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo eliminado'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOptions() {
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
              ListTile(
                leading: Icon(Icons.copy, color: Colors.blue[700]),
                title: Text('Duplicar'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Funcionalidad en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.drive_file_move, color: Colors.blue[700]),
                title: Text('Mover'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Funcionalidad en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue[700]),
                title: Text('Propiedades'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Funcionalidad en desarrollo')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}