part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class CommunicationButtonBody extends StatelessWidget {
  const CommunicationButtonBody(
      {super.key, required this.data, this.isFromSearchScreens});

  final bool? isFromSearchScreens;
  final ShippingAgentsFullDataEntity data;

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      onPressed: () {
        Methods().isFriends(
          userEntity: UserEntity(
            name: data.ownerName,
            id: data.ownerId,
            isFriend: true,
            profile: ProfileRoomEntity(
              image: data.ownerImage,
            ),
          ),
          context: context,
        );
      },
      title: StringManager.chat.tr(),
      padding: context.paddingSymmetric(vertical: 2),
      paddingButton: context.paddingZero(),
      // width: ScreenUtil().screenWidth * 0.27,
      height: ScreenUtil().screenHeight * 0.035,
      radius: 20.r,
      backgroundColor: ColorManager.transparent,
      borderColor: ColorManager.primary,
      titleColor: ColorManager.primary,
      isFittedBox: false,
      fontSize: 9,
    );
  }
}
