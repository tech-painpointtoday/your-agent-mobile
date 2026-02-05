import 'package:equatable/equatable.dart';

class ContractAttachment extends Equatable {
  final int? id;
  final String key;
  final String name;
  final String? filePath;
  final String? fileUrl;
  final int? fileSize;

  const ContractAttachment({
    this.id,
    required this.key,
    this.name = '',
    this.filePath,
    this.fileUrl,
    this.fileSize,
  });

  bool get isRemote => id != null;

  ContractAttachment copyWith({
    String? name,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    bool clearFilePath = false,
    bool clearFileSize = false,
  }) {
    return ContractAttachment(
      id: id,
      key: key,
      name: name ?? this.name,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: clearFileSize ? null : (fileSize ?? this.fileSize),
    );
  }

  factory ContractAttachment.fromJson(Map<String, dynamic> json) {
    final serverId = json['id'];
    return ContractAttachment(
      id: serverId is int ? serverId : int.tryParse(serverId.toString()),
      key: 'remote_$serverId',
      name: json['name'] ?? '',
      fileUrl: json['validated_url'] ?? json['file_url'],
      fileSize: json['file_size'],
    );
  }

  @override
  List<Object?> get props => [id, key, name, filePath, fileUrl, fileSize];
}
