import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/group_repository.dart';
import '../../domain/models/group_model.dart';

// EVENTS
abstract class GroupEvent extends Equatable {
  const GroupEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroupsEvent extends GroupEvent {}

class CreateGroupEvent extends GroupEvent {
  final String name;
  final String category;
  final String iconName;
  final String createdBy;
  final String? description;
  final List<GroupMemberModel> members;

  const CreateGroupEvent({
    required this.name,
    required this.category,
    required this.iconName,
    required this.createdBy,
    this.description,
    required this.members,
  });

  @override
  List<Object?> get props => [name, category, iconName, createdBy, description, members];
}

class SelectGroupEvent extends GroupEvent {
  final String groupId;
  const SelectGroupEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

// STATES
abstract class GroupState extends Equatable {
  const GroupState();
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  final GroupModel? selectedGroup;

  const GroupLoaded({required this.groups, this.selectedGroup});

  double get totalDebt => groups.fold<double>(0, (sum, g) => sum + g.userDebt);
  double get totalCredit => groups.fold<double>(0, (sum, g) => sum + g.userCredit);
  int get debtCount => groups.where((g) => g.userDebt > 0).length;
  int get creditCount => groups.where((g) => g.userCredit > 0).length;

  GroupLoaded copyWith({
    List<GroupModel>? groups,
    GroupModel? selectedGroup,
  }) {
    return GroupLoaded(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
    );
  }

  @override
  List<Object?> get props => [groups, selectedGroup];
}

class GroupError extends GroupState {
  final String message;
  const GroupError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository groupRepository;

  GroupBloc({required this.groupRepository})
      : super(GroupInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<SelectGroupEvent>(_onSelectGroup);
  }

  Future<void> _onLoadGroups(LoadGroupsEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      final groups = await groupRepository.getGroups();
      emit(GroupLoaded(groups: groups));
    } catch (e) {
      emit(GroupError('Gagal memuat grup: ${e.toString()}'));
    }
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<GroupState> emit) async {
    try {
      final newGroup = await groupRepository.createGroup(
        name: event.name,
        category: event.category,
        iconName: event.iconName,
        createdBy: event.createdBy,
        description: event.description,
        members: event.members,
      );

      final currentGroups = state is GroupLoaded ? (state as GroupLoaded).groups : <GroupModel>[];
      final updated = [newGroup, ...currentGroups];
      emit(GroupLoaded(groups: updated, selectedGroup: newGroup));
    } catch (e) {
      emit(GroupError('Gagal membuat grup: ${e.toString()}'));
    }
  }

  Future<void> _onSelectGroup(SelectGroupEvent event, Emitter<GroupState> emit) async {
    if (state is GroupLoaded) {
      final currentState = state as GroupLoaded;
      final group = currentState.groups.firstWhere(
        (g) => g.id == event.groupId,
        orElse: () => currentState.groups.first,
      );
      emit(currentState.copyWith(selectedGroup: group));
    }
  }
}
