part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

/// Agency identity card at the top of Agency Center: brand gradient, logo,
/// name, ID, and (for the owner) Wallet / Edit shortcuts.
class _HeaderBody extends StatelessWidget {
  const _HeaderBody({required this.state});

  final InformationAgencyState state;

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          3.hBox,
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primary;
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Color.lerp(primary, Colors.black, .25)!],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: UserImage(
              image: state.data?.img ?? '',
              displayName: state.data?.name ?? '',
              borderRadius: BorderRadius.circular(12.r),
              imageSize: 58.w,
            ),
          ),
          12.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.data?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                5.hBox,
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: IdWithCopyIcon(
                    userId: state.data?.id.toString() ?? '',
                    isNeedCopyIcon: false,
                    idStyle: context.bodyMedium.w600
                        .size(11)
                        .colorExt(Colors.white),
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ),
              ],
            ),
          ),
          if (StringManager.userType[2]!) ...[
            8.wBox,
            // Same Wallet screen as Profile > Wallet, opened straight to the
            // Diamond tab (on request).
            _action(
              Icons.account_balance_wallet_rounded,
              'Wallet',
              () => context.pushNamedRoute(Routes.coinsPage, arguments: 1),
            ),
            10.wBox,
            _action(
              Icons.edit_rounded,
              'Edit',
              () => context.pushNamedRoute(Routes.updateHostAgencyScreen,
                  arguments: di<InformationAgencyBloc>().state.data),
            ),
          ],
        ],
      ),
    );
  }
}
