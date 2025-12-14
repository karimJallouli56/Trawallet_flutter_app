import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vault_item.dart';

class VaultService {
  static final VaultService instance = VaultService._internal();
  VaultService._internal();
  factory VaultService() => instance;

  static const String boxName = 'vaultBox';
  final _secureStorage = const FlutterSecureStorage();
  final _auth = FirebaseAuth.instance;

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

  String? get _currentUserId => _auth.currentUser?.uid;

  List<VaultItem> getAll() {
    if (_currentUserId == null) return [];
    return box.values.where((item) => item.userId == _currentUserId).toList();
  }

  List<VaultItem> getByType(String fileType) {
    if (_currentUserId == null) return [];
    return box.values
        .where(
          (item) => item.userId == _currentUserId && item.fileType == fileType,
        )
        .toList();
  }

  Future<void> addVaultItem(File file, String fileType) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final encryptedPath = await _encryptAndSaveFile(file);
    final item = VaultItem(
      fileName: file.uri.pathSegments.last,
      encryptedPath: encryptedPath,
      fileType: fileType,
      createdAt: DateTime.now(),
      userId: _currentUserId!,
    );
    await box.add(item);
  }

  Future<void> updateVaultItemAt(int index, VaultItem item) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final existingItem = box.getAt(index);
    if (existingItem?.userId != _currentUserId) {
      throw Exception('Unauthorized: Cannot update another user\'s item');
    }

    await box.putAt(index, item);
  }

  Future<void> deleteAt(int index) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final item = box.getAt(index);
    if (item == null) return;

    if (item.userId != _currentUserId) {
      throw Exception('Unauthorized: Cannot delete another user\'s item');
    }

    final file = File(item.encryptedPath);
    if (await file.exists()) await file.delete();
    await box.deleteAt(index);
  }

  Future<void> deleteItem(VaultItem item) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (item.userId != _currentUserId) {
      throw Exception('Unauthorized: Cannot delete another user\'s item');
    }

    final file = File(item.encryptedPath);
    if (await file.exists()) await file.delete();
    await item.delete();
  }

  Future<void> clearCurrentUserData() async {
    if (_currentUserId == null) return;

    final userItems = getAll();
    for (var item in userItems) {
      final file = File(item.encryptedPath);
      if (await file.exists()) await file.delete();
      await item.delete();
    }
  }

  Future<String> _encryptAndSaveFile(File file) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(_aesKey));
    final bytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_currentUserId}_${file.uri.pathSegments.last}';
    final encryptedFile = File('${dir.path}/$fileName.enc');
    await encryptedFile.writeAsBytes(iv.bytes + encrypted.bytes);

    return encryptedFile.path;
  }

  Future<File> decryptFile(String encryptedPath) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final matchingItem = box.values.firstWhere(
      (item) =>
          item.encryptedPath == encryptedPath && item.userId == _currentUserId,
      orElse: () =>
          throw Exception('Unauthorized: File does not belong to current user'),
    );

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
