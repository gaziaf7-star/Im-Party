import 'package:general/src/core/index.dart';

class Styles {
  static TextStyle h1(BuildContext context) {
    return context.titleLarge.w500.colorExt(ColorManager.textPrimary);
  }

  static friendsBox() {
    return BoxDecoration(
        color: ColorManager.transparent,
        borderRadius: BorderRadius.only(
            topLeft: 15.radiusCircular, topRight: 15.radiusCircular));
  }

  static messagesCardStyle(check) {
    return BoxDecoration(
      borderRadius: check
          ? 10.radius.copyWith(bottomRight: 0.radiusCircular)
          : 10.radius.copyWith(bottomLeft: 0.radiusCircular),
      color: check ? ColorManager.primary : ColorManager.surfaceCardColor,
    );
  }

  static messageFieldCardStyle() {
    return BoxDecoration(
        color: ColorManager.surfaceCardColor,
        border: Border.all(color: ColorManager.primary),
        borderRadius: BorderRadius.circular(10));
  }

  static messageTextFieldStyle({
    required void Function()? onPressed,
    required Function() onSubmitImage,
    required Function() onSubmit,
    required BuildContext context,
    required bool doNotNeedCamIcon,
  }) {
    return InputDecoration(
      fillColor: ColorManager.textAddInfo,
      filled: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: ColorManager.transparent)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: ColorManager.transparent)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: ColorManager.transparent)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: ColorManager.transparent)),
      hintText: StringManager.enterYorFullData.tr(),
      hintStyle: context.bodyMedium.colorExt(ColorManager.textPrimary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      suffixIcon: SizedBox(
        width: 80.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: () {},
                child: Image.asset(
                  AssetsManager.google,
                  scale: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: (0.8)),
                )

                // Icon(
                //
                //
                //   Icons.,
                //   color: Theme.of(context).colorScheme.background.withValues(alpha:0.8),
                //
                // ),
                ),
            (doNotNeedCamIcon == false)
                ? IconButton(
                    onPressed: onSubmitImage,
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: (0.8)),
                    ),
                  )
                : const SizedBox()

            // InkWell(
            //   onTap: (){
            //     bottomDialog(context: context,
            //         widget:  MyApp());
            //   }  ,
            //
            //
            //
            //
            //
            //   child: Icon(
            //
            //
            //     Icons.mic,
            //     color: Theme.of(context).colorScheme.background.withValues(alpha:0.8),
            //
            //   ),
            // ),
          ],
        ),
      ),
      // prefixIcon: IconButton(
      //   onPressed:onPressed,
      //   icon: Icon(
      //     Icons.emoji_emotions_outlined,
      //     color: Theme.of(context).colorScheme.background.withValues(alpha:0.8),
      //   ),
      // )
    );
  }

  static searchTextFieldStyle() {
    return InputDecoration(
      border: InputBorder.none,
      hintText: StringManager.enterANickname.tr(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      suffixIcon:
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
    );
  }
}
