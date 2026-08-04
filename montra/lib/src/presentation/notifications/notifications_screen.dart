import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFDF9EE);
    const textColor = Color(0xFF1B3B7B);
    const subTextColor = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: textColor),
            onPressed: () {
              context.push('/notification-settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('TODAY'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.lightbulb_outline,
            iconBgColor: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'Daily Summary',
            time: '10:00 AM',
            description: 'Today\'s Summary: Spent ₹1,240 across 5 transactions. Biggest expense: Swiggy (₹450). ₹580 left for today.',
            actionButtonText: 'View Summary',
          ),
          _buildNotificationCard(
            icon: Icons.chat_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            title: 'New SMS Added',
            time: '09:15 AM',
            description: 'Amazon - ₹1,240. Category: Shopping.',
            isVerified: true,
          ),
          _buildNotificationCard(
            icon: Icons.warning_amber_rounded,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFDC2626),
            title: 'Budget Alert: Food & Dining',
            time: '08:30 AM',
            description: '85% used. ₹150 remaining. You\'re doing great, keep it up!',
            progressValue: 0.85,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('YESTERDAY'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.local_fire_department_outlined,
            iconBgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            title: 'Streak Alert!',
            time: '09:00 PM',
            description: 'You\'ve stayed within your daily budget for 7 consecutive days! Keep the momentum going.',
          ),
          _buildNotificationCard(
            icon: Icons.account_balance_wallet_outlined,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFDC2626),
            title: 'High Spending Alert',
            time: '02:45 PM',
            description: '₹5,400 at Apple Store via Credit Card. Tap to review.',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('EARLIER THIS WEEK'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.calendar_view_week_outlined,
            iconBgColor: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'Weekly Wrap-up',
            time: 'Mon',
            description: '₹8,450 spent (12% less than last week). Top category: Transport. Biggest merchant: Uber.',
          ),
          _buildNotificationCard(
            icon: Icons.cloud_upload_outlined,
            iconBgColor: const Color(0xFFF3F4F6),
            iconColor: const Color(0xFF4B5563),
            title: 'Secure Your Data',
            time: 'Sun',
            description: 'It\'s been 7 days since your last backup. Keep your financial history safe.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    String? actionButtonText,
    bool isVerified = false,
    double? progressValue,
  }) {
    const textColor = Color(0xFF1B3B7B);
    const subTextColor = Color(0xFF4B5563);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconBgColor,
            radius: 24,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, size: 10, color: Color(0xFF059669)),
                                  const SizedBox(width: 4),
                                  const Text('Verified', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (progressValue != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: const Color(0xFF991B1B), // Dark red for budget alert
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                if (actionButtonText != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF), // Light indigo
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionButtonText,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5), // Indigo
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
