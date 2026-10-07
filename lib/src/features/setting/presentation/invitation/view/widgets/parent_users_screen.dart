import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/user_info_card.dart';

import '../../../../../../core/index.dart';

class ParentUsersScreen extends StatefulWidget {
  const ParentUsersScreen({
    super.key,
  });

  @override
  State<ParentUsersScreen> createState() => _ParentUsersScreenState();
}

class _ParentUsersScreenState extends State<ParentUsersScreen> {
  @override
  void initState() {
    super.initState();
    di<SendInviteBloc>().add(GetEarnInviteUserEvent());
  }

  void _refreshUsers() {
    di<SendInviteBloc>().add(GetEarnInviteUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: StringManager.invitation.tr(),
        backgroundGradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFC343),
            Color(0xFFFF7744),
            Color(0xFFFF375F),
          ],
        ),
        iconColor: Colors.white,
        shadow: const Color(0x22FF5A43),
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: ColoredBox(
        color: Colors.white,
        child: BlocBuilder<SendInviteBloc, SendInviteState>(
          bloc: di<SendInviteBloc>(),
          buildWhen: (prev, curr) =>
          prev.getInviteUserRequest != curr.getInviteUserRequest ||
              prev.getInviteUserSuccess != curr.getInviteUserSuccess,
          builder: (BuildContext context, SendInviteState state) {
            final users = state.getInviteUserSuccess ?? const [];

            return HandlingDataWidget(
              reqState: state.getInviteUserRequest,
              title: '',
              subTitle: '',
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshUsers();
                  await Future<void>.delayed(
                    const Duration(milliseconds: 450),
                  );
                },
                child: users.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 30.h,
                  ),
                  children: [
                    SizedBox(height: 70.h),
                    Container(
                      width: 92.w,
                      height: 92.w,
                      margin: EdgeInsets.symmetric(horizontal: 110.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4ED),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD7BE),
                        ),
                      ),
                      child: Icon(
                        Icons.group_add_rounded,
                        size: 42.h,
                        color: const Color(0xFFFF6B45),
                      ),
                    ),
                    20.hBox,
                    TextWidget(
                      StringManager.invitation.tr(),
                      textAlign: TextAlign.center,
                      style: context.bodyLarge
                          .size(19)
                          .bold
                          .colorExt(Colors.black),
                    ),
                    8.hBox,
                    TextWidget(
                      StringManager.totalInvited.tr(),
                      textAlign: TextAlign.center,
                      style: context.bodyMedium
                          .size(14)
                          .colorExt(
                        Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                )
                    : ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    14.w,
                    16.h,
                    14.w,
                    24.h,
                  ),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => 10.hBox,
                  itemBuilder: (context, i) {
                    return UserDetailsForParent(
                      data: users[i],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
