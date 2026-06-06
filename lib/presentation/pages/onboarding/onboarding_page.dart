import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.onboardingDoneKey) ?? false;
}

Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.onboardingDoneKey, true);
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color bgColor;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.bgColor,
  });
}

const _slides = [
  _OnboardingSlide(
    title: 'Track Every Birr',
    subtitle:
        'Record your income and expenses in seconds. '
        'Stay on top of your finances with a clear, '
        'up-to-date balance at a glance.',
    icon: Icons.account_balance_wallet_outlined,
    primaryColor: Color(0xFF54B998),
    bgColor: Color(0xFFEAF7F2),
  ),
  _OnboardingSlide(
    title: 'Works Offline Too',
    subtitle:
        'Your data is saved locally first so the app '
        'works even without internet. When you come '
        'back online, everything syncs to the cloud automatically.',
    icon: Icons.cloud_sync_outlined,
    primaryColor: Color(0xFF4A90E2),
    bgColor: Color(0xFFEAF2FB),
  ),
  _OnboardingSlide(
    title: 'Smart Filtering',
    subtitle:
        'Instantly search, filter by date, type, or '
        'category, and drill into any transaction for '
        'the full details — including payment method and reference ID.',
    icon: Icons.filter_list_rounded,
    primaryColor: Color(0xFFE2844A),
    bgColor: Color(0xFFFBF0EA),
  ),
];

class OnboardingPage extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingPage({super.key, required this.onDone});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    markOnboardingDone();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentIndex];
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: slide.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isLast ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: slide.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (_, i) => _SlideContent(slide: _slides[i]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => _Dot(
                        isActive: i == _currentIndex,
                        color: slide.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slide.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          key: ValueKey(isLast),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: slide.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 90,
              color: slide.primaryColor,
            ),
          ),
          const SizedBox(height: 48),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _Dot({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


