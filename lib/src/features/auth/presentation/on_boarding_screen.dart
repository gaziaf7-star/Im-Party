import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/index.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final List<String> titles = [
    StringManager.onBoarding1title.tr(),
    StringManager.onBoarding2title.tr(),
    StringManager.onBoarding3title.tr(),
  ];

  final List<String> subTitles = [
    StringManager.onBoarding1Subtitlt.tr(),
    StringManager.onBoarding2Subtitlt.tr(),
    StringManager.onBoarding3Subtitlt.tr(),
  ];

  final List<String> images = [
    AssetsManager.onboarding1,
    AssetsManager.onboarding2,
    AssetsManager.onboarding3,
  ];

  final List<String> buttonText = [
    StringManager.next.tr(),
    StringManager.next.tr(),
    StringManager.getStarted.tr(),
  ];

  final PageController pageController = PageController();

  int currentPage = 0;
  static bool isFirstTime = true;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (currentPage < titles.length - 1) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.intro,
          (_) => false,
    );

    await Methods.saveOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final horizontalPadding =
            (constraints.maxWidth * 0.065).clamp(20.0, 30.0);
            final bottomPadding = (screenHeight * 0.028).clamp(18.0, 28.0);

            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: titles.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() => currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnBoardingBody(
                        image: images[index],
                        title: titles[index],
                        subTitle: subTitles[index],
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 10,
                  ),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: pageController,
                        count: titles.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 7,
                          dotWidth: 7,
                          expansionFactor: 3.4,
                          spacing: 7,
                          activeDotColor: Colors.black,
                          dotColor: Color(0xFFD9D9DE),
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight * 0.035).clamp(22.0, 32.0),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            buttonText[currentPage],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: bottomPadding),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnBoardingBody extends StatelessWidget {
  final String title;
  final String subTitle;
  final String image;

  const _OnBoardingBody({
    required this.title,
    required this.subTitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding =
        (constraints.maxWidth * 0.065).clamp(20.0, 30.0);
        final topPadding = (constraints.maxHeight * 0.045).clamp(22.0, 42.0);
        final imageHeight = (constraints.maxHeight * 0.52).clamp(280.0, 470.0);
        final titleSize = (constraints.maxWidth * 0.068).clamp(24.0, 30.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: imageHeight,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFECECF0),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              SizedBox(
                height: (constraints.maxHeight * 0.055).clamp(28.0, 44.0),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: titleSize,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  subTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF606168),
                    fontSize: 15.5,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
