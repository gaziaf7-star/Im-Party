part of 'package:general/src/features/agency/presentation/search_agency_screen/view/search_for_agency_screen.dart';

class SearchItemWidget extends StatelessWidget {
  final String id;
  final String ownerId;
  final String name;
  final String bio;
  final String image;
  final String usersNumber;
  final bool isSelected;
  final String ownerImage;
  final String ownerName;
  final String ownerFrame;
  final String ownerFrameType;
  final VoidCallback onTap;
  final bool? isMaster;

  const SearchItemWidget({
    super.key,
    this.isSelected = false,
    this.isMaster = false,
    this.ownerName = '',
    this.ownerFrame = '',
    this.ownerFrameType = '',
    required this.id,
    required this.name,
    required this.image,
    required this.ownerImage,
    required this.ownerId,
    required this.usersNumber,
    required this.onTap,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
      margin: context.paddingSymmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: ColorManager.scaffoldBg,
        borderRadius: 15.radius,
        border: Border.all(
          color: isSelected ? ColorManager.primary : ColorManager.transparent,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            UserImage(
              image: image,
              displayName: name,
              imageSize: 55.w,
              // The owner's avatar frame (إطار) wraps the agency avatar when present.
              frame: ownerFrame.isNotEmpty ? ownerFrame : null,
              frameType: ownerFrameType,
              frameSize: 72.w,
              borderRadius: 50.radius,
            ),
            10.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ScreenUtil().screenWidth * 0.45,
                  child: GradientName(child: TextWidget(
                    name,
                    style: context.bodyMedium.w600
                        .size(14)
                        .colorExt(ColorManager.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                3.hBox,
                IdWithCopyIcon(
                  userId: id,
                  isNeedCopyIcon: true,
                  idColor: ColorManager.secondaryText,
                  idStyle: context.bodyMedium
                      .size(11)
                      .w500
                      .colorExt(ColorManager.secondaryText),
                ),
                3.hBox,
                SizedBox(
                  width: ScreenUtil().screenWidth * 0.45,
                  child: TextWidget(
                    bio,
                    style: context.bodyMedium.w500.size(11).colorExt(
                        ColorManager.textPrimary.withValues(alpha: (0.5))),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Row(
                //   children: [
                //     Image.asset(
                //       AssetsManager.persons,
                //       scale: 2.5,
                //       color: ColorManager.grey,
                //     ),
                //     Text(
                //       usersNumber.toString(),
                //       style: context.bodyMedium
                //           .colorExt(ColorManager.greyTextColor),
                //     ),
                //   ],
                // ),
              ],
            ),
            const Spacer(),

            // Chat with the agency owner (صاحب الوكالة): opens a 1:1 DM, mirroring
            // the canonical chat-open used on the visitor profile / friend picker.
            if (ownerId.isNotEmpty && ownerId != '0' && ownerId != 'null')
              InkWell(
                onTap: () {
                  di<FetchUsersChatBloc>().add(
                    UpdateTotalMessages(userId: ownerId, isIncreased: false),
                  );
                  Navigator.pushNamed(
                    context,
                    Routes.messages,
                    arguments: MessagesParameter(
                      hasColorName: false,
                      name: ownerName,
                      image: ownerImage,
                      userId: ownerId,
                      // Recipient owns this agency — exempt from the non-friend
                      // 3-message cap (backend enforces the same exemption).
                      isAgencyOwner: true,
                    ),
                  );
                },
                child: Padding(
                  padding: context.paddingSymmetric(horizontal: 6),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 20.h,
                    color: ColorManager.primary,
                  ),
                ),
              ),

            InkWell(
              onTap: () {
                Methods().userProfileNavigator(
                  context: context,
                  //isPushAndRemoveUntil: true,
                  userId: ownerId,
                );
              },
              child: Icon(
                Icons.navigate_next_sharp,
                size: 20.5.h,
                color: ColorManager.black.withValues(alpha: (0.5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
