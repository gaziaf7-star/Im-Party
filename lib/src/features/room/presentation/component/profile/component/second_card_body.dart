import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';
import '../../../../data/model/user_in_room_model.dart';
import '../bloc/extra_data_profile_bloc.dart';

class SecondCardRoomProfileBody extends StatelessWidget {
  const SecondCardRoomProfileBody({super.key, required this.userData});

  final UserInRoomModel userData;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchExtraDataBloc, FetchExtraDataStates>(
      bloc: di.isRegistered<FetchExtraDataBloc>() ? di<FetchExtraDataBloc>() : null,
      buildWhen: (prev, curr) => prev.extraProfileData != curr.extraProfileData,
      builder: (context, state) {
        final hasCp =
            (state.extraProfileData?.cp?.user?.image ?? '').isNotEmpty;

        return Column(
          children: [
            // CP relationship — only when the user actually HAS a CP. Same
            // gradient card look as the "My Relations" CP page, on request,
            // instead of the plain white row this used to be.
            if (hasCp) ...[
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.popRoute();
                  Methods().userProfileNavigator(
                    context: context,
                    user_: const UserEntity(),
                    userId: userData.id.toString(),
                  );
                },
                child: CpLegendBox(
                  label: 'Lv.${state.extraProfileData?.cp?.level ?? 1}',
                  backgroundGradient: const [
                    Color(0xFFFF6FA5),
                    Color(0xFF7A1E4A),
                  ],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Was spaceAround (pushed the two avatars out toward the
                    // card's edges) -- centered with a fixed gap instead, on
                    // request, so they sit closer together around the heart.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CpProfileColumn(
                        image: userData.image ?? '',
                        name: userData.name ?? '',
                      ),
                      12.wBox,
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Image.asset(
                          AssetsManager.heartCpProfile,
                          height: 36.h,
                          width: 36.h,
                        ),
                      ),
                      12.wBox,
                      _CpProfileColumn(
                        image: state.extraProfileData?.cp?.user?.image ?? '',
                        name: state.extraProfileData?.cp?.user?.name ?? '',
                      ),
                    ],
                  ),
                ),
              ),
              5.hBox,
            ],
            // وسام (medal) card hidden on request.
            // Gifts card removed from this sheet on request.
            // Family card removed from this sheet on request too.
          ],
        );
      },
    );
  }
}

/// Avatar + name, stacked — matches the "My Relations" CP card's layout so
/// this preview reads as the same card.
class _CpProfileColumn extends StatelessWidget {
  const _CpProfileColumn({required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageViewWidget(
          height: 40.h,
          width: 40.h,
          shape: BoxShape.circle,
          displayName: name,
          url: image,
        ),
        1.hBox,
        SizedBox(
          // Widened — names were getting clipped at 80.w.
          width: 105.w,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodySmall.bold.colorExt(Colors.white).size(11),
          ),
        ),
      ],
    );
  }
}
