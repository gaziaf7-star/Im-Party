import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

class DollarsCard extends StatelessWidget {
  const DollarsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: ColorManager.agencypurpleColorList),
          borderRadius: 10.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: TextWidget(
              StringManager.totalBeans.tr(),
              style:
                  context.bodyLarge.w600.size(20).colorExt(ColorManager.textPrimary),
            ),
          ),
          Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset(
                 " AssetsManager.beans",
                  scale: 4,
                ),
                BlocBuilder<MyStoreBloc, MyStoreState>(
                  bloc: di<MyStoreBloc>(),
                  buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                  builder: (context, state) {
                    return TextWidget(
                        (di<MyStoreBloc>().state.myStore?.userUsd ?? 0)
                            .toString(),
                        style: context.bodyLarge
                            .colorExt(ColorManager.textPrimary)
                            .w600
                            .size(30));
                  },
                ),
              ],
            ),
          ),
          20.hBox,
          Container(
            padding: context.paddingSymmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: ColorManager.agencypurpleColorList),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: (0.2 )),
                    // Shadow color
                    offset: const Offset(2, 0),
                    // Shadow offset (x, y)
                    blurRadius: 6,
                    // Spread of the shadow
                    spreadRadius: 2, // Intensity around the edges
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                )),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      StringManager.withdrawalBeans.tr(),
                      style: context.bodyLarge.w600
                          .size(13)
                          .colorExt(ColorManager.textPrimary),
                    ),
                    Row(
                      children: [
                        Image.asset(
                        "  AssetsManager.beans",
                          scale: 6,
                        ),
                        BlocBuilder<MyStoreBloc, MyStoreState>(
                          bloc: di<MyStoreBloc>(),
                          buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                          builder: (context, state) {
                            return TextWidget(
                                (di<MyStoreBloc>().state.myStore?.withdrawaledUsd ?? 0)
                                    .toString(),
                                style: context.bodyLarge
                                    .colorExt(ColorManager.textPrimary)
                                    .w600
                                    .size(16));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      StringManager.pendingBeans.tr(),
                      style: context.bodyLarge.w600
                          .size(13)
                          .colorExt(ColorManager.textPrimary),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "AssetsManager.beans",
                          scale: 6,
                        ),
                        BlocBuilder<MyStoreBloc, MyStoreState>(
                          bloc: di<MyStoreBloc>(),
                          buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                          builder: (context, state) {
                            return TextWidget(
                                (int.parse(di<MyStoreBloc>()
                                                .state
                                                .myStore
                                                ?.pendingDollar)
                                            .abs())
                                    .toString(),
                                style: context.bodyLarge
                                    .colorExt(ColorManager.textPrimary)
                                    .w600
                                    .size(16));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
