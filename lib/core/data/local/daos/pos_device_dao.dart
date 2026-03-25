import 'package:drift/drift.dart';
import '../app_database.dart';

part 'pos_device_dao.g.dart';

/// DAO pour la table pos_devices
/// Gère les appareils POS / caisses enregistreuses
@DriftAccessor(include: {'../tables/pos_devices.drift'})
class PosDeviceDao extends DatabaseAccessor<AppDatabase>
    with _$PosDeviceDaoMixin {
  PosDeviceDao(AppDatabase db) : super(db);

  /// Insère un appareil POS
  Future<int> insertPosDevice(PosDevicesCompanion device) =>
      into(posDevices).insert(device);

  /// Met à jour un appareil POS
  Future<bool> updatePosDevice(PosDevicesCompanion device) async {
    final rowsAffected = await (update(posDevices)
          ..where((tbl) => tbl.id.equals(device.id.value)))
        .write(device.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Met à jour le timestamp last_seen_at
  Future<bool> updateLastSeen(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowsAffected = await (update(posDevices)
          ..where((tbl) => tbl.id.equals(id)))
        .write(PosDevicesCompanion(
      lastSeenAt: Value(now),
      synced: const Value(0),
      updatedAt: Value(now),
    ));
    return rowsAffected > 0;
  }

  /// Désactive un appareil POS
  Future<bool> deactivatePosDevice(String id) async {
    final rowsAffected = await (update(posDevices)
          ..where((tbl) => tbl.id.equals(id)))
        .write(PosDevicesCompanion(
      active: const Value(0),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Marque comme synchronisé
  Future<bool> markPosDeviceSynced(String id) async {
    final rowsAffected = await (update(posDevices)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const PosDevicesCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Stream pour écouter les appareils d'un magasin
  Stream<List<PosDevice>> watchPosDevicesByStore(String storeId) =>
      getPosDevicesByStore(storeId).watch();
}
