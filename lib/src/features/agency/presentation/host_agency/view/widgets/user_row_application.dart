part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class UserRowApplication extends StatelessWidget {
  const UserRowApplication({super.key, required this.userDataModel});

  final ShowAgencyRequestModel userDataModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
          context: context,
          userId: userDataModel.id.toString(),
        );
      },
      child: Container(
        padding: context.paddingOnly(start: 10, top: 5, bottom: 5, end: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                UserImage(
                  image: userDataModel.profile?.image ?? '',
                  displayName: userDataModel.name ?? '',
                  imageSize: 50.w,
                ),
                10.wBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ScreenUtil().screenWidth * 0.3,
                      child: TextWidget(
                        userDataModel.name!,
                        style: context.bodyMedium.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextWidget('ID: ${userDataModel.uuid}'),
                  ],
                ),
              ],
            ),
            const Spacer(),
            BlocBuilder<AgencyRequestsActionBloc, AgencyRequestsActionState>(
              bloc: di<AgencyRequestsActionBloc>(),
              buildWhen: (prev, curr) => prev.state != curr.state,
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ButtonWidget(
                      onPressed: () {
                        if (!state.state.isLoading) {
                          di<AgencyRequestsActionBloc>().add(
                            AgencyRequestsActionEvent(
                              accept: true,
                              userId: userDataModel.id.toString(),
                            ),
                          );
                        }
                      },
                      title: StringManager.accept.tr(),
                      padding: context.paddingAll(0),
                      paddingButton: context.paddingAll(0),
                      fontSize: 12,
                      isFittedBox: false,
                      fontWeight: FontWeight.w400,
                      width: 60.w,
                      height: 25.h,
                      backgroundColor: ColorManager.primary,
                      radius: 30,
                      isLoading: state.state.isLoading,
                    ),
                    15.wBox,
                    ButtonWidget(
                      onPressed: () {
                        if (!state.state.isLoading) {
                          di<AgencyRequestsActionBloc>().add(
                            AgencyRequestsActionEvent(
                              accept: false,
                              userId: userDataModel.id.toString(),
                            ),
                          );
                        }
                      },
                      title: StringManager.refuse.tr(),
                      padding: context.paddingAll(0),
                      paddingButton: context.paddingAll(0),
                      fontSize: 12,
                      isFittedBox: false,
                      fontWeight: FontWeight.w400,
                      titleColor: ColorManager.secondaryText,
                      width: 60.w,
                      height: 25.h,
                      backgroundColor: ColorManager.lightGrey,
                      radius: 30,
                      isLoading: state.state.isLoading,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
