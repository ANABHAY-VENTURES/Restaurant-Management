// Anabhay Ventures — GST Tax Invoice & Thermal Receipt Preview

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class InvoicePreviewDialog extends StatelessWidget {
  final String invoiceNumber;
  final String tableNumber;
  final String orderType;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double cgst;
  final double sgst;
  final double total;
  final String paymentMethod;

  const InvoicePreviewDialog({
    super.key,
    required this.invoiceNumber,
    required this.tableNumber,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.total,
    required this.paymentMethod,
  });

  static Future<void> show({
    required BuildContext context,
    required String invoiceNumber,
    required String tableNumber,
    required String orderType,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double total,
    required String paymentMethod,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.8),
      builder: (ctx) => InvoicePreviewDialog(
        invoiceNumber: invoiceNumber,
        tableNumber: tableNumber,
        orderType: orderType,
        items: items,
        subtotal: subtotal,
        cgst: cgst,
        sgst: sgst,
        total: total,
        paymentMethod: paymentMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt Header
              const Text(
                'THE ROYAL SAFFRON',
                style: TextStyle(
                  color: AppColors.textOnLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                'Park Street Flagship • Kolkata - 700016\nGSTIN: 19AAECR1234F1Z5 • FSSAI: 12821019000123\nPhone: +91 98300 12345',
                style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: Colors.black26, thickness: 1),
              // Meta info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice: $invoiceNumber', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(tableNumber, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type: $orderType', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  Text('${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                ],
              ),
              const Divider(color: Colors.black26, thickness: 1),
              const SizedBox(height: 4),

              // Itemized List Header
              const Row(
                children: [
                  Expanded(flex: 4, child: Text('ITEM', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(flex: 1, child: Text('QTY', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('RATE', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('AMT', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                ],
              ),
              const SizedBox(height: 6),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text(item['name'] as String, style: const TextStyle(color: Colors.black87, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 1, child: Text('${item['qty']}', style: const TextStyle(color: Colors.black87, fontSize: 12), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('₹${(item['price'] as num).toStringAsFixed(0)}', style: const TextStyle(color: Colors.black87, fontSize: 12), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('₹${((item['price'] as num) * (item['qty'] as num)).toStringAsFixed(0)}', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  ],
                ),
              )),

              const Divider(color: Colors.black26, thickness: 1),
              // Tax Breakup
              _taxRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
              _taxRow('CGST (2.5%)', '₹${cgst.toStringAsFixed(2)}'),
              _taxRow('SGST (2.5%)', '₹${sgst.toStringAsFixed(2)}'),
              const Divider(color: Colors.black87, thickness: 1.5),
              // Total
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GRAND TOTAL', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Divider(color: Colors.black26, thickness: 1),
              // Payment method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Mode:', style: TextStyle(color: Colors.black54, fontSize: 11)),
                  Text(paymentMethod, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Thank you for dining with us!\nVisit again • Powered by Anabhay Ventures',
                style: TextStyle(color: Colors.black54, fontSize: 10, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.matteBlack,
                        side: const BorderSide(color: Colors.black45),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.matteBlack,
                        foregroundColor: AppColors.warmIvory,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sent to Thermal Receipt Printer (58mm/80mm ESC/POS)'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Bill'),
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

  Widget _taxRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 11)),
        ],
      ),
    );
  }
}
