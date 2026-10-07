import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';

class SuccessLuckWidget extends StatelessWidget {
  final String coins;
  final String ownerName;
  final String ownerImage;
  const SuccessLuckWidget({
    required this.coins,
    super.key,
    required this.ownerName,
    required this.ownerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsManager.luckyBoxWinner),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25.h),
                child: ImageViewWidget(
                  url: MyDataModel.getInstance().profile?.image ?? '',
                  displayName: MyDataModel.getInstance().name ?? '',
                  width: 50.h,
                  height: 50.h,
                  radius: 100.r,
                ),
              ),
              Text(
                MyDataModel.getInstance().name ?? "",
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorManager.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              20.hBox,
              Center(
                child: Text(
                  '${StringManager.goodLuck.tr()} $coins \n${StringManager.coins_.tr()} ',
                  style: TextStyle(
                    color: ColorManager.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ShowSVGA(
            svgaAssetPath: AssetsManager.fireWorks,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }
}
