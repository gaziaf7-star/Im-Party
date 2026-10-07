import 'package:general/src/core/index.dart';
import '../../../agency.dart';

class ShowShippingAgency extends StatefulWidget {
  final ChargeAgencyInfoEntity? agencyData;
  final bool isProfile;
  final int? id;

  const ShowShippingAgency({
    super.key,
    this.agencyData,
    this.id,
    required this.isProfile,
  });

  @override
  State<ShowShippingAgency> createState() => _ShowShippingAgencyState();
}

class _ShowShippingAgencyState extends State<ShowShippingAgency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      body: BlocBuilder<GetChargeAgencyBloc, GetChargeAgencyStates>(
        bloc: di<GetChargeAgencyBloc>(),
        buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.data != curr.data,
        builder: (context, state) {
          if (widget.isProfile && widget.agencyData == null) {
            return HandlingDataWidget(
              reqState: state.requestState,
              title: StringManager.someThingWentWrong,
              subTitle: StringManager.someThingWentWrong,
              child: _buildAgencyUI(
                ProfileParams(
                  img: state.data?.img ?? '',
                  name: state.data?.name ?? '',
                  id: state.data?.id?.toString() ?? '',
                  owner: state.data?.owner,
                ),
              ),
            );
          }
          return _buildAgencyUI(
            ProfileParams(
                img: widget.agencyData?.img ?? '',
                name: widget.agencyData?.name ?? '',
                id: widget.agencyData?.id?.toString() ?? '',
                owner: widget.agencyData?.owner),
          );
        },
      ),
    );
  }

  Widget _buildAgencyUI(ProfileParams param) {
    return Stack(
      children: [
        NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: ScreenUtil().screenHeight * 0.42,
              automaticallyImplyLeading: false,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: ColorManager.scaffoldBg,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: TextWidget(
                  innerBoxIsScrolled ? param.name : '',
                  style: context.bodyLarge.w600,
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: ColorManager.transparent,
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.arrow_back,
                    size: 18.5.h,
                    color:
                        innerBoxIsScrolled ? Colors.black : ColorManager.white,
                  ),
                ),
              ),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ImageViewWidget(
                      url: param.img,
                      displayName: param.name,
                      width: ScreenUtil().screenWidth,
                      height: ScreenUtil().screenHeight * 0.32,
                      boxFit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: context.paddingSymmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageViewWidget(
                              url: param.img,
                              displayName: param.name,
                              height: 120.w,
                              width: 120.w,
                              radius: 150.r,
                            ),
                            5.hBox,
                            Padding(
                              padding: context.paddingSymmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    param.name,
                                    style: context.bodyMedium.w600
                                        .colorExt(ColorManager.textPrimary)
                                        .size(15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  7.hBox,
                                  Row(
                                    children: [
                                      TextWidget(
                                        "ID: ${param.id}",
                                        style: TextStyle(
                                          color: ColorManager.textPrimary
                                              .withValues(alpha: 0.4),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      3.wBox,
                                      ImageWidget(
                                        height: 12.h,
                                        width: 12.w,
                                        image: AssetsManager.copyFamily1,
                                        color: ColorManager.grey2,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            10.hBox,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: _buildAgencyDetails(param),
        ),
      ],
    );
  }

  Widget _buildAgencyDetails(ProfileParams param) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _divider(),
        20.hBox,
        _sectionHeader(StringManager.agencyOwner),
        10.hBox,
        _ownerDetails(param),
        30.hBox,
      ],
    );
  }

  Widget _divider() => Divider(
        color: Colors.black.withValues(alpha: 0.05),
        thickness: 5,
        height: 5,
      );

  Widget _sectionHeader(String title) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 25),
      child: TextWidget(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _ownerDetails(ProfileParams param) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 25),
      child: Row(
        children: [
          UserImage(
            image: EndPoints.getImage(param.owner?.image ?? ""),
            displayName: param.owner?.name ?? '',
            imageSize: 40.w,
          ),
          10.wBox,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //           GradientTextVip(
              //             text: param.owner?.name ?? '',
              //             textStyle: context.bodyLarge
              //                 .colorExt(
              //                   ColorManager.blackColor,
              //                 )
              //                 .w500,
              //             isVip: param.owner?.hasColorName ?? false,
              //             width: ScreenUtil().screenWidth * 0.5,
              //             textOverflow: TextOverflow.ellipsis,
              // color: coloredName != ""
              // ? Color((int.parse(
              // coloredName!.replaceAll('#', '0xff'))))
              //     : ColorManager.black,
              // mainAxisAlignment: MainAxisAlignment.center,
              // textAlign: TextAlign.center,
              // textStyle: context.bodyMedium.size(14).w600.colorExt(
              // coloredName != ""
              // ? Color((int.parse(coloredName!
              //     .replaceAll('#', '0xff'))))
              //     : ColorManager.blackColor,
              //           ),
              //           ),

              TextWidget(
                param.owner?.name ?? "",
                style:
                    context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
              7.hBox,
              Row(
                children: [
                  TextWidget(
                    "ID: ${param.owner?.uuid ?? ''}",
                    style: TextStyle(
                      color: ColorManager.textPrimary.withValues(alpha: 0.7),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  3.wBox,
                  ImageWidget(
                    height: 13.h,
                    width: 13.w,
                    image: AssetsManager.copyFamily1,
                    color: ColorManager.grey2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileParams {
  final String img;
  final String name;
  final String id;
  final int? transaction;
  final OwnerEntity? owner;

  const ProfileParams({
    required this.img,
    required this.name,
    required this.id,
    this.transaction,
    this.owner,
  });
}
