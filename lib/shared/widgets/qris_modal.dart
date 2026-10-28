import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme.dart';
import '../../core/utils/currency_formatter.dart';
import 'custom_button.dart';

class QrisModal extends StatelessWidget {
  final String recipientName;
  final double amount;
  final String note;
  final VoidCallback onConfirmPayment;

  const QrisModal({
    super.key,
    required this.recipientName,
    required this.amount,
    required this.note,
    required this.onConfirmPayment,
  });

  static Future<void> show(
    BuildContext context, {
    required String recipientName,
    required double amount,
    required String note,
    required VoidCallback onConfirmPayment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QrisModal(
        recipientName: recipientName,
        amount: amount,
        note: note,
        onConfirmPayment: onConfirmPayment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final displayName = recipientName.trim().isEmpty ? 'putrivbri' : recipientName;
    final qrisPayload = '00020101021226580016ID.SPLITBILL.WWW0118936009990000000000520458125303360540${amount.toInt()}5802ID5913${displayName}6007JAKARTA6304';

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Header Row with Title and Close icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Bayar via QRIS',
                          style: AppText.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pindai dengan GoPay, OVO, Dana, BCA, atau Livin',
                          style: AppText.bodySm.copyWith(
                            color: palette.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: palette.onSurfaceVariant,
                    tooltip: 'Tutup',
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // QR Code Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.cardBorder, width: 2),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    // Top header logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'QRIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'QR Standar Pembayaran Nasional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: qrisPayload,
                      version: QrVersions.auto,
                      size: 190,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0F172A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NMID: ID1020092817290',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Amount pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: palette.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppText.bodyMedium.copyWith(
                        color: palette.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: AppText.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Action button
              CustomButton(
                text: 'Saya Sudah Transfer / Bayar',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirmPayment();
                },
              ),
              const SizedBox(height: 10),
              // Dedicated Tutup button
              CustomButton(
                text: 'Tutup',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
