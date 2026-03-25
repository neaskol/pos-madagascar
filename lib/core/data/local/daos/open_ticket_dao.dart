import 'package:drift/drift.dart';
import '../app_database.dart';

part 'open_ticket_dao.g.dart';

/// DAO pour la table open_tickets
/// Gère les tickets ouverts / sauvegardés
@DriftAccessor(include: {'../tables/open_tickets.drift'})
class OpenTicketDao extends DatabaseAccessor<AppDatabase>
    with _$OpenTicketDaoMixin {
  OpenTicketDao(AppDatabase db) : super(db);

  /// Insère un ticket ouvert
  Future<int> insertOpenTicket(OpenTicketsCompanion ticket) =>
      into(openTickets).insert(ticket);

  /// Met à jour un ticket (items, nom, commentaire)
  Future<bool> updateOpenTicket(OpenTicketsCompanion ticket) async {
    final rowsAffected = await (update(openTickets)
          ..where((tbl) => tbl.id.equals(ticket.id.value)))
        .write(ticket.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Supprime un ticket ouvert (hard delete car non finalisé)
  Future<int> deleteOpenTicket(String id) =>
      (delete(openTickets)..where((tbl) => tbl.id.equals(id))).go();

  /// Marque un ticket comme synchronisé
  Future<bool> markOpenTicketSynced(String id) async {
    final rowsAffected = await (update(openTickets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const OpenTicketsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Stream pour écouter les tickets d'un magasin
  Stream<List<OpenTicket>> watchOpenTicketsByStore(String storeId) =>
      getOpenTicketsByStore(storeId).watch();

  /// Compte le nombre de tickets ouverts
  Future<int> countOpenTickets(String storeId) async {
    final tickets = await getOpenTicketsByStore(storeId).get();
    return tickets.length;
  }
}
