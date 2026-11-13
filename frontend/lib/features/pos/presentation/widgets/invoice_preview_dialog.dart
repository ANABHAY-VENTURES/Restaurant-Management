// Anabhay Ventures — GST Tax Invoice & Thermal Receipt Preview
// Phase 3: Premium Billing & Demonstration Invoice Engine

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/order_models.dart';

class InvoicePreviewDialog extends StatefulWidget {
  final String invoiceNumber;
  final String tableNumber;
  final OrderType orderType;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double cgst;
  final double sgst;
  final double total;
  final String initialPaymentMethod;
  final VoidCallback? onPaymentCompleted;

  const InvoicePreviewDialog({
    super.key,
    required this.invoiceNumber,
    required this.tableNumber,
    required this.orderType,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0.0,
    required this.cgst,
    required this.sgst,
    required this.total,
    this.initialPaymentMethod = 'Demo Cash',
    this.onPaymentCompleted,
  });

  static Future<void> show({
    required BuildContext context,
    required String invoiceNumber,
    required String tableNumber,
    required OrderType orderType,
    required List<OrderItem> items,
    required double subtotal,
    double discountAmount = 0.0,
    required double cgst,
    required double sgst,
    required double total,
    String initialPaymentMethod = 'Demo Cash',
    VoidCallback? onPaymentCompleted,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.85),
      builder: (ctx) => InvoicePreviewDialog(
        invoiceNumber: invoiceNumber,
        tableNumber: tableNumber,
        orderType: orderType,
        items: items,
        subtotal: subtotal,
        discountAmount: discountAmount,
        cgst: cgst,
        sgst: sgst,
        total: total,
        initialPaymentMethod: initialPaymentMethod,
        onPaymentCompleted: onPaymentCompleted,
      ),
    );
  }

  @override
  State<InvoicePreviewDialog> createState() => _InvoicePreviewDialogState();
}

class _InvoicePreviewDialogState extends State<InvoicePreviewDialog> {
  late String _selectedPayment;
  bool _isSettled = false;

  @override
  void initState() {
    super.initState();
    _selectedPayment = widget.initialPaymentMethod;
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulating print job to 80mm thermal receipt printer (ESC/POS)...'),
        backgroundColor: AppColors.champagneGold,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Demo Prototype Watermark Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEMO BILLING PROTOTYPE — NO REAL PAYMENT CHARGED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Restaurant Logo & Header
              const Text(
                'THE ROYAL SAFFRON',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                'ANABHAY VENTURES HOSPITALITY\nPark Street Flagship • Kolkata - 700016\nGSTIN: 19AAECR1234F1Z5 • FSSAI: 12821019000123\nPhone: +91 98300 12345',
                style: TextStyle(color: Colors.black87, fontSize: 11, height: 1.35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: Colors.black38, thickness: 1),

              // Invoice Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice: ${widget.invoiceNumber}', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${widget.tableNumber} (${widget.orderType.label})', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ${DateTime.now().toString().substring(0, 16)}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  const Text('Server: Vikramaditya R.', style: TextStyle(color: Colors.black54, fontSize: 11)),
                ],
              ),
              const Divider(color: Colors.black38, thickness: 1),

              // Items Table Header
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 5, child: Text('ITEM DESCRIPTION', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('RATE', textAlign: TextAlign.right, style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const Divider(color: Colors.black26, thickness: 0.8),

              // Items List
              ...widget.items.map((item) {
                final rate = item.unitPrice + item.addOnsTotal;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${item.name}${item.variantName != null ? ' (${item.variantName})' : ''}',
                              style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('₹${rate.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('₹${item.totalPrice.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      if (item.selectedAddOns.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 1),
                          child: Text(
                            '+ ${item.selectedAddOns.join(', ')}',
                            style: const TextStyle(color: Colors.black54, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ),
                      if (item.specialInstruction != null && item.specialInstruction!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 1),
                          child: Text(
                            'Note: ${item.specialInstruction}',
                            style: const TextStyle(color: Color(0xFFB45309), fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              const Divider(color: Colors.black38, thickness: 1),

              // Financial Calculation Breakdown
              _receiptRow('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}'),
              if (widget.discountAmount > 0)
                _receiptRow('Discount Applied', '-₹${widget.discountAmount.toStringAsFixed(2)}', isDiscount: true),
              _receiptRow('CGST @ 2.50%', '₹${widget.cgst.toStringAsFixed(2)}'),
              _receiptRow('SGST @ 2.50%', '₹${widget.sgst.toStringAsFixed(2)}'),
              const Divider(color: Colors.black54, thickness: 1.5),

              // Grand Total
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GRAND TOTAL (ROUNDED)', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900)),
                    Text(
                      '₹${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payment Method Selector
              if (!_isSettled) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Payment Method (DEMO):',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['Demo Cash', 'Demo UPI', 'Demo Card'].map((method) {
                    final isSel = _selectedPayment == method;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedPayment = method),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF171717) : Colors.grey.shade100,
                            border: Border.all(color: isSel ? const Color(0xFFB88746) : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            method,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? const Color(0xFFB88746) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'PAID VIA $_selectedPayment • SESSION CLOSED',
                        style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Footer Note
              const Text(
                'Thank you for dining at The Royal Saffron!\nWe look forward to serving you again.',
                style: TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black38),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _printReceipt,
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Print Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF171717),
                        foregroundColor: const Color(0xFFB88746),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() => _isSettled = true);
                        if (widget.onPaymentCompleted != null) {
                          widget.onPaymentCompleted!();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        _isSettled ? 'Close' : 'Complete & Settle',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
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

  Widget _receiptRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? const Color(0xFFDC2626) : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
