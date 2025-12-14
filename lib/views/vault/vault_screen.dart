import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:trawallet_final_version/models/vault_item.dart';
import 'package:trawallet_final_version/services/vault_service.dart';
import 'package:trawallet_final_version/views/home/components/capitalizeWords.dart';
import 'package:trawallet_final_version/views/vault/component/imageViewerScreen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with WidgetsBindingObserver {
  final vault = VaultService.instance;
  final LocalAuthentication auth = LocalAuthentication();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  DateTime? _lastAuthTime;
  final Duration _authTimeout = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticateUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthTimeout();
    }
  }

  void _checkAuthTimeout() {
    if (_lastAuthTime != null) {
      final timeSinceAuth = DateTime.now().difference(_lastAuthTime!);
      if (timeSinceAuth > _authTimeout) {
        setState(() {
          _isAuthenticated = false;
        });
        _authenticateUser();
      }
    }
  }

  Future<void> _authenticateUser() async {
    setState(() => _isLoading = true);

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showErrorAndExit(
          'Biometric authentication is not available on this device',
        );
        return;
      }

      final List<BiometricType> availableBiometrics = await auth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        _showErrorAndExit(
          'No biometric methods are enrolled. Please set up fingerprint or face ID in your device settings.',
        );
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access your secure vault',
        biometricOnly: false,
      );

      setState(() {
        _isAuthenticated = didAuthenticate;
        _isLoading = false;
        if (didAuthenticate) {
          _lastAuthTime = DateTime.now();
        }
      });

      if (!didAuthenticate) {
        _showRetryDialog();
      }
    } on PlatformException catch (e) {
      setState(() => _isLoading = false);

      if (e.code == 'NotAvailable') {
        _showErrorAndExit('Biometric authentication not available');
      } else if (e.code == 'NotEnrolled') {
        _showErrorAndExit(
          'No biometrics enrolled. Please set up fingerprint or face ID.',
        );
      } else {
        _showRetryDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showRetryDialog();
    }
  }

  void _showErrorAndExit(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Authentication Failed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You must authenticate to access the secure vault.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticateUser();
            },
            child: const Text('Retry', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
                const SizedBox(height: 16),
                const Text('Authenticating...'),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'Vault Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Authentication required',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _authenticateUser,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Secure Digital Vault",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.teal,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),

            tooltip: 'Lock Vault',
            onPressed: () {
              setState(() {
                _isAuthenticated = false;
                _lastAuthTime = null;
              });
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _chooseAddOption,
        child: const Icon(Icons.add),
      ),

      body: ValueListenableBuilder(
        valueListenable: vault.box.listenable(),
        builder: (context, box, _) {
          final items = vault.getAll();

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No documents stored",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildVaultCard(item, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildVaultCard(VaultItem item, int index) {
    return InkWell(
      onTap: () => _openDocument(item),
      child: SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Icon(_getIcon(item.fileType), size: 36, color: Colors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          capitalizeWords(item.fileType),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          item.createdAt.toString().substring(0, 16),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.teal),
                    onPressed: () => _deleteDocument(index),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "passport":
        return Icons.perm_identity;
      case "ticket":
        return Icons.airplane_ticket;
      case "visa":
        return Icons.credit_card;
      default:
        return Icons.folder;
    }
  }

  Future<void> _chooseAddOption() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.camera, color: Colors.teal),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _addDocumentFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.teal),
              title: const Text("Pick a File"),
              onTap: () {
                Navigator.pop(context);
                _addDocumentFromFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDocumentFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    await _selectTypeAndSave(file);
  }

  Future<void> _addDocumentFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    await _selectTypeAndSave(File(photo.path));
  }

  Future<void> _selectTypeAndSave(File file) async {
    String? type = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Select Document Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _typeButton("passport"),
            _typeButton("visa"),
            _typeButton("ticket"),
          ],
        ),
      ),
    );

    if (type == null) return;

    await vault.addVaultItem(file, type);
  }

  Widget _typeButton(String type) {
    return ListTile(
      title: Text(capitalizeWords(type)),
      onTap: () => Navigator.pop(context, type),
    );
  }

  Future<void> _openDocument(VaultItem item) async {
    final decrypted = await vault.decryptFile(item.encryptedPath);

    if (item.fileType == 'passport' ||
        item.fileType == 'visa' ||
        item.fileType == 'ticket') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ImageViewerScreen(file: decrypted, fileType: item.fileType),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open this file type inside app.")),
      );
    }
  }

  Future<void> _deleteDocument(int index) async {
    await vault.deleteAt(index);
  }
}
