
import '../../../../../../core/index.dart';

class CardBody extends StatelessWidget {
  const CardBody({super.key, 
    required this.image,
    required this.title,
    required this.onTap,
  });
  final String image, title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius:4.radius
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: 4.radius,
        child: Padding(
          padding: context.paddingSymmetric(
            horizontal: 10.w,
            vertical: 10.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageWidget(
                image:  image,
                height: 30.h,
                width: 30.w,
              ),
              10.hBox,
              FittedBox(

                child: TextWidget(
                  title,
                  style: context.bodySmall.w500.colorExt(
                    ColorManager.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // const CardBody({super.key,
  //   required this.image,
  //    this.height,
  //    this.width,
  //   required this.title, this.color, this.paddingTop, this.fontSize,
  // });

  // final String image, title;
  // final Color? color;
  // final double? paddingTop,height,width,fontSize;
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     alignment: Alignment.center,
  //     height: height?? 55.h,
  //     width:width?? 120.w,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         fit: BoxFit.contain,
  //         image: AssetImage(image),
  //       ),
  //     ),
  //     child: TextWidget(title,padding: context.paddingOnly(top:paddingTop??0),style: context.bodyMedium.bold.colorExt(color??ColorManager.white).copyWith(

  //       fontSize:fontSize?? 11.sp
  //     ),),
  //   );
  // }


}
