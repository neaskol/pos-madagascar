import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sale_repository.dart';
import 'sale_event.dart';
import 'sale_state.dart';

/// BLoC pour la gestion des ventes (paiements et historique)
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRepository saleRepository;

  SaleBloc(this.saleRepository) : super(const SaleInitial()) {
    on<CreateSaleEvent>(_onCreateSale);
    on<LoadSalesEvent>(_onLoadSales);
    on<LoadSaleByIdEvent>(_onLoadSaleById);
  }

  Future<void> _onCreateSale(
    CreateSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleCreating());

    try {
      final sale = await saleRepository.createSale(
        storeId: event.storeId,
        employeeId: event.employeeId,
        items: event.items,
        subtotal: event.subtotal,
        taxAmount: event.taxAmount,
        discountAmount: event.discountAmount,
        total: event.total,
        // Single payment (rétrocompatibilité)
        paymentType: event.paymentType,
        amountReceived: event.amountReceived,
        paymentReference: event.paymentReference,
        // Multi-payment (nouveau)
        payments: event.payments,
        customerId: event.customerId,
        note: event.note,
      );

      emit(SaleCreated(sale));
    } catch (e) {
      emit(SaleError('Erreur lors de la création de la vente: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSales(
    LoadSalesEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SalesLoading());

    try {
      final sales = await saleRepository.getSales(
        storeId: event.storeId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SaleError(
          'Erreur lors du chargement des ventes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSaleById(
    LoadSaleByIdEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SalesLoading());

    try {
      final sale = await saleRepository.getSaleById(event.saleId);

      if (sale != null) {
        emit(SaleLoaded(sale));
      } else {
        emit(const SaleError('Vente introuvable'));
      }
    } catch (e) {
      emit(SaleError(
          'Erreur lors du chargement de la vente: ${e.toString()}'));
    }
  }
}
