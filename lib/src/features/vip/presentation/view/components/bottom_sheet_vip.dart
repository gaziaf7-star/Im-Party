import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/user_info_row.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';

class BottomSheetVip extends StatelessWidget {
  final int vipId;

  const BottomSheetVip({super.key, required this.vipId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchStates>(
      bloc: di<SearchBloc>(),
      buildWhen: (prev, curr) => prev.data != curr.data || prev.selectedUserId != curr.selectedUserId,
      builder: (context, state) {
        return Container(
          height: 500.h,
          padding: context.paddingSymmetric(horizontal: 10),
          width: double.infinity,
          color: ColorManager.vipDialogGray,
          child: ListView.separated(
            shrinkWrap: true,
            padding: context.paddingOnly(top: 10, bottom: 10),
            itemCount: state.data?.users.length ?? 0,
            itemBuilder: (context, index) {
                if (state.data?.users.isNotEmpty == true) {
                  return UserInfoRow(
                    isUserVip: state.data?.users[index].uuid ==
                        state.selectedUserId
                        ? true
                        : false,
                    select: () {
                      di<SearchBloc>().add(UserSelectedEvent(
                          state.data!.users[index].uuid ??
                              ''));
                      Navigator.pop(context);
                    },
                    user: state.data!.users[index],
                    endIcon: const Icon(
                      Icons.arrow_forward_ios,
                      color: ColorManager.white,
                    ),
                  );
                }

              return TextWidget(StringManager.notFoundUsers.tr());
            },
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: context.paddingSymmetric(vertical: 15),
                child: Image.asset(AssetsManager.line),
              );
            },
          ),
        );
      },
    );
  }
}
