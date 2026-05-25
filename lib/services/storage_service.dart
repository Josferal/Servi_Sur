import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageServiceException implements Exception {
  const StorageServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UploadedRequestImage {
  const UploadedRequestImage({
    required this.url,
    required this.path,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
  });

  final String url;
  final String path;
  final String fileName;
  final String contentType;
  final int sizeBytes;

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'path': path,
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
    };
  }
}

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage;

  static const maxImageBytes = 5 * 1024 * 1024;

  final FirebaseStorage? _storage;

  FirebaseStorage get _firebaseStorage => _storage ?? FirebaseStorage.instance;

  Future<UploadedRequestImage> uploadRequestImage({
    required String uid,
    required String orderId,
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return uploadRequestImageBytes(
        uid: uid,
        orderId: orderId,
        bytes: bytes,
        originalName: file.name,
        contentType: file.mimeType,
      );
    } on FirebaseException catch (error) {
      throw StorageServiceException(_storageErrorMessage(error));
    } on StorageServiceException {
      rethrow;
    } catch (_) {
      throw const StorageServiceException(
        'No se pudo leer la imagen seleccionada.',
      );
    }
  }

  Future<UploadedRequestImage> uploadRequestImageBytes({
    required String uid,
    required String orderId,
    required Uint8List bytes,
    required String originalName,
    String? contentType,
  }) async {
    final resolvedContentType = _resolveContentType(originalName, contentType);
    if (!resolvedContentType.startsWith('image/')) {
      throw const StorageServiceException('Solo puedes adjuntar imagenes.');
    }
    if (bytes.length > maxImageBytes) {
      throw const StorageServiceException(
        'Cada imagen debe pesar 5 MB o menos.',
      );
    }

    final fileName = _safeFileName(originalName);
    final path = 'request_images/$uid/$orderId/$fileName';
    final reference = _firebaseStorage.ref(path);

    try {
      await reference.putData(
        bytes,
        SettableMetadata(
          contentType: resolvedContentType,
          customMetadata: {'originalName': originalName},
        ),
      );
      final url = await reference.getDownloadURL();
      return UploadedRequestImage(
        url: url,
        path: path,
        fileName: fileName,
        contentType: resolvedContentType,
        sizeBytes: bytes.length,
      );
    } on FirebaseException catch (error) {
      throw StorageServiceException(_storageErrorMessage(error));
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _firebaseStorage.ref(path).delete();
    } on FirebaseException catch (error) {
      throw StorageServiceException(_storageErrorMessage(error));
    }
  }

  String _safeFileName(String originalName) {
    final sanitized = originalName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    final extension = _extensionFromName(sanitized);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '$timestamp$extension';
  }

  String _extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '.jpg';
    }
    final extension = name.substring(dotIndex);
    if (extension.length > 8) {
      return '.jpg';
    }
    return extension;
  }

  String _resolveContentType(String originalName, String? contentType) {
    if (contentType != null && contentType.isNotEmpty) {
      return contentType;
    }
    final lower = originalName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  String _storageErrorMessage(FirebaseException error) {
    return switch (error.code) {
      'unauthorized' => 'No tienes permiso para subir esta imagen.',
      'canceled' => 'La subida de la imagen fue cancelada.',
      'quota-exceeded' => 'Storage no tiene cuota disponible en este momento.',
      'retry-limit-exceeded' =>
        'La conexion fallo varias veces al subir la imagen.',
      _ => 'No se pudo subir la imagen. Intenta de nuevo.',
    };
  }
}
