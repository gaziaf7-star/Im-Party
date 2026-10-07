part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class _HeaderBody extends StatelessWidget {
  const _HeaderBody({required this.state});

  final InformationAgencyState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserImage(
                image: state.data?.img ?? '',
                displayName: state.data?.name ?? '',
                borderRadius: 5.radius,
                imageSize: 65.w,
              ),
              15.wBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ScreenUtil().screenWidth * 0.45,
                    child: Text(
                      state.data?.name ?? '',
                      style: context.bodyMedium.w600.size(14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IdWithCopyIcon(
                    userId: state.data?.id.toString() ?? '',
                    isNeedCopyIcon: false,
                    idStyle: context.bodyMedium.w500.size(10),
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ],
              ),
              const Spacer(),
              if (StringManager.userType[2]!) ...[
                IconButton(
                  onPressed: () {
                    // Same Wallet screen as Profile > Wallet, opened
                    // straight to the Diamond tab (was Routes.withDrawScreen,
                    // a different withdrawal-only screen), on request.
                    context.pushNamedRoute(
                      Routes.coinsPage,
                      arguments: 1,
                    );
                  },
                  icon: Image.asset(
                    AssetsManager.agencyWallet,
                    color: ColorManager.textPrimary,
                    scale: 20,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.pushNamedRoute(Routes.updateHostAgencyScreen,
                        arguments: di<InformationAgencyBloc>().state.data);
                  },
                  icon: Icon(
                    CupertinoIcons.pencil,
                    color: ColorManager.textPrimary,
                  ),
                ),
              ]
            ],
          ),
          10.hBox,
        ],
      ),
    );
  }
}
