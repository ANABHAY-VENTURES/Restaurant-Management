// Anabhay Ventures — Printable QR Standee Sheet for All Tables
// Formats all table standees in a multi-card printable grid layout for table acrylic holders

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import 'qr_painter.dart';

class PrintableQrSheetDialog extends StatelessWidget {
  final List<RestaurantTable> tables;

  const PrintableQrSheetDialog({super.key, required this.tables});

  static void show(BuildContext context, List<RestaurantTable> tables) {
    showDialog(
      context: context,
      builder: (_) => PrintableQrSheetDialog(tables: tables),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Printable Table QR Standee Sheet', style: AppTypography.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Ready-to-print acrylic standee cards for all ${tables.length} tables • Standard 4"×6" card ratio',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Prepared print spool with ${tables.length} tabletop standee cards.'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Print Complete Sheet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textTertiary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: AppColors.borderSubtle, height: 24),

            // Scrollable Grid of Standees
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 380,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final t = tables[index];
                  final url = 'https://royalsaffron.anabhay.com/#/qr/${Uri.encodeComponent(t.number)}';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB88746), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'THE ROYAL SAFFRON',
                              style: TextStyle(
                                color: Color(0xFF171717),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Text(
                              'FINE DINE & AWADHI CUISINE',
                              style: TextStyle(
                                color: Color(0xFFB88746),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171717),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                t.number.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFF3EBDD),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            QrCodeWidget(
                              data: url,
                              size: 130,
                              darkColor: const Color(0xFF171717),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Scan to Order from Phone',
                              style: TextStyle(
                                color: Color(0xFF171717),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'No app download required',
                              style: TextStyle(
                                color: Color(0xFF88847C),
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Divider(height: 12, color: Color(0xFFE0E0E0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi, size: 10, color: Color(0xFFB88746)),
                                const SizedBox(width: 4),
                                Text(
                                  'Wi-Fi: RoyalSaffron | Zone: ${t.zone}',
                                  style: const TextStyle(fontSize: 7.5, color: Color(0xFF424242)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
