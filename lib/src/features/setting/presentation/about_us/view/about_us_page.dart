import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../../core/index.dart';

/// Professional "About Us" screen with real version info, animated logo,
/// and bilingual (Arabic/English) app description.
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.white,
        iconColor: ColorManager.black,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
        title: StringManager.aboutUs.tr(),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                // Animated logo
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.primary.withValues(alpha: 0.12),
                          ColorManager.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AssetsManager.logo,
                      width: 120.w,
                      height: 120.w,
                    ),
                  ),
                ),

                16.hBox,

                // App name
                Text(
                  StringManager.appName.tr(),
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black,
                  ),
                ),

                8.hBox,

                // Real version from package_info_plus
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Version $_version',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorManager.black.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                32.hBox,

                // App description — admin-managed (bilingual) content from the
                // panel via /config/settings, with a built-in professional
                // fallback description so this card always shows something
                // meaningful even before the admin fills that field in.
                _buildInfoCardChild(
                  title: isArabic ? 'عن التطبيق' : 'About the App',
                  icon: Icons.info_outline,
                  child: HtmlWidget(
                    _aboutUsContent(isArabic),
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: ColorManager.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                16.hBox,

                // Ownership notice — sits ABOVE the feature list so it is the
                // first thing read on this screen, and mirrors the licence
                // header carried by the source itself.
                _buildLicenceCard(isArabic),

                16.hBox,

                _buildInfoCard(
                  title: isArabic ? 'المميزات الرئيسية' : 'Key Features',
                  content: isArabic
                      ? '• غرف صوتية ومرئية مباشرة مع أصدقائك\n• نظام هدايا افتراضية فاخرة ومكافآت\n• ألعاب تفاعلية ومسابقات مباشرة\n• نظام مستويات وشارات وإنجازات\n• دعم فني على مدار الساعة'
                      : '• Live voice & video rooms with friends\n• Premium virtual gifts & rewards\n• Interactive live games & contests\n• Levels, badges & achievements\n• Dedicated 24/7 customer support',
                  icon: Icons.star_outline,
                ),

                16.hBox,

                _buildInfoCard(
                  title: isArabic ? 'تواصل معنا' : 'Contact Us',
                  content: isArabic
                      ? 'نحن هنا لخدمتك! لأي مساعدة أو استفسار أو للإبلاغ عن مشكلة، تواصل معنا عبر البريد الإلكتروني help24imran@gmail.com أو زر موقعنا iamparty.linlive.fr'
                      : 'We\'re here to help! For support, questions, or to report an issue, reach us anytime at help24imran@gmail.com or visit iamparty.linlive.fr',
                  icon: Icons.support_agent_outlined,
                ),

                24.hBox,

                // Footer — this app's own name and ownership, not a
                // third-party vendor's.
                Text(
                  '© ${DateTime.now().year} ${StringManager.appName.tr()}. '
                      '${isArabic ? 'جميع الحقوق محفوظة.' : 'All rights reserved.'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorManager.black.withValues(alpha: 0.5),
                  ),
                ),

                8.hBox,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// This app's own "About the App" description, always shown — no longer
  /// pulled from the backend admin panel, because old/leftover admin text
  /// (RealtimeConfig.aboutUsEn/Ar) kept taking priority and hiding this
  /// app's own description whenever that admin field wasn't empty. Edit the
  /// text below directly to change what's shown in the App.
  String _aboutUsContent(bool isArabic) {
    final appName = StringManager.appName.tr();
    return isArabic
        ? '$appName هو تطبيق بث مباشر ومجتمع اجتماعي نابض بالحياة، حيث يمكنك '
        'استضافة أو الانضمام إلى غرف صوتية ومرئية مباشرة، والتعرف على '
        'أشخاص جدد من جميع أنحاء العالم، وإرسال واستقبال هدايا افتراضية '
        'مميزة، والاستمتاع بالألعاب التفاعلية والمسابقات — كل ذلك في '
        'تطبيق واحد آمن وسهل الاستخدام.'
        : '$appName is a vibrant live-streaming and social community app '
        'where you can host or join live voice & video rooms, meet new '
        'people from around the world, send and receive premium virtual '
        'gifts, and enjoy interactive games and contests — all in one '
        'safe, easy-to-use app.';
  }

  /// Ownership and licensing notice — this app's own name/contact, so the
  /// page identifies the actual owner of this build rather than a
  /// third-party vendor's placeholder details.
  Widget _buildLicenceCard(bool isArabic) {
    final app = StringManager.appName.tr();
    return _buildInfoCardChild(
      title: isArabic ? 'الملكية والترخيص' : 'Ownership & Licence',
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? '$app — جميع الحقوق محفوظة' : '$app — All Rights Reserved',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: ColorManager.black,
            ),
          ),
          8.hBox,
          Text(
            isArabic
                ? 'هذا التطبيق وجميع محتوياته وشيفرته المصدرية مملوكة بالكامل '
                'لـ $app. لا يُسمح بنسخ الشيفرة المصدرية أو تعديلها أو '
                'إعادة توزيعها أو اشتقاق عمل آخر منها دون إذن كتابي مسبق.'
                : 'This application, its source code, design, and content are '
                'owned by $app. Copying, modifying, reverse-engineering, '
                'or redistributing the source code, in whole or in part, '
                'is not permitted without prior written consent.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: ColorManager.black.withValues(alpha: 0.65),
            ),
          ),
          12.hBox,
          Text(
            isArabic ? 'للاستفسار:' : 'For more information:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: ColorManager.black,
            ),
          ),
          6.hBox,
          _contactRow(Icons.mail_outline, 'help24imran@gmail.com'),
          4.hBox,
          _contactRow(Icons.language_outlined, 'iamparty.linlive.fr'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: ColorManager.primary),
        8.wBox,
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorManager.black.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }

  /// Card variant that renders an arbitrary child (e.g. HtmlWidget) instead of
  /// a plain text body — shares the same header/styling as [_buildInfoCard].
  Widget _buildInfoCardChild({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: ColorManager.primary,
                  size: 20.sp,
                ),
              ),
              12.wBox,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black,
                  ),
                ),
              ),
            ],
          ),
          12.hBox,
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: ColorManager.primary,
                  size: 20.sp,
                ),
              ),
              12.wBox,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black,
                  ),
                ),
              ),
            ],
          ),
          12.hBox,
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: ColorManager.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}