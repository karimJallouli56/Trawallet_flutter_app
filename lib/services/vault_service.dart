import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/vault_item.dart';

class VaultService {
  // Singleton pattern
  static final VaultService instance = VaultService._internal();
  VaultService._internal();
  factory VaultService() => instance;

  static const String boxName = 'vaultBox';
  final _secureStorage = FlutterSecureStorage();
  late Key _aesKey;
  late Box<VaultItem> _box;

  Box<VaultItem> get box => _box;

  Future<void> init() async {
    _box = Hive.box<VaultItem>(boxName);
    await _initAESKey();
  }

  Future<void> _initAESKey() async {
    String? keyString = await _secureStorage.read(key: 'vault_key');
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = base64UrlEncode(key.bytes);
      await _secureStorage.write(key: 'vault_key', value: keyString);
    }
    _aesKey = Key(base64Url.decode(keyString));
  }

  // Get all vault items
  List<VaultItem> getAll() => box.values.toList();

  // Add document
  Future<void> addVaultItem(File file, String fileType) async {
    final encryptedPath = await _encryptAndSaveFile(file);
    final item = VaultItem(
      fileName: file.uri.pathSegments.last,
      encryptedPath: encryptedPath,
      fileType: fileType,
      createdAt: DateTime.now(),
    );
    await box.add(item);
  }

  // Update vault item at index
  Future<void> updateVaultItemAt(int index, VaultItem item) async {
    await box.putAt(index, item);
  }

  // Delete vault item at index
  Future<void> deleteAt(int index) async {
    final item = box.getAt(index);
    if (item != null) {
      final file = File(item.encryptedPath);
      if (await file.exists()) await file.delete();
      await box.deleteAt(index);
    }
  }

  // Encrypt file and save locally
  Future<String> _encryptAndSaveFile(File file) async {
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(_aesKey));

    final bytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    final dir = await getApplicationDocumentsDirectory();
    final encryptedFile = File('${dir.path}/${file.uri.pathSegments.last}.enc');
    await encryptedFile.writeAsBytes(iv.bytes + encrypted.bytes);

    return encryptedFile.path;
  }

  // Decrypt file
  Future<File> decryptFile(String encryptedPath) async {
    final encrypter = Encrypter(AES(_aesKey));
    final encryptedFile = File(encryptedPath);
    final bytes = await encryptedFile.readAsBytes();

    final iv = IV(bytes.sublist(0, 16));
    final encryptedBytes = bytes.sublist(16);

    final decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);

    final dir = await getApplicationDocumentsDirectory();
    final decryptedFile = File(
      '${dir.path}/decrypted_${encryptedFile.uri.pathSegments.last}',
    );
    await decryptedFile.writeAsBytes(decrypted);

    return decryptedFile;
  }
}
