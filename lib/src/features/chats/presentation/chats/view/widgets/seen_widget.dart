import '../../../../../../core/index.dart';

class SeenWidget extends StatefulWidget {
  final String seen;

  const SeenWidget({super.key, required this.seen});

  @override
  State<SeenWidget> createState() => _SeenWidgetState();
}

class _SeenWidgetState extends State<SeenWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.seen) {
      case "sent":
      case "sended":
        return Icon(
          Icons.check,
          size: 18.h,
          color: ColorManager.grey,
        );
      case "delivered":
      case "received":
        return Icon(
          Icons.done_all,
          size: 18.h,
          color: ColorManager.grey,
        );
      case "seen":
        return Icon(
          Icons.done_all,
          size: 18.h,
          color: ColorManager.blue,
        );
      default:
        return Icon(
          Icons.done_all,
          size: 18.h,
          color: ColorManager.grey,
        );
    }
  }
}
