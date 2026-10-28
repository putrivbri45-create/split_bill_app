import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settlement_repository.dart';
import '../../domain/models/settlement_model.dart';
import '../../../../core/algorithm/debt_simplifier.dart';

// EVENTS
abstract class SettlementEvent extends Equatable {
  const SettlementEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettlementsEvent extends SettlementEvent {
  final String groupId;
  const LoadSettlementsEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class LoadAllSettlementsEvent extends SettlementEvent {}

class RecordSettlementEvent extends SettlementEvent {
  final SettlementModel settlement;
  const RecordSettlementEvent(this.settlement);
  @override
  List<Object?> get props => [settlement];
}

class SimplifyDebtsEvent extends SettlementEvent {
  final Map<String, double> netBalances;
  final Map<String, String>? userNames;
  const SimplifyDebtsEvent({required this.netBalances, this.userNames});
  @override
  List<Object?> get props => [netBalances, userNames];
}

// STATES
abstract class SettlementState extends Equatable {
  const SettlementState();
  @override
  List<Object?> get props => [];
}

class SettlementInitial extends SettlementState {}

class SettlementLoading extends SettlementState {}

class SettlementLoaded extends SettlementState {
  final List<SettlementModel> settlements;
  final List<SimplifiedDebt> simplifiedDebts;
  final String? activeGroupId;

  const SettlementLoaded({
    required this.settlements,
    this.simplifiedDebts = const [],
    this.activeGroupId,
  });

  SettlementLoaded copyWith({
    List<SettlementModel>? settlements,
    List<SimplifiedDebt>? simplifiedDebts,
    String? activeGroupId,
  }) {
    return SettlementLoaded(
      settlements: settlements ?? this.settlements,
      simplifiedDebts: simplifiedDebts ?? this.simplifiedDebts,
      activeGroupId: activeGroupId ?? this.activeGroupId,
    );
  }

  @override
  List<Object?> get props => [settlements, simplifiedDebts, activeGroupId];
}

class SettlementError extends SettlementState {
  final String message;
  const SettlementError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;

  SettlementBloc({required this.settlementRepository})
      : super(SettlementInitial()) {
    on<LoadSettlementsEvent>(_onLoadSettlements);
    on<LoadAllSettlementsEvent>(_onLoadAllSettlements);
    on<RecordSettlementEvent>(_onRecordSettlement);
    on<SimplifyDebtsEvent>(_onSimplifyDebts);
  }

  Future<void> _onLoadSettlements(LoadSettlementsEvent event, Emitter<SettlementState> emit) async {
    emit(SettlementLoading());
    try {
      final settlements = await settlementRepository.getSettlementsByGroup(event.groupId);
      emit(SettlementLoaded(settlements: settlements, activeGroupId: event.groupId));
    } catch (e) {
      emit(SettlementError('Gagal memuat penyelesaian tagihan: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllSettlements(LoadAllSettlementsEvent event, Emitter<SettlementState> emit) async {
    emit(SettlementLoading());
    try {
      final settlements = await settlementRepository.getAllSettlements();
      emit(SettlementLoaded(settlements: settlements));
    } catch (e) {
      emit(SettlementError('Gagal memuat histori: ${e.toString()}'));
    }
  }

  Future<void> _onRecordSettlement(RecordSettlementEvent event, Emitter<SettlementState> emit) async {
    try {
      final recorded = await settlementRepository.recordSettlement(event.settlement);
      if (state is SettlementLoaded) {
        final current = state as SettlementLoaded;
        final updatedList = [recorded, ...current.settlements.where((s) => s.id != recorded.id)];
        
        // Update simplifiedDebts if any match
        final updatedSimplified = current.simplifiedDebts.map((d) {
          if (d.debtorId == recorded.debtorId && d.creditorId == recorded.creditorId) {
            return d.copyWith(isSettled: true);
          }
          return d;
        }).toList();

        emit(current.copyWith(settlements: updatedList, simplifiedDebts: updatedSimplified));
      }
    } catch (e) {
      emit(SettlementError('Gagal mencatat penyelesaian: ${e.toString()}'));
    }
  }

  Future<void> _onSimplifyDebts(SimplifyDebtsEvent event, Emitter<SettlementState> emit) async {
    try {
      final simplified = DebtSimplifier.simplify(
        netBalances: event.netBalances,
        userNames: event.userNames,
      );
      if (state is SettlementLoaded) {
        final current = state as SettlementLoaded;
        emit(current.copyWith(simplifiedDebts: simplified));
      } else {
        emit(SettlementLoaded(settlements: const [], simplifiedDebts: simplified));
      }
    } catch (e) {
      emit(SettlementError('Gagal menyederhanakan utang: ${e.toString()}'));
    }
  }
}
