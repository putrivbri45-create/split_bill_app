import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_repository.dart';
import '../../domain/models/expense_model.dart';

// EVENTS
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroupExpensesEvent extends ExpenseEvent {
  final String groupId;
  const LoadGroupExpensesEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class LoadAllExpensesEvent extends ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseModel expense;
  const AddExpenseEvent(this.expense);
  @override
  List<Object?> get props => [expense];
}

// STATES
abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String? activeGroupId;

  const ExpenseLoaded({required this.expenses, this.activeGroupId});

  double get totalGroupSpending => expenses.fold<double>(0, (sum, e) => sum + e.totalAmount);

  ExpenseLoaded copyWith({
    List<ExpenseModel>? expenses,
    String? activeGroupId,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      activeGroupId: activeGroupId ?? this.activeGroupId,
    );
  }

  @override
  List<Object?> get props => [expenses, activeGroupId];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository})
      : super(ExpenseInitial()) {
    on<LoadGroupExpensesEvent>(_onLoadGroupExpenses);
    on<LoadAllExpensesEvent>(_onLoadAllExpenses);
    on<AddExpenseEvent>(_onAddExpense);
  }

  Future<void> _onLoadGroupExpenses(LoadGroupExpensesEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseRepository.getExpensesByGroup(event.groupId);
      emit(ExpenseLoaded(expenses: expenses, activeGroupId: event.groupId));
    } catch (e) {
      emit(ExpenseError('Gagal memuat pengeluaran: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllExpenses(LoadAllExpensesEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseRepository.getAllExpenses();
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError('Gagal memuat semua pengeluaran: ${e.toString()}'));
    }
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      final newExpense = await expenseRepository.addExpense(event.expense);
      final currentExpenses = state is ExpenseLoaded ? (state as ExpenseLoaded).expenses : <ExpenseModel>[];
      final currentGroup = state is ExpenseLoaded ? (state as ExpenseLoaded).activeGroupId : null;
      
      final updated = [newExpense, ...currentExpenses];
      emit(ExpenseLoaded(expenses: updated, activeGroupId: currentGroup));
    } catch (e) {
      emit(ExpenseError('Gagal menambahkan pengeluaran: ${e.toString()}'));
    }
  }
}
