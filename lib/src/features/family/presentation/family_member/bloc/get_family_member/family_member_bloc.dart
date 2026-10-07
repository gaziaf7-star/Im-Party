
import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'family_member_event.dart';
part 'family_member_state.dart';

class FamilyMemberBloc extends Bloc<FamilyMemberEvent, FamilyMemberState> {
  final GetFamilyMemberUC getFamilyMember;
  bool isLoadingMore = false;
  List<MemberFamilyEntity>? membersTemp;

  FamilyMemberBloc({required this.getFamilyMember})
      : super(const FamilyMemberState()) {
    on<GetFamilyMemberEvent>(
      (event, emit) async {
        if (membersTemp == null) {
          emit(state.copyWith(reqState: RequestState.loading));
        }
        final result = await getFamilyMember(FamilyParameter(
          id: event.familyId,
        )); //event.familyId, null

        result.fold(
          (left) => emit(
            state.copyWith(
                errorMsg: NetworkExceptions.getErrorMessage(left),
                reqState: handleErrorResponse(left)),
          ),
          (right) {
            membersTemp =
                (right.data?.admin ?? []) + (right.data?.members ?? []);
            emit(state.copyWith(
                data: right.data,
                reqState:
                    handleLoadedResponse<AllFamilyMemberEntity>(right.data)));
          },
        );
      },
    );

    on<GetMoreFamilyMemberEvent>(
      (event, emit) async {
        isLoadingMore = true;
        emit(state.copyWith(data: state.data));
        final result = await getFamilyMember(
            FamilyParameter(id: event.familyId, page: event.page));

        result.fold(
          (left) {
            isLoadingMore = false;
            emit(
              state.copyWith(errorMsg: NetworkExceptions.getErrorMessage(left)),
            );
          },
          (right) {
            // isLoadingMore = false;
            // membersTemp = membersTemp!.members + (right.data.members ?? []);
            // emit(state.copyWith(data: membersTemp+=));
          },
        );
      },
    );

    on<LocalRemoveFamilyUserEvent>((event, emit) async {
      final List<MemberFamilyEntity> updatedMembers =
          List.of(state.data?.members??[])
            ..removeWhere(
                (element) => element.id.toString().toString() == event.userId);

      final List<MemberFamilyEntity> updatedAdmins = List.of(state.data?.admin??[])
        ..removeWhere(
            (element) => element.id.toString().toString() == event.userId);

      emit(state.copyWith(
        data: state.data?.copyWith(
          members: updatedMembers,
          admin: updatedAdmins,
        ),
      ));
    });

    on<LocalChangeUserTypeUserEvent>((event, emit) async {

      // Make copies of the current lists to avoid direct mutation
      final List<MemberFamilyEntity> updatedMembers =
          List.of(state.data?.members ?? []);
      final List<MemberFamilyEntity> updatedAdmins =
          List.of(state.data?.admin ?? []);

      if (event.type == '1') {
        _addAdmin(updatedMembers, updatedAdmins, event.userId);
      } else if (event.type == '0') {
        _removeAdmin(updatedMembers, updatedAdmins, event.userId);
      }

      // Emit the updated state with the modified members and admin lists
      emit(state.copyWith(
        data: state.data?.copyWith(
          members: updatedMembers,
          admin: updatedAdmins,
        ),
      ));
    });

    on<LocalAddFamilyUserEvent>((event, emit) async {
      // Create a new list from the existing members and add the new user at the start
      final List<MemberFamilyEntity> updatedMembers = List.from(state.data?.members ?? []);
      updatedMembers.insert(0, event.user);

      // Emit the updated state with the modified members list
      emit(state.copyWith(
        data: state.data?.copyWith(
          members: updatedMembers,
        ),
      ));
    });
  }

// Helper function to add a user to the admin list
  void _addAdmin(List<MemberFamilyEntity> members,
      List<MemberFamilyEntity> admins, String userId) {
    final MemberFamilyEntity user =
        members.firstWhere((element) => element.id.toString() == userId);
    final MemberFamilyEntity updatedUser = user.copyWith(familyStatus: 1);


    members.remove(user);
    admins.add(updatedUser);

  }

// Helper function to remove a user from the admin list
  void _removeAdmin(List<MemberFamilyEntity> members,
      List<MemberFamilyEntity> admins, String userId) {
    final MemberFamilyEntity user =
        admins.firstWhere((element) => element.id.toString() == userId);
    final MemberFamilyEntity updatedUser = user.copyWith(familyStatus: 0);


    admins.remove(user);
    members.add(updatedUser);

  }
}
