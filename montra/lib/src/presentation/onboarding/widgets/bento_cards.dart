import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AutoSmsGraphic extends StatelessWidget {
  const AutoSmsGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SMS Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sms, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text('Bank XYZ', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Payment of ₹450.00 to Starbucks was successful.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurface),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Icon(Icons.arrow_downward, color: AppTheme.primary, size: 32),
          ),

          // Transaction Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.secondaryContainer,
                  child: Icon(Icons.local_cafe, color: AppTheme.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starbucks', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                      Text('Coffee & Snacks', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(
                  '-₹450.00',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialHabitsBento extends StatelessWidget {
  const FinancialHabitsBento({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Analytics Card
          Positioned(
            right: 0,
            top: 20,
            width: 200,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Trend', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bar(height: 30, color: AppTheme.primary.withValues(alpha: 0.3)),
                      _Bar(height: 50, color: AppTheme.primary.withValues(alpha: 0.3)),
                      _Bar(height: 25, color: AppTheme.primary.withValues(alpha: 0.3)),
                      const _Bar(height: 70, color: AppTheme.primary),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Central Main Savings Glass Card
          Positioned(
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.secondaryContainer,
                        child: Icon(Icons.savings, color: AppTheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Savings', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                          Text('₹1,24,500', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target: ₹1.5L', style: Theme.of(context).textTheme.labelMedium),
                      Text('83%', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(
                    value: 0.83,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;

  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class PrivacyShieldGraphic extends StatelessWidget {
  const PrivacyShieldGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 64, color: AppTheme.primary),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 28, color: AppTheme.secondary),
              SizedBox(width: 16),
              Icon(Icons.smartphone, size: 28, color: AppTheme.tertiary),
            ],
          )
        ],
      ),
    );
  }
}
