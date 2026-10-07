import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/search_manager/search_user_agency_bloc.dart';
import 'package:general/src/features/payment/presentation/view/components/dollars_view.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key, this.isMySalary = true});

  final bool isMySalary;

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  late final TextEditingController userIdController,
      agencyIdController,
      amountController;
  ValueNotifier<int> userType = ValueNotifier<int>(0);

  String selectedDate = "";
  final MyStoreBloc _myStoreBloc = di<MyStoreBloc>();

  @override
  void initState() {
    userIdController = TextEditingController();
    agencyIdController = TextEditingController();
    amountController = TextEditingController();
    selectedDate = !widget.isMySalary
        ? "${DateTime.now().year} / ${DateTime.now().month}"
        : "${DateTime.now().year} - ${DateTime.now().month}";
    if (!_myStoreBloc.state.reqState.isLoaded) {
      _myStoreBloc.add(const GetMyStoreEvent());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    userIdController.dispose();
    agencyIdController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.withdrawal.tr(),
        titleStyle: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, Routes.hostsAgencyDollarsRecordsScreen);
            },
            child: TextWidget(
              StringManager.record,
              style: context.bodyMedium
                  .size(12)
                  .w600
                  .colorExt(ColorManager.textPrimary),
            ),
          ),
        ],
      ),
      body: BlocListener<ChargeDollarsForUserBloc, ChargeDollarsForUserState>(
        bloc: di<ChargeDollarsForUserBloc>(),
        listener: (context, state) {
          if (state.requestState.isLoading) {
            Methods.showToast(context, isLoading: true);
          } else if (state.requestState.isLoaded) {
            Methods.showToast(
              context,
              message: StringManager.transferSuccess.tr(),
            );
            di<MyStoreBloc>().add(const GetMyStoreEvent());
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: ColorManager.scaffoldBgAlt,
            padding: context.paddingSymmetric(horizontal: 20),
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                150.hBox,
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Container(
                    width: ScreenUtil().screenWidth,
                    margin:
                        context.paddingSymmetric(horizontal: 10, vertical: 30),
                    padding: context.paddingSymmetric(vertical: 10),
                    decoration:
                        const BoxDecoration(color: ColorManager.transparent),
                    child: Column(
                      children: [
                        BlocBuilder<MyStoreBloc, MyStoreState>(
                          bloc: _myStoreBloc,
                          buildWhen: (prev, curr) =>
                              prev.myStore != curr.myStore,
                          builder: (context, state) {
                            return TextWidget(
                              Methods()
                                  .convertToAbbreviatedString(
                                      _myStoreBloc.state.myStore!.agentUsd ?? 0)
                                  .toString(),
                              style: context.bodyMedium
                                  .size(30)
                                  .w700
                                  .colorExt(ColorManager.textPrimary),
                            );
                          },
                        ),
                        TextWidget(
                          StringManager.availableBalance.tr(),
                          style: context.bodyMedium
                              .size(14)
                              .w700
                              .colorExt(ColorManager.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                30.hBox,
                TextWidget(
                  StringManager.userType_,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: ColorManager.textPrimary,
                  ),
                ),
                5.hBox,
                UserTypeSwitcherWidget(userType: userType),
                15.hBox,
                Expanded(
                  child: UserTypeContentWidget(
                    userType: userType,
                    agencyIdController: agencyIdController,
                    userIdController: userIdController,
                    amountController: amountController,
                    isDollarsValue: true,
                    onPressedTransfer: () {
                      if (!di<ChargeDollarsForUserBloc>()
                          .state
                          .requestState
                          .isLoading) {
                        di<ChargeDollarsForUserBloc>().add(
                          ChargeDollarsForUserEvent(
                            id: di<SearchUserAgencyBloc>().state.param?.id ??
                                '-1',
                            type: userType.value == 1 ? "user" : "agency",
                            amount: amountController.text,
                            context: context,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
