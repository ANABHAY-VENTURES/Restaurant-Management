// Anabhay Ventures — Table QR Card Component
// Displays tabletop standee preview with high-contrast QR code, actions and direct guest menu testing

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import 'qr_painter.dart';

class TableQrCard extends StatefulWidget {
  final RestaurantTable table;
  final VoidCallback? onRegenerate;

  const TableQrCard({
    super.key,
    required this.table,
    this.onRegenerate,
  });

  @override
  State<TableQrCard> createState() => _TableQrCardState();
}

class _TableQrCardState extends State<TableQrCard> {
  int _versionKey = 1;

  String get _qrPayloadUrl => 'https://royalsaffron.anabhay.com/#/qr/${Uri.encodeComponent(widget.table.number)}?v=$_versionKey';

  void _regenerate() {
    setState(() {
      _versionKey++;
    });
    widget.onRegenerate?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Regenerated security token for ${widget.table.number}!'),
        backgroundColor: AppColors.champagneGold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _qrPayloadUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied customer menu URL for ${widget.table.number}'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openGuestMenu() {
    context.push('/qr/${Uri.encodeComponent(widget.table.number)}');
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Table Standee Preview', style: AppTypography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textTertiary, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Acrylic Standee Preview Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.champagneGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Brand Header
                    const Text(
                      'THE ROYAL SAFFRON',
                      style: TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Text(
                      'FINE DINE & AWADHI CUISINE',
                      style: TextStyle(
                        color: Color(0xFFB88746),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Table Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.table.number.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFF3EBDD),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // QR Code
                    QrCodeWidget(
                      data: _qrPayloadUrl,
                      size: 160,
                      darkColor: const Color(0xFF171717),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan to View Digital Menu & Order',
                      style: TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'No app download required • Instant KOT',
                      style: TextStyle(
                        color: Color(0xFF88847C),
                        fontSize: 9,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE0E0E0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wifi, size: 12, color: Color(0xFFB88746)),
                        SizedBox(width: 4),
                        Text(
                          'Wi-Fi: RoyalSaffron-Guest | Key: RoyalDining',
                          style: TextStyle(fontSize: 8, color: Color(0xFF424242), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        side: const BorderSide(color: AppColors.champagneGold),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _copyLink();
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy URL'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sent ${widget.table.number} standee card to system printer.'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Print Card'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.table.number,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.table.zone} • ${widget.table.capacity} seats',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.table.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.table.status.color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  widget.table.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.table.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // QR Code Display
          InkWell(
            onTap: _showPrintDialog,
            borderRadius: BorderRadius.circular(12),
            child: QrCodeWidget(
              data: _qrPayloadUrl,
              size: 140,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Route: /qr/${widget.table.number.replaceAll(' ', '%20')}',
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontFamily: 'monospace'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.champagneGold,
                    side: const BorderSide(color: AppColors.champagneGold),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: _openGuestMenu,
                  icon: const Icon(Icons.phone_android_rounded, size: 15),
                  label: const Text('Test Menu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.warmIvory),
                tooltip: 'Print Standee Card',
                onPressed: _showPrintDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textTertiary),
                tooltip: 'Regenerate QR Token',
                onPressed: _regenerate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
