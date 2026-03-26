import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/refund_repository.dart';
import 'refund_event.dart';
import 'refund_state.dart';

class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final RefundRepository repository;

  RefundBloc({required this.repository}) : super(RefundInitial()) {
    on<LoadRefunds>(_onLoadRefunds);
    on<LoadRefundsBySale>(_onLoadRefundsBySale);
    on<CreateRefund>(_onCreateRefund);
    on<CheckSaleRefunded>(_onCheckSaleRefunded);
  }

  Future<void> _onLoadRefunds(
    LoadRefunds event,
    Emitter<RefundState> emit,
  ) async {
    try {
      emit(RefundLoading());

      // Écouter le stream des remboursements
      await emit.forEach(
        repository.watchRefundsByStore(event.storeId),
        onData: (refunds) => RefundLoaded(refunds: refunds),
        onError: (error, stackTrace) => RefundError(error.toString()),
      );
    } catch (e) {
      emit(RefundError('Erreur chargement remboursements: $e'));
    }
  }

  Future<void> _onLoadRefundsBySale(
    LoadRefundsBySale event,
    Emitter<RefundState> emit,
  ) async {
    try {
      emit(RefundLoading());

      final refunds = await repository.getRefundsBySale(event.saleId);
      final isRefunded = refunds.isNotEmpty;

      emit(RefundLoaded(
        refunds: refunds,
        isSaleRefunded: isRefunded,
      ));
    } catch (e) {
      emit(RefundError('Erreur chargement remboursements: $e'));
    }
  }

  Future<void> _onCreateRefund(
    CreateRefund event,
    Emitter<RefundState> emit,
  ) async {
    try {
      emit(RefundLoading());

      // Vérifier si déjà remboursé
      final alreadyRefunded = await repository.isSaleRefunded(event.saleId);
      if (alreadyRefunded) {
        emit(const RefundError('Cette vente a déjà été remboursée'));
        return;
      }

      // Créer le remboursement
      final refundId = await repository.createRefund(
        saleId: event.saleId,
        storeId: event.storeId,
        employeeId: event.employeeId,
        items: event.items,
        reason: event.reason,
      );

      emit(RefundCreated(refundId));
    } catch (e) {
      emit(RefundError('Erreur création remboursement: $e'));
    }
  }

  Future<void> _onCheckSaleRefunded(
    CheckSaleRefunded event,
    Emitter<RefundState> emit,
  ) async {
    try {
      final isRefunded = await repository.isSaleRefunded(event.saleId);

      if (state is RefundLoaded) {
        emit((state as RefundLoaded).copyWith(isSaleRefunded: isRefunded));
      } else {
        emit(RefundLoaded(refunds: const [], isSaleRefunded: isRefunded));
      }
    } catch (e) {
      emit(RefundError('Erreur vérification remboursement: $e'));
    }
  }
}
