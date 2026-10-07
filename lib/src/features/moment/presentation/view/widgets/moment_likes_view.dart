import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_likes_bloc/moment_likes_bloc_state.dart';

import '../../bloc/moment_likes_bloc/get_moment_likes_event.dart';
import '../../bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';

class MomentLikesView extends StatelessWidget {
  const MomentLikesView({
    super.key,
    required this.momentId,
  });

  final int momentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMomentLikesBloc, GetMomentLikesState>(
      bloc: di<GetMomentLikesBloc>(),
      buildWhen: (prev, curr) =>
      prev.reqState != curr.reqState ||
          prev.momentLikes != curr.momentLikes,
      builder: (context, state) {
        if (!state.reqState.isLoaded || state.momentLikes.isEmpty) {
          return SliverToBoxAdapter(
            child: HandlingDataWidget(
              reqState: state.reqState,
              title: StringManager.noMomentsFound.tr(),
              subTitle: StringManager.noMomentsFoundSubTitle.tr(),
              titleStyle: context.bodyLarge.w600
                  .colorExt(ColorManager.momentPostTextColor),
              subTitleStyle: context.bodyMedium.copyWith(
                color: ColorManager.momentPostTextColor.withValues(alpha: 0.7),
                height: 1.30,
              ),
              buttonBackgroundColors: ColorManager.brandGradientColors,
              buttonBorderColor: ColorManager.transparent,
              onTap: () {
                di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
                    momentId: momentId.toString(), page: "1"));
              },
              child: state.momentLikes.isEmpty
                  ? Center(
                child: Padding(
                  padding: context.paddingSymmetric(vertical: 50),
                  child: Text(
                    StringManager.noLikesFound.tr(),
                    style: context.bodyLarge
                        .colorExt(ColorManager.textPrimary)
                        .w500
                        .size(14),
                  ),
                ),
              )
                  : const SizedBox(),
            ),
          );
        }

        return SliverList.builder(
          itemCount: state.momentLikes.length,
          itemBuilder: (context, index) {
            if (index == state.momentLikes.length - 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkPagination(state);
              });
            }
            return Container(
              padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
              margin: context.paddingSymmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: ColorManager.transparent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: GestureDetector(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: '${state.momentLikes[index].userId}',
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserImage(
                      image: state.momentLikes[index].userImage,
                      displayName: state.momentLikes[index].userName,
                      imageSize: 45.w,
                      boxFit: BoxFit.fill,
                    ),
                    10.wBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientName(child: Text(
                            state.momentLikes[index].userName,
                            style: context.bodySmall
                                .colorExt(ColorManager.greyTextColor)
                                .size(14),
                          )),
                          5.hBox,
                          TextWidget(
                            "${StringManager.liked.tr()} ${Methods.timeAgo(DateTime.parse(state.momentLikes[index].createdAt).toLocal())}",
                            style: context.bodyLarge
                                .colorExt(ColorManager.textPrimary)
                                .size(14),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _checkPagination(GetMomentLikesState state) {
    if (state.lastPage > state.currentPage) {
      final int nextPage = state.currentPage + 1;
      di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
        page: '$nextPage',
        momentId: state.currentMomentId,
        isLoading: false,
      ));
    }
  }
}