import 'package:equatable/equatable.dart';

class ContractAttachment extends Equatable {
  final String id;
  final int? remoteId;
  final String name;
  final String? filePath;
  final String? fileUrl;
  final int? fileSize;

  const ContractAttachment({
    required this.id,
    this.remoteId,
    this.name = '',
    this.filePath,
    this.fileUrl,
    this.fileSize,
  });

  bool get isRemote => remoteId != null;

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
      remoteId: remoteId,
      name: name ?? this.name,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: clearFileSize ? null : (fileSize ?? this.fileSize),
    );
  }

  factory ContractAttachment.fromJson(Map<String, dynamic> json) {
    return ContractAttachment(
      id: 'remote_${json['id']}',
      remoteId: json['id'],
      name: json['name'] ?? '',
      fileUrl: json['validated_url'] ?? json['file_url'],
      fileSize: json['file_size'],
    );
  }

  @override
  List<Object?> get props => [id, remoteId, name, filePath, fileUrl, fileSize];
}
