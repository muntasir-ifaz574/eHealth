import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _PaymentMethod { card, mobileBanking, netBanking }

/// Pre-payment review step matching the mockup's checkout screen. Pushes to
/// [RouteNames.paymentCheckout] (the real SSLCOMMERZ webview) on confirm.
class PaymentReviewScreen extends StatefulWidget {
  const PaymentReviewScreen({
    super.key,
    required this.consultationId,
    required this.amount,
    required this.userId,
  });

  final int consultationId;
  final num amount;
  final int userId;

  @override
  State<PaymentReviewScreen> createState() => _PaymentReviewScreenState();
}

class _PaymentReviewScreenState extends State<PaymentReviewScreen> {
  // Purely visual/local state — InitiatePaymentDto has no payment-method
  // field, so this selection doesn't change the actual payment call.
  _PaymentMethod _method = _PaymentMethod.card;

  void _payNow() {
    context.pushNamed(
      RouteNames.paymentCheckout,
      pathParameters: {'consultationId': widget.consultationId.toString()},
      extra: {'amount': widget.amount, 'userId': widget.userId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text('Secure Checkout', style: AppTextStyles.headlineLg),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BOOKING SUMMARY', style: AppTextStyles.labelCaps),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: AppColors.electricBlue),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text('৳${widget.amount}', style: AppTextStyles.headlineXl),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('SELECT PAYMENT METHOD', style: AppTextStyles.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<_PaymentMethod>(
              groupValue: _method,
              onChanged: (value) => setState(() => _method = value!),
              child: Column(
                children: [
                  _buildMethodTile(
                    method: _PaymentMethod.card,
                    icon: Icons.credit_card,
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa, MasterCard, Amex',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildMethodTile(
                    method: _PaymentMethod.mobileBanking,
                    icon: Icons.smartphone,
                    title: 'Mobile Banking',
                    subtitle: 'bKash, Nagad, Rocket',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildMethodTile(
                    method: _PaymentMethod.netBanking,
                    icon: Icons.account_balance,
                    title: 'Net Banking',
                    subtitle: 'All major banks supported',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Payments processed securely via SSLCOMMERZ',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: _payNow,
              child: Text('Pay Now  |  ৳${widget.amount}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required _PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _method == method;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: () => setState(() => _method = method),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: selected ? AppColors.electricBlue : AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Radio<_PaymentMethod>(value: method),
            Icon(icon, color: AppColors.onSurface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
