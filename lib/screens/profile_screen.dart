import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _notificationsEnabled = true;
  bool _autoSync = true;
  String _storageProvider = 'Local';
  
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      final stats = await _firestoreService.getUserStats();
      
      setState(() {
        _userData = userData;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Editar perfil - En desarrollo'),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildStatsCards(),
              SizedBox(height: 20),
              _buildSettingsSection(),
              SizedBox(height: 20),
              _buildAccountSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String userName = _userData?['name'] ?? 'Usuario';
    String userEmail = _authService.currentUser?.email ?? 'email@ejemplo.com';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 47,
              backgroundColor: Colors.blue[100],
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  _userData?['plan']?.toUpperCase() ?? 'GRATIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    int totalFiles = _stats?['totalFiles'] ?? 0;
    int totalTags = _stats?['totalTags'] ?? 0;
    double storageUsed = (_stats?['storageUsed'] ?? 0) / (1024 * 1024);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.folder,
              '$totalFiles',
              'Archivos',
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.storage,
              '${storageUsed.toStringAsFixed(1)} MB',
              'Usado',
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.label,
              '$totalTags',
              'Etiquetas',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Configuración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Divider(height: 1),
          SwitchListTile(
            title: Text('Notificaciones'),
            subtitle: Text('Recibir alertas de sincronización'),
            secondary: Icon(Icons.notifications, color: Colors.blue[700]),
            value: _notificationsEnabled,
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          Divider(height: 1),
          SwitchListTile(
            title: Text('Sincronización automática'),
            subtitle: Text('Subir archivos automáticamente'),
            secondary: Icon(Icons.sync, color: Colors.blue[700]),
            value: _autoSync,
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.cloud, color: Colors.blue[700]),
            title: Text('Almacenamiento'),
            subtitle: Text(_storageProvider),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Almacenamiento local activo'),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.language, color: Colors.blue[700]),
            title: Text('Idioma'),
            subtitle: Text('Español'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cambiar idioma - En desarrollo'),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blue[700]),
            title: Text('Cambiar contraseña'),
            trailing: Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.storage, color: Colors.blue[700]),
            title: Text('Gestionar almacenamiento'),
            trailing: Icon(Icons.chevron_right),
            onTap: _showStorageDialog,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue[700]),
            title: Text('Acerca de'),
            trailing: Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contraseña actualizada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('Cambiar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStorageDialog() {
    double storageUsed = (_stats?['storageUsed'] ?? 0) / (1024 * 1024);
    double storageLimit = (_stats?['storageLimit'] ?? 104857600) / (1024 * 1024);
    double percentage = storageUsed / storageLimit;

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
              Text(
                'Espacio usado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Archivos:'),
                  Text('${storageUsed.toStringAsFixed(2)} MB', 
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                color: Colors.blue[700],
                minHeight: 8,
              ),
              SizedBox(height: 16),
              Text(
                '${storageUsed.toStringAsFixed(2)} MB de ${storageLimit.toStringAsFixed(0)} MB utilizados',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'Espacio disponible: ${(storageLimit - storageUsed).toStringAsFixed(2)} MB',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.folder_special, color: Colors.blue[700]),
              SizedBox(width: 10),
              Text('Acerca de'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organizador de Archivos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Versión 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Desarrollado por:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('David Villagómez'),
              Text('5to "B" Desarrollo de Software'),
              SizedBox(height: 16),
              Text(
                'Materia: Aplicaciones Híbridas',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                '© 2025 - Proyecto Académico',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas cerrar sesión?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}