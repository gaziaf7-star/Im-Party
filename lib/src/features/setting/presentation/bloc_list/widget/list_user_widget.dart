import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_event.dart';

import '../../../../../core/widgets/user_info_row.dart';

class ListUserWidget extends StatelessWidget {
  const ListUserWidget({super.key, required this.users});

  final List<UserEntity> users;
  @override
  Widget build(BuildContext context) {
    return users.isEmpty
        ? const Align(
            alignment: AlignmentDirectional.center,
            child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), child: SizedBox()),
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: users.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return UserInfoRow(
                padding: context.paddingSymmetric(horizontal: 5,vertical: 10),
                margin: context.paddingSymmetric(horizontal: 5),
                user: users[index],
                endIcon: ButtonWidget(
                  onPressed: () {
                    di<AddOrRemoveBlock>().add(
                      DeleteBlockListEvent(
                        context,
                        userId: users[index].id.toString(),
                      ),
                    );
                  },
                  width: 100.w,
                  padding: context.paddingZero(),
                  paddingButton: context.paddingSymmetric(horizontal: 10,vertical: 6),
                  height: 35.h,
                  fontSize: 15,
                  backgroundColor: ColorManager.primary,
                  fontWeight: FontWeight.w600,
                  title: StringManager.remove.tr(),
                ),
                select: () {},
              );
            },
          );
  }
}
