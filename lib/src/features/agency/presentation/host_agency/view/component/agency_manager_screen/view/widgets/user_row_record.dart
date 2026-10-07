part of'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';
class UserRowRecord extends StatelessWidget {
  const UserRowRecord({super.key, required this.userDataModel});

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
        padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
        child: Row(
         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserImage(
              image: userDataModel.profile?.image ?? '',
              displayName: userDataModel.name ?? '',
              imageSize: 50,
            ),
            5.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150.w,
                  child: TextWidget(
                    '${userDataModel.name ?? ''} (ID: ${userDataModel.uuid})',
                    style: context.bodyMedium.bold
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: ScreenUtil().screenWidth * 0.25,
                      child: TextWidget(
                        userDataModel.date ?? '',
                        style: context.bodyMedium.size(12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil().screenWidth * 0.33,
                      child: TextWidget(
                        StringManager.operator.tr() + (userDataModel.operator ?? ''),
                        style: context.bodyMedium.size(12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            TextWidget(userDataModel.status==1?StringManager.agreed.tr():StringManager.rejected.tr()),
          ],
        ),
      ),
    );
  }
}
