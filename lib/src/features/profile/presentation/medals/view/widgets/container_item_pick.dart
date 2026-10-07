part of '../medals_page.dart';

class ContainerItemPicked extends StatelessWidget {
  const ContainerItemPicked({
    super.key,
    this.onTap,
    this.isImage,
    this.imageUrl,
  });

  final void Function()? onTap;
  final bool? isImage;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
          height: 80.h,
          width: 70.w,
          child: isImage == true
              ? Center(
                  child: (imageUrl ?? "").contains(".svga") ||
                          (imageUrl ?? "").contains(".zz") ||
                          (imageUrl ?? "").contains(".zzz")
                      ? CacheSvgaWidget(
                          url: imageUrl ?? '',
                          height: 70,
                          width: 70,
                          radius: 15,
                          boxFit: BoxFit.fill,
                        )
                      : ImageViewWidget(
                          url: imageUrl ?? "",
                          height: 70,
                          width: 70,
                          heightError: 60,
                          widthError: 60,
                          radius: 15,
                          boxFit: BoxFit.fill,
                        ),
                )
              : Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Image.asset(
                      AssetsManager.emptyBadge,
                      color: ColorManager.headerColor,
                    ),
                    Positioned(
                      bottom: 20.h,
                      child: Image.asset(
                        AssetsManager.starBadge,
                        color: ColorManager.primary.withValues(alpha: (0.5)),
                        scale: 3.5,
                      ),
                    ),
                  ],
                )),
    );
  }
}
