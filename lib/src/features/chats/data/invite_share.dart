import 'package:general/src/core/index.dart';
import 'package:share_plus/share_plus.dart';

/// مساعد لمشاركة دعوة التطبيق مع جهة اتصال غير مسجّلة كمستخدم.
///
/// الاستخدام النموذجي: داخل قائمة الأصدقاء من جهات الاتصال، إذا كانت جهة
/// الاتصال غير مسجّلة في التطبيق، يظهر زر "إرسال دعوة" يستدعي
/// [shareInvite] لفتح شيت المشاركة (واتساب / ماسنجر / تيك توك / إنستغرام / ...).
class InviteShare {
  const InviteShare._();

  /// رابط متجر التطبيق الاحتياطي إذا لم يكن الأدمن قد ضبط
  /// [ConstantsManager.appURL] بعد (يُملأ من config_app عند الإقلاع).
  ///
  /// White-label: المصدر الموثوق هو [ConstantsManager.appURL] القادم من
  /// config_app؛ هذا مجرد احتياطي محايد لا يربط بحزمة عميل بعينه. الافتراضي
  /// هو الموقع الرسمي للتطبيق (يحوّل أي جهاز إلى المتجر الصحيح)، وقابل للضبط
  /// لكل بناء:
  ///   flutter build ... --dart-define=APP_STORE_URL=<store-or-site-url>
  static const String _fallbackStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: EndPoints.domainURL,
  );

  /// يبني رابط الدعوة.
  ///
  /// بدون داعٍ يُرجع رابط المتجر مباشرة ([ConstantsManager.appURL] أو
  /// [_fallbackStoreUrl]). مع [inviterUserId] يُرجع رابط الـ deep link المُتحقَّق
  /// منه (`/deeplink`، مفعَّل عليه App Links بـ autoVerify) بنفس صيغة
  /// [DynamicLinkHandler.createDynamicLink] للبروفايل: الجهاز المثبَّت يفتح
  /// بروفايل الداعي عبر فرع `profile_` في الـ handler، وصفحة الـ landing تحوّل
  /// أي جهاز غير مثبَّت إلى المتجر.
  ///
  /// الصيغة:
  ///   بدون داعٍ : `<appURL>`
  ///   مع داعٍ   : `<domainURL>/deeplink?data=profile_<inviterUserId>`
  static String buildInviteLink({String? inviterUserId}) {
    if (inviterUserId == null || inviterUserId.trim().isEmpty) {
      return ConstantsManager.appURL.trim().isNotEmpty
          ? ConstantsManager.appURL.trim()
          : _fallbackStoreUrl;
    }

    return '${EndPoints.domainURL}/deeplink?data=profile_${inviterUserId.trim()}';
  }

  /// Builds the friendly invite message (in the user's language) plus the link.
  static String _buildMessage({String? inviterUserId, String? contactName}) {
    final String link = buildInviteLink(inviterUserId: inviterUserId);
    final String appName = ConstantsManager.appDisplayName;
    final String greeting = (contactName != null && contactName.trim().isNotEmpty)
        ? StringManager.inviteGreeting.tr(namedArgs: {'name': contactName.trim()})
        : '';
    return greeting +
        StringManager.inviteShareMessage
            .tr(namedArgs: {'app': appName, 'link': link});
  }

  /// Opens the system share sheet so the invite can be sent through any app
  /// (WhatsApp / Messenger / TikTok / Instagram / ...).
  static Future<void> shareInvite(
    BuildContext context, {
    String? inviterUserId,
    String? contactName,
  }) async {
    try {
      final String message = _buildMessage(
        inviterUserId: inviterUserId,
        contactName: contactName,
      );
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: ConstantsManager.appDisplayName,
        ),
      );
    } catch (_) {
      Methods.showToast(
        context,
        message: StringManager.unableToShare.tr(),
        isError: true,
      );
    }
  }

  /// ينسخ رابط الدعوة إلى الحافظة ويُرجع الرابط المنسوخ.
  static Future<String> copyInviteLink({String? inviterUserId}) async {
    final String link = buildInviteLink(inviterUserId: inviterUserId);
    await Clipboard.setData(ClipboardData(text: link));
    return link;
  }
}
