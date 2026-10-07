import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/auth/domain/entities/vip_entity.dart';
import 'package:general/src/features/vip/vip.dart';
import '../../../mall_bag/presentation/component/custom_model_bottom_sheet.dart';
import 'components/my_vip_card.dart';
import 'components/send_vip_bottom_sheet.dart';
part 'widgets/vip_body_item.dart';
part 'components/tab_bar_body.dart';
part 'components/tab_bar_view_vip_body.dart';
part 'components/vip_body.dart';
part 'components/tab_bar_body_vip.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key, this.parameter});
  final NavigateVipParameter? parameter;
  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    if (di<VipCenterBloc>().state.requestState != RequestState.loaded) {
      di<VipCenterBloc>().add(const GetVipCenterEvent());
    }
    if (!di<VipCenterBloc>().state.requestStateVipBag.isLoaded) {
      di<VipCenterBloc>().add(const GetVipBagEvent());
    }
    // Fetch VIP theme settings for backgrounds
    if (di<GetVipThemeSettingsBloc>().state.state != RequestState.loaded) {
      di<GetVipThemeSettingsBloc>().add(const GetVipThemeSettingsEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = BlocBuilder<VipCenterBloc, VipStates>(
      bloc: di<VipCenterBloc>(),
      buildWhen: (prev, curr) =>
          prev.requestState != curr.requestState || prev.vip != curr.vip,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorManager.scaffoldBgAlt,
          body: BackgroundImgWidget(
            child: HandlingDataWidget(
              reqState: state.requestState,
              title: '-',
              subTitle: '-',
              child: VipBody(
                index: widget.parameter?.vip,
                length: state.vip.length,
              ),
            ),
          ),
        );
      },
    );

    return normalPage;
  }
}
