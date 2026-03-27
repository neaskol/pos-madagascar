import 'package:drift/drift.dart';
import '../app_database.dart';

part 'shift_dao.g.dart';

/// DAO pour les tables shifts et cash_movements
/// Gère les shifts de caisse et mouvements de caisse
@DriftAccessor(include: {
  '../tables/shifts.drift',
  '../tables/cash_movements.drift',
})
class ShiftDao extends DatabaseAccessor<AppDatabase> with _$ShiftDaoMixin {
  ShiftDao(AppDatabase db) : super(db);

  // ─── SHIFTS ───────────────────────────────────────────

  /// Ouvre un nouveau shift
  Future<int> openShift(ShiftsCompanion shift) =>
      into(shifts).insert(shift);

  /// Ferme un shift avec les montants finaux
  Future<bool> closeShift({
    required String id,
    required int actualCash,
    required int expectedCash,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowsAffected = await (update(shifts)
          ..where((tbl) => tbl.id.equals(id)))
        .write(ShiftsCompanion(
      status: const Value('closed'),
      closedAt: Value(now),
      actualCash: Value(actualCash),
      expectedCash: Value(expectedCash),
      cashDifference: Value(actualCash - expectedCash),
      synced: const Value(0),
      updatedAt: Value(now),
    ));
    return rowsAffected > 0;
  }

  /// Met à jour le cash attendu d'un shift
  Future<bool> updateExpectedCash(String id, int expectedCash) async {
    final rowsAffected = await (update(shifts)
          ..where((tbl) => tbl.id.equals(id)))
        .write(ShiftsCompanion(
      expectedCash: Value(expectedCash),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Marque un shift comme synchronisé
  Future<bool> markShiftSynced(String id) async {
    final rowsAffected = await (update(shifts)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const ShiftsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Stream pour écouter le shift ouvert actuel
  Stream<Shift?> watchOpenShift(String storeId) =>
      getOpenShift(storeId).watchSingleOrNull();

  /// Stream pour écouter les shifts d'un magasin
  Stream<List<Shift>> watchShiftsByStore(String storeId) =>
      getShiftsByStore(storeId).watch();

  // ─── CASH MOVEMENTS ──────────────────────────────────

  /// Insère un mouvement de caisse (pay in / pay out)
  Future<int> insertCashMovement(CashMovementsCompanion movement) =>
      into(cashMovements).insert(movement);

  /// Marque un mouvement comme synchronisé
  Future<bool> markCashMovementSynced(String id) async {
    final rowsAffected = await (update(cashMovements)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const CashMovementsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Stream pour écouter les mouvements d'un shift
  Stream<List<CashMovement>> watchCashMovementsByShift(String shiftId) =>
      getCashMovementsByShift(shiftId).watch();

  /// Total des pay_in et pay_out d'un shift
  Future<({int payIn, int payOut})> getShiftMovementTotals(String shiftId) async {
    final movements = await getCashMovementsByShift(shiftId).get();
    int payIn = 0;
    int payOut = 0;
    for (final m in movements) {
      if (m.type == 'pay_in') {
        payIn += m.amount;
      } else {
        payOut += m.amount;
      }
    }
    return (payIn: payIn, payOut: payOut);
  }

  // ─── UPSERT (SYNC) ────────────────────────────────────

  /// Upsert (insert ou update) un shift depuis Supabase
  Future<void> upsertShift(ShiftsCompanion shift) async {
    await into(shifts).insertOnConflictUpdate(shift);
  }

  /// Upsert un cash_movement depuis Supabase
  Future<void> upsertCashMovement(CashMovementsCompanion movement) async {
    await into(cashMovements).insertOnConflictUpdate(movement);
  }
}
