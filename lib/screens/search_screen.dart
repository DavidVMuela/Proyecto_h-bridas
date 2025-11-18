import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../services/firestore_service.dart';
import 'file_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  String _selectedType = 'Todos';
  String _selectedTag = 'Todas';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Buscar Archivos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          Expanded(
            child: StreamBuilder<List<FileItem>>(
              stream: _firestoreService.getFiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<FileItem> allFiles = snapshot.data ?? [];
                List<FileItem> filteredFiles = _filterFiles(allFiles);

                return Column(
                  children: [
                    _buildResultsHeader(filteredFiles.length),
                    Expanded(
                      child: filteredFiles.isEmpty
                          ? _buildEmptyState()
                          : _buildResultsList(filteredFiles),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FileItem> _filterFiles(List<FileItem> files) {
    return files.where((file) {
      bool matchesSearch = file.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      bool matchesType =
          _selectedType == 'Todos' || file.type == _selectedType;
      bool matchesTag =
          _selectedTag == 'Todas' || file.tags.contains(_selectedTag);
      return matchesSearch && matchesType && matchesTag;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '🔍 Buscar por nombre...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(
              'Tipo: $_selectedType',
              Icons.category,
              () => _showTypeFilter(),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              'Tag: $_selectedTag',
              Icons.label,
              () => _showTagFilter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    bool isFiltered = !label.contains('Todos') && !label.contains('Todas');
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isFiltered ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltered ? Colors.blue[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isFiltered ? Colors.blue[700] : Colors.grey[600],
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isFiltered ? FontWeight.w600 : FontWeight.w400,
                  color: isFiltered ? Colors.blue[700] : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<FileItem> files) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _buildFileCard(files[index]);
      },
    );
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
                      children: file.tags.map((tag) {
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
            _searchQuery.isEmpty ? Icons.search : Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Busca tus archivos'
                : 'No se encontraron archivos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Usa la barra de búsqueda o los filtros'
                : 'Intenta con otros términos de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTypeFilter() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por Tipo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ..._buildTypeOptions(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTypeOptions() {
    List<String> types = ['Todos', 'PDF', 'JPG', 'PNG', 'XLSX', 'DOCX'];
    return types.map((type) {
      return RadioListTile<String>(
        title: Text(type),
        value: type,
        groupValue: _selectedType,
        activeColor: Colors.blue[700],
        onChanged: (value) {
          setState(() {
            _selectedType = value!;
          });
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  void _showTagFilter() async {
    try {
      List<String> allTags = await _firestoreService.getAllTags();
      allTags.insert(0, 'Todas');

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por Etiqueta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ...allTags.map((tag) {
                  return RadioListTile<String>(
                    title: Text(tag),
                    value: tag,
                    groupValue: _selectedTag,
                    activeColor: Colors.blue[700],
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar etiquetas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtros Avanzados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo: $_selectedType',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Etiqueta: $_selectedTag',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = 'Todos';
                  _selectedTag = 'Todas';
                  _searchQuery = '';
                  _searchController.clear();
                });
                Navigator.pop(context);
              },
              child: Text('Limpiar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}