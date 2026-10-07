part of '../coin_seller_screen.dart';

class CoinSellerBalanceCard extends StatelessWidget {
  const CoinSellerBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _coinSellerGradient,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: _coinSellerPurple.withValues(alpha: 0.24),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: BlocBuilder<CoinSellerBloc, CoinSellerState>(
        bloc: di<CoinSellerBloc>(),
        buildWhen: (prev, curr) =>
        prev.profile != curr.profile ||
            prev.reqStateProfile != curr.reqStateProfile,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Image.asset(
                      'assets/icons/coinSeller.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 24.h,
                      ),
                    ),
                  ),
                  11.wBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          StringManager.sellerBalance,
                          isTranslate: false,
                          style: context.bodyMedium
                              .size(12)
                              .w600
                              .colorExt(
                            Colors.white.withValues(alpha: 0.80),
                          ),
                        ),
                        3.hBox,
                        if (state.reqStateProfile.isLoading)
                          SizedBox(
                            height: 27.h,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: GradientLoader(
                                size: 20.h,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          TextWidget(
                            Methods()
                                .convertToAbbreviatedString(
                              state.profile?.sellerBalance ?? 0,
                            )
                                .toString(),
                            isTranslate: false,
                            style: context.bodyLarge
                                .size(26)
                                .bold
                                .colorExt(Colors.white),
                          ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => di<CoinSellerBloc>().add(
                        const GetCoinSellerProfileEvent(
                          isLoading: true,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              15.hBox,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        title: StringManager.coinBalance,
                        value: state.profile?.coinBalance,
                      ),
                    ),
                    _StatDivider(),
                    Expanded(
                      child: _StatTile(
                        title: StringManager.totalTransferred,
                        value: state.profile?.totalTransferred,
                      ),
                    ),
                    _StatDivider(),
                    Expanded(
                      child: _StatTile(
                        title: StringManager.todayTransferred,
                        value: state.profile?.todayTransferred,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 33.h,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
  });

  final String title;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextWidget(
          Methods()
              .convertToAbbreviatedString(value ?? 0)
              .toString(),
          isTranslate: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyMedium
              .size(14)
              .bold
              .colorExt(Colors.white),
        ),
        4.hBox,
        TextWidget(
          title,
          isTranslate: false,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodySmall
              .size(10.5)
              .colorExt(
            Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
