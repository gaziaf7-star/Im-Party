import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/setting/setting.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_bloc.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_event.dart';
part 'widgets/privacy_screen_item.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final MangerGetVipPrevBloc _bloc = di<MangerGetVipPrevBloc>();

  @override
  void initState() {
    _bloc.add(const GetVipPrevEvent());

    // if (_bloc.state.requestState != RequestState.loaded) {
    //   _bloc.add(const GetVipPrevEvent());
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.vipPrivilege.tr(),
        backgroundColor: ColorManager.white,
        iconColor: ColorManager.black,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
      ),
      body: RefreshIndicatorWidget(
        onRefresh: () async {
          _bloc.add(const GetVipPrevEvent());
        },
        child: BlocListener<PrivacyBloc, PrivacyState>(
          bloc: di<PrivacyBloc>(),
          listener: (context, state) {
            if (state is LoadingState) {
              Methods.showToast(context, isLoading: true);
            }
            if (state is SuccessState) {
              Methods.showToast(context, message: state.massege);
              UsersCache().removeUser(MyDataModel.getInstance().id ?? -1);
            }
            if (state is ErrorState) {
              Methods.showToast(context, message: state.massege, isError: true);
            }
          },
          child: BlocBuilder<MangerGetVipPrevBloc, MangerGetVipPrevState>(
            bloc: di<MangerGetVipPrevBloc>(),
            buildWhen: (prev, curr) =>
            prev.requestState != curr.requestState ||
                prev.error != curr.error ||
                prev.data != curr.data,
            builder: (context, state) {
              return Center(
                child: HandlingDataWidget(
                  reqState: state.requestState ?? RequestState.idle,
                  title: state.error ?? "",
                  subTitle: state.error ?? "",
                  titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
                  subTitleStyle: context.bodyMedium.colorExt(ColorManager.black.withValues(alpha: 0.6)),
                  buttonBackgroundColors: [ColorManager.primary, ColorManager.primary],
                  child: Padding(
                    padding: context.paddingAll(15),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.data.length,
                            itemBuilder: (context, index) {
                              return PrivacyScreenItem(
                                title: state.data[index].title,
                                currentValue:
                                state.data[index].isActive ?? false,
                                onChanged: (newValue) {
                                  !(state.data[index].isAllowToUser ?? true)
                                      ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AnimatedDialog(
                                        onTap: () {
                                          context.popRoute();
                                          context.pushNamedRoute(
                                            Routes.vipScreen,
                                            arguments:
                                            NavigateVipParameter(
                                              index: 0,
                                              vip: (state
                                                  .data[index].mine ??
                                                  0),
                                            ),
                                          );
                                          di<VipCenterBloc>().add(
                                            ChangeBackgroundEvent(
                                                (state.data[index].mine ??
                                                    1) -
                                                    1),
                                          );
                                          di<VipCenterBloc>().add(
                                              const ChangeTabEvent(0));
                                        },
                                        description: StringManager
                                            .thisFeatureisNotAvailableForYou(
                                            vip: state
                                                .data[index].mine
                                                .toString())
                                            .tr(),
                                        title: state.data[index].title,
                                      );
                                    },
                                  )
                                      : (state.data[index].isActive == true)
                                      ? di<PrivacyBloc>().add(
                                      DisposePrivacy(
                                          type: state.data[index].key ??
                                              ''))
                                      : di<PrivacyBloc>().add(ActivePrivacy(
                                      type:
                                      state.data[index].key ?? ''));
                                },
                                subTitle: state.data[index].description,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}