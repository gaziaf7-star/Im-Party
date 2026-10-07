import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_relations/cp_relations_bloc.dart';
import 'component/all_friends_view.dart';

class CpStorePage extends StatefulWidget {
  const CpStorePage({super.key});

  @override
  State<CpStorePage> createState() => _CpStorePageState();
}

class _CpStorePageState extends State<CpStorePage> {
  @override
  void initState() {
    if (!di<GetCpRelationsBloc>().state.userStates.isLoaded) {
      di<GetCpRelationsBloc>().add(GetCpRelationsEvents());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        // Professional gradient app bar instead of the old transparent one.
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E6BFF), Color(0xFFC084FC)],
        ),
        title: StringManager.relationSpecial.tr(),
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.white),
        iconColor: ColorManager.white,
      ),
      body: BlocBuilder<GetCpRelationsBloc, CpRelationsStates>(
        bloc: di<GetCpRelationsBloc>(),
        buildWhen: (prev, curr) =>
        prev.userStates != curr.userStates ||
            prev.errorMessage != curr.errorMessage ||
            prev.data != curr.data,
        builder: (context, state) {
          return HandlingDataWidget(
              reqState: state.userStates,
              title: state.errorMessage,
              subTitle: state.errorMessage,
              child: GridView.builder(
                padding: context.paddingSymmetric(horizontal: 8, vertical: 8),
                itemCount: state.data?.data.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: 20.radiusCircular,
                            topLeft: 20.radiusCircular,
                          ),
                        ),
                        builder: (context) => AllFriendsView(
                          relationId:
                          state.data?.data[index].id.toString() ?? "",
                        ),
                      );
                    },
                    child: Container(
                      margin: context.paddingAll(5),
                      padding: context.paddingAll(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: ColorManager.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                            ColorManager.black.withValues(alpha: 0.06),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageViewWidget(
                            url: EndPoints.getImage(
                                state.data?.data[index].image ?? ""),
                            width: 60.w,
                            height: 70.h,
                            boxFit: BoxFit.contain,
                          ),
                          5.hBox,
                          TextWidget(
                            state.data?.data[index].title.toString() ?? "",
                            style: context.bodyMedium
                                .size(12)
                                .w600
                                .colorExt(ColorManager.black),
                            maxLines: 1,
                          ),
                          5.hBox,
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AssetsManager.cpCoin,
                                  scale: 2.8,
                                ),
                                5.wBox,
                                FittedBox(
                                  child: TextWidget(
                                    state.data?.data[index].price
                                        .toString() ??
                                        "0",
                                    style: context.bodyMedium
                                        .size(12)
                                        .w600
                                        .colorExt(ColorManager.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ));
        },
      ),
    );
  }
}