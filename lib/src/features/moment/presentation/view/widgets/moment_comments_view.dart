import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/core/index.dart';

class MomentCommentsView extends StatelessWidget {
  const MomentCommentsView({
    super.key,
    required this.momentId,
  });

  final int momentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentCommentBloc, MomentCommentStates>(
      bloc: di<MomentCommentBloc>(),
      buildWhen: (prev, curr) =>
      prev.reqState != curr.reqState ||
          prev.momentsComment != curr.momentsComment,
      builder: (context, state) {
        if (!state.reqState.isLoaded || state.momentsComment.isEmpty) {
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
                di<MomentCommentBloc>().add(FetchMomentComment(
                    momentId: momentId.toString(), page: "1"));
              },
              child: state.momentsComment.isEmpty
                  ? Center(
                child: Padding(
                  padding: context.paddingSymmetric(vertical: 50),
                  child: Text(
                    StringManager.noCommentFound.tr(),
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
        return SliverList.separated(
          separatorBuilder: (context, index) {
            return Padding(
              padding: context.paddingSymmetric(horizontal: 15),
              child: Divider(
                color: ColorManager.grey.withValues(alpha: (0.2)),
                height: 0.5,
                thickness: 0.5,
              ),
            );
          },
          itemCount: state.momentsComment.length,
          itemBuilder: (context, index) {
            // Trigger pagination when reaching end
            if (index == state.momentsComment.length - 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkPagination(state);
              });
            }
            return Container(
              padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
              margin: context.paddingSymmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: ColorManager.transparent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: GestureDetector(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: '${state.momentsComment[index].userId}',
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserImage(
                      image: state.momentsComment[index].userProfilePic,
                      displayName: state.momentsComment[index].userName,
                      imageSize: 50.w,
                      boxFit: BoxFit.fill,
                    ),
                    10.wBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientName(child: Text(
                            state.momentsComment[index].userName,
                            style: context.bodySmall
                                .colorExt(ColorManager.greyTextColor
                                .withValues(alpha: (0.98)))
                                .size(14),
                          )),
                          3.hBox,
                          TextWidget(
                            Methods.formatDate(
                                state.momentsComment[index].commentTime,
                                locale: context.locale.languageCode),
                            style: context.bodySmall.w500
                                .colorExt(ColorManager.greyTextColor
                                .withValues(alpha: (0.68)))
                                .size(12),
                          ),
                          5.hBox,
                          TextWidget(
                            state.momentsComment[index].comment,
                            style: context.bodyLarge
                                .colorExt(ColorManager.textPrimary)
                                .size(14),
                          ),
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

  void _checkPagination(MomentCommentStates state) {
    if (state.lastPage > state.currentPage) {
      final int nextPage = state.currentPage + 1;
      di<MomentCommentBloc>().add(FetchMomentComment(
        isLoading: false,
        momentId: state.currentMomentId,
        page: '$nextPage',
      ));
    }
  }
}