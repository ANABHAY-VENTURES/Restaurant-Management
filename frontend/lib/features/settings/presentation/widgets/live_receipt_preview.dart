// Anabhay Ventures — Live Invoice & 80mm Thermal Receipt Preview Widget
// Phase 7: Real-time visual template switching between 80mm POS slip and A4 Tax Invoice

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/settings_models.dart';

class LiveReceiptPreview extends StatefulWidget {
  final RestaurantProfile profile;
  final TaxBillingConfig taxBilling;
  final InvoiceReceiptConfig invoiceConfig;

  const LiveReceiptPreview({
    super.key,
    required this.profile,
    required this.taxBilling,
    required this.invoiceConfig,
  });

  @override
  State<LiveReceiptPreview> createState() => _LiveReceiptPreviewState();
}

class _LiveReceiptPreviewState extends State<LiveReceiptPreview> {
  late String _format;

  @override
  void initState() {
    super.initState();
    _format = widget.invoiceConfig.defaultFormat;
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${_format == '80mm' ? '80mm Thermal POS Slip' : 'A4 Tax Invoice'} to print dialog.'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Format Switcher Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: const Text('80mm Thermal Receipt'),
                  selected: _format == '80mm',
                  selectedColor: AppColors.champagneGold,
                  labelStyle: TextStyle(
                    color: _format == '80mm' ? AppColors.matteBlack : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _format = '80mm'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('A4 Full Tax Invoice'),
                  selected: _format == 'A4',
                  selectedColor: AppColors.champagneGold,
                  labelStyle: TextStyle(
                    color: _format == 'A4' ? AppColors.matteBlack : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  onSelected: (_) => setState(() => _format = 'A4'),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagneGold,
                foregroundColor: AppColors.matteBlack,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: _printReceipt,
              icon: const Icon(Icons.print_rounded, size: 16),
              label: const Text('Print / Save PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Live Document Frame
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _format == '80mm' ? 320 : 540,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB88746), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _format == '80mm' ? _buildThermalReceipt() : _buildA4Invoice(),
          ),
        ),
      ],
    );
  }

  Widget _buildThermalReceipt() {
    final cfg = widget.invoiceConfig;
    final prof = widget.profile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        if (cfg.showLogo) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF171717), width: 1.5),
            ),
            child: const Icon(Icons.restaurant_rounded, size: 24, color: Color(0xFF171717)),
          ),
          const SizedBox(height: 6),
        ],

        // Name & Tagline
        if (cfg.showRestaurantName) ...[
          Text(
            prof.name.toUpperCase(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF171717), letterSpacing: 1.5),
            textAlign: TextAlign.center,
          ),
          Text(
            prof.tagline,
            style: const TextStyle(fontSize: 9, color: Color(0xFF555555)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
        ],

        // Address & Contacts
        if (cfg.showAddressContact) ...[
          Text(
            prof.address,
            style: const TextStyle(fontSize: 8.5, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          Text(
            'Tel: ${prof.phone} | ${prof.email}',
            style: const TextStyle(fontSize: 8.5, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],

        // Tax Registrations
        if (cfg.showGstin && prof.gstin.isNotEmpty)
          Text('GSTIN: ${prof.gstin}', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
        if (cfg.showFssai && prof.fssai.isNotEmpty)
          Text('FSSAI Lic No: ${prof.fssai}', style: const TextStyle(fontSize: 8.5, color: Color(0xFF444444))),

        const SizedBox(height: 8),
        Text(
          cfg.invoiceTitle,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF171717), letterSpacing: 1.0),
        ),
        const Divider(color: Color(0xFF999999), thickness: 1, height: 16),

        // Metadata
        _thermalMetaRow('Receipt #:', '${cfg.invoicePrefix}8841'),
        _thermalMetaRow('Table / Type:', 'Table 05 • Dine-in'),
        _thermalMetaRow('Date & Time:', DateTime.now().toLocal().toString().split('.')[0]),
        _thermalMetaRow('Cashier / Capt:', 'Anita Roy (CP-01)'),

        if (cfg.showCustomerDetails) ...[
          const Divider(color: Color(0xFFCCCCCC), height: 12),
          _thermalMetaRow('Guest Name:', 'Aarav Malhotra'),
          _thermalMetaRow('Phone:', '+91 98765 43210'),
        ],

        const Divider(color: Color(0xFF999999), thickness: 1, height: 16),

        // Items Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Item & Portion', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
            Text('Qty   Price', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
          ],
        ),
        const Divider(color: Color(0xFFCCCCCC), height: 8),

        // Sample Items
        _thermalItemRow('Murgh Awadhi Dum Biryani (Full)', 2, 760.0),
        _thermalItemRow('+ Extra Chicken Pieces', 2, 160.0),
        _thermalItemRow('Dal Makhani Reserve', 1, 380.0),
        _thermalItemRow('Butter Garlic Naan', 3, 330.0),
        _thermalItemRow('Royal Cold Brew', 2, 320.0),

        const Divider(color: Color(0xFF999999), thickness: 1, height: 16),

        // Subtotals & Tax
        _thermalTotalRow('Subtotal (10 items):', '₹1,950.00'),
        _thermalTotalRow('Discount Applied (VIP 10%):', '- ₹195.00'),

        if (cfg.showTaxBreakdown && widget.taxBilling.isGstEnabled) ...[
          _thermalTotalRow('CGST (${(widget.taxBilling.taxRatePercent / 2).toStringAsFixed(1)}%):', '₹43.88'),
          _thermalTotalRow('SGST (${(widget.taxBilling.taxRatePercent / 2).toStringAsFixed(1)}%):', '₹43.88'),
        ],

        if (widget.taxBilling.serviceChargePercent > 0)
          _thermalTotalRow('Service Charge (${widget.taxBilling.serviceChargePercent}%):', '₹${(1755 * widget.taxBilling.serviceChargePercent / 100).toStringAsFixed(2)}'),

        const Divider(color: Color(0xFF171717), thickness: 1.5, height: 14),

        // Grand Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('GRAND TOTAL:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF171717))),
            Text('₹1,843.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF171717))),
          ],
        ),
        const Divider(color: Color(0xFF171717), thickness: 1.5, height: 14),

        // Payment Tender
        _thermalTotalRow('Tender Method:', 'Demo UPI (Ref #98214)'),

        const SizedBox(height: 12),
        // Footer Message
        Text(
          cfg.thankYouMessage,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF171717)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          cfg.footerMessage,
          style: const TextStyle(fontSize: 7.5, color: Color(0xFF777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildA4Invoice() {
    final cfg = widget.invoiceConfig;
    final prof = widget.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prof.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF171717))),
                Text(prof.tagline, style: const TextStyle(fontSize: 10, color: Color(0xFFB88746), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(prof.address, style: const TextStyle(fontSize: 9, color: Color(0xFF555555))),
                Text('Phone: ${prof.phone} | Email: ${prof.email}', style: const TextStyle(fontSize: 9, color: Color(0xFF555555))),
                if (cfg.showGstin) Text('GSTIN: ${prof.gstin}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(cfg.invoiceTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFB88746))),
                Text('Invoice #: ${cfg.invoicePrefix}0042', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
                Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
                Text('Table: Table 05', style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
              ],
            ),
          ],
        ),
        const Divider(color: Color(0xFFB88746), thickness: 1.5, height: 24),

        if (cfg.showCustomerDetails) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Billed To: Aarav Malhotra (+91 98765 43210)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
              Text('Payment: Demo UPI Settle', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Table
        Container(
          color: const Color(0xFFF5EFEB),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text('Description', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF171717)))),
              Expanded(child: Text('Rate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF171717)))),
              Expanded(child: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF171717)))),
              Expanded(child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF171717)))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _a4Row('Murgh Awadhi Dum Biryani (Full)', 380.0, 2, 760.0),
        _a4Row('Dal Makhani Reserve', 380.0, 1, 380.0),
        _a4Row('Butter Garlic Naan', 110.0, 3, 330.0),
        _a4Row('Royal Cold Brew', 160.0, 2, 320.0),
        const Divider(color: Color(0xFFCCCCCC), height: 16),

        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 220,
            child: Column(
              children: [
                _thermalTotalRow('Subtotal:', '₹1,790.00'),
                if (cfg.showTaxBreakdown) ...[
                  _thermalTotalRow('CGST (2.5%):', '₹44.75'),
                  _thermalTotalRow('SGST (2.5%):', '₹44.75'),
                ],
                const Divider(color: Color(0xFF171717), height: 12),
                _thermalTotalRow('Grand Total:', '₹1,879.50', isBold: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            cfg.thankYouMessage,
            style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Color(0xFF555555)),
          ),
        ),
      ],
    );
  }

  Widget _thermalMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 8.5, color: Color(0xFF555555))),
          Text(value, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
        ],
      ),
    );
  }

  Widget _thermalItemRow(String name, int qty, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 9, color: Color(0xFF222222)))),
          Text('$qty × ₹${(total / qty).toStringAsFixed(0)}  ₹${total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF171717))),
        ],
      ),
    );
  }

  Widget _thermalTotalRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: const Color(0xFF444444), fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: 9.5, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: const Color(0xFF171717))),
        ],
      ),
    );
  }

  Widget _a4Row(String name, double rate, int qty, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 9.5, color: Color(0xFF222222)))),
          Expanded(child: Text('₹${rate.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF444444)))),
          Expanded(child: Text('$qty', style: const TextStyle(fontSize: 9.5, color: Color(0xFF444444)))),
          Expanded(child: Text('₹${total.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF171717)))),
        ],
      ),
    );
  }
}
