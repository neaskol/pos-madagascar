import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service pour gérer les uploads de fichiers vers Supabase Storage
///
/// Gère :
/// - Upload de photos produits (items)
/// - Upload de photos variants
/// - Upload de logos magasins
/// - Génération d'URLs publiques
/// - Suppression de fichiers
class StorageService {
  final SupabaseClient _supabase;
  static const String _productImagesBucket = 'product-images';
  static const String _storeLogosBucket = 'store-logos';

  StorageService(this._supabase);

  /// Upload une photo de produit
  ///
  /// [storeId] - ID du magasin (pour organiser les fichiers)
  /// [file] - Fichier image à uploader
  /// [itemId] - ID du produit (optionnel, génère un UUID si null)
  ///
  /// Retourne l'URL publique de l'image uploadée
  Future<String> uploadProductImage({
    required String storeId,
    required File file,
    String? itemId,
  }) async {
    try {
      final uuid = const Uuid();
      final fileId = itemId ?? uuid.v4();
      final extension = path.extension(file.path);
      final fileName = '$storeId/$fileId$extension';

      // Upload vers Supabase Storage
      await _supabase.storage
          .from(_productImagesBucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Remplace si existe déjà
            ),
          );

      // Récupérer l'URL publique
      final publicUrl = _supabase.storage
          .from(_productImagesBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw StorageException('Erreur upload photo produit: $e');
    }
  }

  /// Upload une photo de variant
  ///
  /// Utilise le même bucket que les produits mais avec un préfixe différent
  Future<String> uploadVariantImage({
    required String storeId,
    required File file,
    String? variantId,
  }) async {
    try {
      final uuid = const Uuid();
      final fileId = variantId ?? uuid.v4();
      final extension = path.extension(file.path);
      final fileName = '$storeId/variants/$fileId$extension';

      await _supabase.storage
          .from(_productImagesBucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from(_productImagesBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw StorageException('Erreur upload photo variant: $e');
    }
  }

  /// Upload un logo de magasin
  Future<String> uploadStoreLogo({
    required String storeId,
    required File file,
  }) async {
    try {
      final extension = path.extension(file.path);
      final fileName = '$storeId/logo$extension';

      await _supabase.storage
          .from(_storeLogosBucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from(_storeLogosBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw StorageException('Erreur upload logo magasin: $e');
    }
  }

  /// Supprime une photo de produit
  ///
  /// [imageUrl] - URL complète de l'image à supprimer
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extraire le path du fichier depuis l'URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Format URL Supabase: .../storage/v1/object/public/product-images/...
      final bucketIndex = pathSegments.indexOf(_productImagesBucket);
      if (bucketIndex == -1) {
        throw StorageException('URL invalide: bucket non trouvé');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage
          .from(_productImagesBucket)
          .remove([filePath]);
    } catch (e) {
      throw StorageException('Erreur suppression photo produit: $e');
    }
  }

  /// Supprime un logo de magasin
  Future<void> deleteStoreLogo(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      final bucketIndex = pathSegments.indexOf(_storeLogosBucket);
      if (bucketIndex == -1) {
        throw StorageException('URL invalide: bucket non trouvé');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage
          .from(_storeLogosBucket)
          .remove([filePath]);
    } catch (e) {
      throw StorageException('Erreur suppression logo magasin: $e');
    }
  }

  /// Vérifie si un bucket existe et le crée si nécessaire
  ///
  /// À appeler au démarrage de l'app pour s'assurer que les buckets existent
  Future<void> ensureBucketsExist() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toSet();

      // Créer product-images si n'existe pas
      if (!bucketNames.contains(_productImagesBucket)) {
        await _supabase.storage.createBucket(
          _productImagesBucket,
          const BucketOptions(public: true),
        );
      }

      // Créer store-logos si n'existe pas
      if (!bucketNames.contains(_storeLogosBucket)) {
        await _supabase.storage.createBucket(
          _storeLogosBucket,
          const BucketOptions(public: true),
        );
      }
    } catch (e) {
      // Ignorer les erreurs si les buckets existent déjà
      // (Supabase retourne une erreur 409 si le bucket existe)
    }
  }
}

/// Exception personnalisée pour les erreurs de storage
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
