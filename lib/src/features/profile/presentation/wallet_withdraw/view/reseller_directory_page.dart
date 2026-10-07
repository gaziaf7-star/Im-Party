import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/wallet_withdraw_models.dart';
import 'package:general/src/features/profile/presentation/wallet_withdraw/bloc/wallet_withdraw_bloc.dart';

/// Gold "VIP directory" gradient — shared by the Recharge Coins app bar's
/// "Top" action and this page's own app bar so the two visually match.
const List<Color> resellerVipGradient = [
  Color(0xFF3A2A0A),
  Color(0xFF7A551C),
  Color(0xFFD4A94A),
];

/// Full directory of coin resellers — reached from the "Top" action on the
/// Recharge Coins app bar. Reuses the same [WalletWithdrawBloc] singleton and
/// `resellers` list already used to populate the withdraw screen's "Coin
/// Seller" dropdown, so opening this page never re-fetches if that list is
/// already loaded.
class ResellerDirectoryPage extends StatefulWidget {
  const ResellerDirectoryPage({super.key});

  @override
  State<ResellerDirectoryPage> createState() => _ResellerDirectoryPageState();
}

class _ResellerDirectoryPageState extends State<ResellerDirectoryPage> {
  late final WalletWithdrawBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di<WalletWithdrawBloc>()..add(const LoadResellersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: StringManager.resellerDirectory.tr(),
        iconColor: Colors.white,
        titleStyle:
            context.bodyMedium.size(18).w700.colorExt(Colors.white),
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: resellerVipGradient,
        ),
      ),
      body: BlocBuilder<WalletWithdrawBloc, WalletWithdrawState>(
        bloc: _bloc,
        buildWhen: (prev, curr) =>
            prev.resellers != curr.resellers ||
            prev.resellerState != curr.resellerState,
        builder: (context, state) {
          if (state.resellerState.isLoading && state.resellers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.resellers.isEmpty) {
            return Center(
              child: TextWidget(
                StringManager.noDataYet.tr(),
                style: context.bodyMedium.colorExt(Colors.black),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _bloc.add(const LoadResellersEvent()),
            child: ListView.separated(
              padding: context.paddingSymmetric(horizontal: 15, vertical: 14),
              itemCount: state.resellers.length,
              separatorBuilder: (_, __) => 12.hBox,
              itemBuilder: (context, index) =>
                  _ResellerTile(reseller: state.resellers[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ResellerTile extends StatelessWidget {
  const _ResellerTile({required this.reseller});

  final WithdrawReseller reseller;

  @override
  Widget build(BuildContext context) {
    final displayId = reseller.publicId.isNotEmpty
        ? reseller.publicId
        : reseller.id.toString();
    return Container(
      padding: context.paddingSymmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: 16.radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF201A10), Color(0xFF120E08)],
        ),
        border: Border.all(color: const Color(0xFFD4A94A), width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x33D4A94A), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: resellerVipGradient),
            ),
            child: ImageViewWidget(
              url: reseller.image,
              displayName: reseller.name,
              width: 48.w,
              height: 48.w,
              radius: 24.h,
            ),
          ),
          12.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFD4A94A), size: 15),
                    4.wBox,
                    Expanded(
                      child: TextWidget(
                        reseller.name,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium.w700
                            .colorExt(Colors.white),
                      ),
                    ),
                  ],
                ),
                6.hBox,
                Container(
                  padding: context.paddingSymmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: 10.radius,
                    color: const Color(0x33D4A94A),
                  ),
                  child: TextWidget(
                    'ID: $displayId',
                    style: context.bodySmall
                        .colorExt(const Color(0xFFD4A94A)),
                  ),
                ),
              ],
            ),
          ),
          if (reseller.hasWhatsapp) ...[
            10.wBox,
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Methods.safeLaunchUrl(
                "https://wa.me/${reseller.whatsappNumber.replaceAll('+', '')}",
              ),
              child: Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF25D366),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
