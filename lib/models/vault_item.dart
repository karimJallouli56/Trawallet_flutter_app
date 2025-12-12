import 'package:hive/hive.dart';

part 'vault_item.g.dart';

@HiveType(typeId: 0)
class VaultItem extends HiveObject {
  @HiveField(0)
  String fileName;

  @HiveField(1)
  String encryptedPath;

  @HiveField(2)
  String fileType; // passport, visa, ticket

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  String userId; // Added userId field

  VaultItem({
    required this.fileName,
    required this.encryptedPath,
    required this.fileType,
    required this.createdAt,
    required this.userId, // Added userId parameter
  });
}