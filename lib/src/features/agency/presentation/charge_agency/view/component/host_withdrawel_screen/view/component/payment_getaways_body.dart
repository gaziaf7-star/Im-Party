part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class PaymentGetawaysBody extends StatelessWidget {
  const PaymentGetawaysBody({super.key, required this.payments});

  final List<PaymentsGetwaysEntity> payments;

  @override
  Widget build(BuildContext context) {
    final int itemCount = payments.length > 4 ? 4 : payments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          StringManager.availablePayments.tr(),
          style: context.bodyMedium.size(7).w600,
        ),
        5.hBox,
        SizedBox(
          width: _width(itemCount),
          height: 30.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < itemCount; i++)
                Positioned(
                  left: i * 8.w * 1.4,
                  child: ClipRRect(
                    borderRadius: 15.radius,
                    child: ImageViewWidget(
                      url: payments[i].photo ?? '',
                      height: 25.h,
                      width: 25.w,
                      boxFit: BoxFit.fill,
                      // errorBuilder: (context, error, stackTrace)
                      // => Container(
                      //   height: 25.h,
                      //   width: 25.w,
                      //   decoration: BoxDecoration(
                      //     borderRadius: 15.radius,
                      //     color: ColorManager.transparent,
                      //   ),
                      //   child: const Center(
                      //     child: Icon(Icons.error, color: Colors.red),
                      //   ), // Optional: error icon
                      // ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _width(int count) {
    if (count == 1) {
      return 10 * 4;
    } else if (count == 2) {
      return 10 * 5.5;
    } else if (count >= 3) {
      return 10 * 7;
    } else {
      return 0;
    }
  }
}
