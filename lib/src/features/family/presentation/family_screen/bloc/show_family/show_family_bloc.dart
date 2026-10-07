import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'show_family_event.dart';

part 'show_family_state.dart';

class ShowFamilyBloc extends Bloc<BaseShowFamilyEvent, ShowFamilyState> {
  ShowFamilyUC showFamilyUseCase;

  ShowFamilyBloc({required this.showFamilyUseCase})
      : super(const ShowFamilyState()) {
    on<ShowFamilyEvent>((event, emit) async {
      final result = await showFamilyUseCase(event.familyId);
      result.fold(
        (left) => emit(state.copyWith(
            message: NetworkExceptions.getErrorMessage(left),
            reqState: handleErrorResponse(left))),
        (right) => emit(
          state.copyWith(
            showFamilyEntity: right.data!,
            reqState: handleLoadedResponse<ShowFamilyModel>(right.data),
          ),
        ),
      );
    });
    on<EditFamilyLocallyEvent>((event, emit) async {
      emit(state.copyWith(showFamilyEntity: event.familyParameter));
    });
    on<EditFamilyLocallyDeleteMemberCountLocallyEvent>((event, emit) async {
      final int updatedCount = (state.showFamilyEntity?.numOfMembers ?? 1) - 1;
      final int updatedNumOfRequests =
          (state.showFamilyEntity?.numOfRequests ?? 0) - 1;

      final MemberFamilyEntity? user =
          state.showFamilyEntity?.members?.firstWhere(
        (element) => element.id.toString() == event.userId,
      );

      final List<MemberFamilyEntity> updatedList =
          List.from(state.showFamilyEntity?.members ?? [])..remove(user);

      final ShowFamilyEntity showFamilyEntityUpdated = state.showFamilyEntity!
          .copyWith(
              numOfMembers: updatedCount,
              members: updatedList,
              numOfRequests: updatedNumOfRequests<0?0:updatedNumOfRequests);

      emit(state.copyWith(showFamilyEntity: showFamilyEntityUpdated));
    });
    on<EditFamilyLocallyAcceptRequestLocallyEvent>((event, emit) async {
      final int updatedCount = (state.showFamilyEntity?.numOfMembers ?? 0) + 1;
      final int updatedNumOfRequests =
          (state.showFamilyEntity?.numOfRequests ?? 0) - 1;

      final List<MemberFamilyEntity> updatedMembers =
          List.from(state.showFamilyEntity?.members ?? []);
      updatedMembers.insert(0, event.userMember!);

      final ShowFamilyEntity? showFamilyEntityUpdated = state.showFamilyEntity
          ?.copyWith(
              numOfMembers: updatedCount,
              members: updatedMembers,
              numOfRequests: updatedNumOfRequests<0?0:updatedNumOfRequests);

      if (showFamilyEntityUpdated != null) {
        emit(state.copyWith(showFamilyEntity: showFamilyEntityUpdated));
      }
    });
    on<EditFamilyLocallyChangeUserTypeLocallyEvent>(
      (event, emit) async {
        final List<MemberFamilyEntity> updatedMembers =
            List.of(state.showFamilyEntity?.members ?? []);

        final MemberFamilyEntity user = updatedMembers.firstWhere((element) {
          return element.id.toString() == event.userId;
        });

        final updatedUser = user.copyWith(
          isFamilyAdmin: event.type == '1' ? true : false,
        );
        final userIndex = updatedMembers.indexWhere(
          (element) => element.id.toString() == event.userId,
        );
        if (userIndex != -1) {
          updatedMembers[userIndex] = updatedUser;
        }
        emit(
          state.copyWith(
            showFamilyEntity:
                state.showFamilyEntity?.copyWith(members: updatedMembers),
          ),
        );
      },
    );
  }
}
