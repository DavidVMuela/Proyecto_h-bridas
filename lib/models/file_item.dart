class FileItem {
  final String id;
  final String name;
  final String type;
  final double size;
  final DateTime date;
  final List<String> tags;
  final String? previewPath;
  bool isSynced;

  FileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    required this.tags,
    this.previewPath,
    this.isSynced = false,
  });

  // Datos de ejemplo
  static List<FileItem> getSampleFiles() {
    return [
      FileItem(
        id: '1',
        name: 'Contrato.pdf',
        type: 'PDF',
        size: 2.3,
        date: DateTime(2025, 10, 5),
        tags: ['Trabajo', 'Legal'],
        isSynced: true,
      ),
      FileItem(
        id: '2',
        name: 'Recibo_luz.jpg',
        type: 'JPG',
        size: 1.5,
        date: DateTime(2025, 10, 4),
        tags: ['Facturas'],
        isSynced: true,
      ),
      FileItem(
        id: '3',
        name: 'Presupuesto.xlsx',
        type: 'XLSX',
        size: 0.8,
        date: DateTime(2025, 10, 3),
        tags: ['Trabajo', '2025'],
        isSynced: false,
      ),
      FileItem(
        id: '4',
        name: 'Logo.png',
        type: 'PNG',
        size: 0.5,
        date: DateTime(2025, 10, 2),
        tags: ['Trabajo', 'Diseño'],
        isSynced: true,
      ),
      FileItem(
        id: '5',
        name: 'Informe_Q3.docx',
        type: 'DOCX',
        size: 1.2,
        date: DateTime(2025, 10, 1),
        tags: ['Trabajo', 'Reportes'],
        isSynced: true,
      ),
    ];
  }
}