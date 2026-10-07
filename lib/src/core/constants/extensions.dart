import 'package:general/src/core/index.dart';

extension ImagePathExt on String {
  // Images
  String get pngImg => "assets/images/$this.png";
  String get webPImg => "assets/images/$this.webp";
  String get jpgImg => "assets/images/$this.jpg";
  String get jpegImg => "assets/images/$this.jpeg";
  String get svgImg => "assets/images/$this.svg";
  String get svgaImg => "assets/images/$this.svga";
  String get jsonImg => "assets/images/$this.json";
  String get gifImg => "assets/images/$this.gif";
  // Icons
  String get webPIcon => "assets/icons/$this.webp";
  String get pngIcon => "assets/icons/$this.png";
  String get svgaVip => "assets/vip/$this.svga";
  String get pngVip => "assets/vip/$this.png";
  String get svgaBottomNav => "assets/bottom_nav/$this.svga";
  String get svgaGridList => "assets/images/$this.svga";
  String get jpgIcon => "assets/icons/$this.jpg";
  String get jpegIcon => "assets/icons/$this.jpeg";
  String get svgIcon => "assets/icons/$this.svg";
  String get svgaIcon => "assets/icons/$this.svga";
}

extension DimensionsExt on num {
  SizedBox get hBox => SizedBox(height: toDouble().h);
  SizedBox get wBox => SizedBox(width: toDouble().w);
  BorderRadius get radius => BorderRadius.circular(toDouble().r);
  Radius get radiusCircular => Radius.circular(toDouble().r);
}

extension PaddingExt on BuildContext {
  EdgeInsetsDirectional paddingOnly({
    double end = 0,
    double top = 0,
    double start = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      end: end.w,
      top: top.h,
      start: start.w,
      bottom: bottom.h,
    );
  }

  EdgeInsetsDirectional paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsetsDirectional.symmetric(
      horizontal: horizontal.w,
      vertical: vertical.h,
    );
  }

  EdgeInsetsDirectional paddingAll(double value) {
    return EdgeInsetsDirectional.all(value.h);
  }

  EdgeInsets paddingZero() => EdgeInsets.zero;
}

extension TextThemeExt on BuildContext {
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;
}

extension FontExt on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
  TextStyle get w200 => copyWith(fontWeight: FontWeight.w200);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);
  TextStyle get w900 => copyWith(fontWeight: FontWeight.w900);
  TextStyle size(double size) => copyWith(fontSize: size.sp);
  TextStyle colorExt(Color color) => copyWith(color: color);
}

extension TextEditingControllerExtension on TextEditingController {
  TextEditingController copyWith({String? text}) {
    return TextEditingController(text: text ?? this.text);
  }
}

// extension PhoneNumberControllerExtension on PhoneController {
//   PhoneController copyWith({IsoCode? isoCode}) {
//     return PhoneController(
//         initialValue: PhoneNumber(isoCode: isoCode ?? IsoCode.EG, nsn: ''));
//   }
// }

extension RequestStateExt on RequestState {
  bool get isIdle => this == RequestState.idle;
  bool get isLoading => this == RequestState.loading;
  bool get isLoaded => this == RequestState.loaded;
  bool get isError => this == RequestState.error;
  bool get isEmpty => this == RequestState.empty;
  bool get isOffline => this == RequestState.offline;
  bool get userBan => this == RequestState.ban_user;
}

extension NavigatorContextExtension on BuildContext {
  Future<T?> pushNamedRoute<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
        routeName, predicate ?? (_) => false,
        arguments: arguments);
  }

  Future<T?> pushReplacementNamedRoute<T, TO>(String routeName,
      {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void popRoute<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  void popUntilRoute(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}
