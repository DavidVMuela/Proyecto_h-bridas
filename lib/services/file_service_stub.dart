// Stub para plataformas no soportadas
class File {
  final String path;
  File(this.path);
  
  Future<int> length() async => 0;
  Future<bool> exists() async => false;
  Future<void> delete() async {}
  Future<File> copy(String newPath) async => this;
}