import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/custom_button.dart';

class RatePickupScreen extends StatefulWidget {
  const RatePickupScreen({super.key});

  @override
  State<RatePickupScreen> createState() => _RatePickupScreenState();
}

class _RatePickupScreenState extends State<RatePickupScreen> {
  int _rating = 4;
  final Set<String> _selectedFeedback = {'On Time'};

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Rate Pickup / पिकअप रेट करें',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Agent Image / Animation Placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleUser,
                    size: 120,
                    color: Colors.green.shade100,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/Scrapify-app-icon.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const AppSectionHeader(
              title: 'How was your pickup?',
              subtitle: 'पिकअप कैसा रहा?',
            ),
            const SizedBox(height: 16),
            const Text(
              'Rate your experience with Agent Rajesh\nKumar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidStar,
                    size: 40,
                    color: index < _rating
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 48),

            const Text(
              'QUICK FEEDBACK / त्वरित प्रतिक्रिया',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),

            // Grid of Feedback Chips
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildFeedbackChip(
                  'On Time',
                  'समय पर',
                  FontAwesomeIcons.solidClock,
                  isSelected: _selectedFeedback.contains('On Time'),
                ),
                _buildFeedbackChip(
                  'Fair Price',
                  'सही दाम',
                  FontAwesomeIcons.dollarSign,
                  isSelected: _selectedFeedback.contains('Fair Price'),
                ),
                _buildFeedbackChip(
                  'Polite',
                  'अच्छा व्यवहार',
                  FontAwesomeIcons.solidFaceSmile,
                  isSelected: _selectedFeedback.contains('Polite'),
                ),
                _buildFeedbackChip(
                  'Clean',
                  'सफाई',
                  FontAwesomeIcons.broom,
                  isSelected: _selectedFeedback.contains('Clean'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comment Box
            AppCard(
              padding: EdgeInsets.zero,
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a comment... / अपनी बात लिखें...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '0/200',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'SUBMIT  /  सबमिट करें',
                onPressed: () {
                  // Submit Rating
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackChip(
    String en,
    String hi,
    IconData icon, {
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFeedback.remove(en);
          } else {
            _selectedFeedback.add(en);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              en,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            Text(
              hi,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.82)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
