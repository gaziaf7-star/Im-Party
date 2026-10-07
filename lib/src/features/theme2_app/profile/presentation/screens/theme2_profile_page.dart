import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/theme2_app/profile/presentation/widgets/theme2_profile_header.dart';
import 'package:general/src/features/theme2_app/profile/presentation/widgets/theme2_menu_grid.dart';
import 'package:general/src/features/theme2_app/profile/presentation/widgets/theme2_settings_section.dart';

class Theme2ProfilePage extends StatelessWidget {
  const Theme2ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
          bloc: di<FetchUserDataBloc>(),
          buildWhen: (prev, curr) =>
              prev.reqState != curr.reqState ||
              prev.userEntity != curr.userEntity,
          builder: (context, state) {
            return RefreshIndicatorWidget(
              onRefresh: () async {
                di<FetchUserDataBloc>().add(
                  const FetchMyDataEvent(isLoading: false),
                );
                di<GetSettingBloc>().add(const GetSettingsEvent());
                di<MyStoreBloc>().add(const GetMyStoreEvent());
              },
              child: HandlingDataWidget(
                reqState: state.reqState,
                title: '',
                subTitle: '',
                onTap: () => di<FetchUserDataBloc>()
                    .add(const FetchMyDataEvent(isLoading: false)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header + edit affordance. The edit button sits at the
                      // top-left (after the Spacer, far end in RTL) and only on
                      // the user's OWN profile — which the "me" tab always is —
                      // mirroring the visitor profile page pattern.
                      Stack(
                        children: [
                          Theme2ProfileHeader(
                            data: state.userEntity ?? const MyDataEntity(),
                          ),
                          Positioned(
                            top: 8.h,
                            left: 8.w,
                            right: 8.w,
                            child: Row(
                              children: [
                                const Spacer(),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Routes.editProfile,
                                    arguments: MyDataModel.getInstance(),
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      color: ColorManager.black
                                          .withValues(alpha: 0.45),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: ColorManager.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      16.hBox,
                      Theme2StatsRow(
                        data: state.userEntity ?? const MyDataEntity(),
                      ),
                      16.hBox,
                      // Unified menu section: shortcut icon grid with the coins
                      // balance nested into its top-right L-notch (diamonds card
                      // removed; diamonds remain reachable inside the coins
                      // screen tabs).
                      Theme2MenuGrid(
                        data: state.userEntity ?? const MyDataEntity(),
                      ),
                      16.hBox,
                      const Theme2SettingsSection(),
                      30.hBox,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
