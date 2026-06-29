import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uts_1123150013/core/routes/app_router.dart';
import 'package:uts_1123150013/core/services/global_institute_pay_service.dart';
import 'package:uts_1123150013/features/order/data/models/order_model.dart';
import 'package:uts_1123150013/features/order/data/presentation/providers/order_provider.dart';
import 'package:provider/provider.dart';

class PaymentPendingPage extends StatefulWidget {
  final OrderModel order;

  const PaymentPendingPage({super.key, required this.order});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage>
    with WidgetsBindingObserver {
  bool _payLaunched = false;
  StreamSubscription<PaymentCallbackData>? _callbackSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Auto-launch Dompet Kampus Global
    if (widget.order.paymentMethod == 'global_institute_pay') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _launchGlobalInstitutePay());
    }

    // 2. Polling backend (tetap berjalan sebagai fallback)
    final orderProv = context.read<OrderProvider>();
    orderProv.startPaymentPolling(widget.order.id);

    // 3. Tangani cold start callback
    final pending = GlobalInstitutePayService().consumePendingCallback();
    if (pending != null && pending.isSuccess) {
      debugPrint('[PaymentPendingPage] Cold start success callback consumed');
      WidgetsBinding.instance.addPostFrameCallback((_) => _onPaymentSuccess());
    }

    // 4. Subscribe stream callback (app sedang berjalan)
    _callbackSub = GlobalInstitutePayService().onCallback.listen((data) {
      debugPrint('[PaymentPendingPage] Stream callback received status=${data.status}');
      if (!mounted) return;
      if (data.isSuccess) {
        _onPaymentSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran gagal (status: ${data.status})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _callbackSub?.cancel(); // batalkan subscription saat page ditutup
    WidgetsBinding.instance.removeObserver(this);
    context.read<OrderProvider>().stopPaymentPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _payLaunched) {
      debugPrint('[PaymentPendingPage] App resumed, checking payment status via polling once');
      context.read<OrderProvider>().checkPaymentStatus(widget.order.id);
    }
  }

  Future<void> _launchGlobalInstitutePay() async {
    final notes = widget.order.notes.isNotEmpty ? widget.order.notes : null;
    final deeplinkUrl = GlobalInstitutePayService.buildDeeplinkUrl(
      orderId: widget.order.id,
      amount: widget.order.totalAmount,
      description: notes,
    );
    final uri = Uri.parse(deeplinkUrl);
    debugPrint('[PaymentPendingPage] Attempting to launch: $uri');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _payLaunched = true);
    } catch (e) {
      debugPrint('[PaymentPendingPage] launchUrl failed: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Aplikasi Tidak Ditemukan'),
          content: const Text(
            'Aplikasi Dompet Kampus Global tidak terpasang atau tidak dapat dibuka di perangkat ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  void _onPaymentSuccess() {
    context.read<OrderProvider>().stopPaymentPolling();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.orderSuccess,
      (route) => route.settings.name == AppRouter.dashboard,
      arguments: context.read<OrderProvider>().lastOrder ?? widget.order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final payStatus = orderProv.paymentCheckStatus;
    final order = orderProv.lastOrder ?? widget.order;

    if (payStatus == PaymentCheckStatus.paid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onPaymentSuccess());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showCancelConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selesaikan Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCancelConfirmation,
          ),
        ),
        body: order.paymentMethod == 'virtual_account'
            ? _VirtualAccountBody(
                order: order,
                payStatus: payStatus,
                formatPrice: _formatPrice,
                onCheckStatus: () =>
                    context.read<OrderProvider>().checkPaymentStatus(order.id),
              )
            : _GlobalInstitutePayBody(
                order: order,
                payStatus: payStatus,
                formatPrice: _formatPrice,
                payLaunched: _payLaunched,
                onOpenApp: _launchGlobalInstitutePay,
                onCheckStatus: () =>
                    context.read<OrderProvider>().checkPaymentStatus(order.id),
              ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Pesanan tetap tersimpan. Kamu bisa bayar nanti di halaman "Pesanan Saya".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Lanjutkan Bayar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.dashboard,
                (route) => false,
              );
            },
            child: Text(
              'Bayar Nanti',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Virtual Account Body
// ──────────────────────────────────────────────────────────────

class _VirtualAccountBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus payStatus;
  final String Function(double) formatPrice;
  final VoidCallback onCheckStatus;

  const _VirtualAccountBody({
    required this.order,
    required this.payStatus,
    required this.formatPrice,
    required this.onCheckStatus,
  });

  static const List<_BankInfo> _banks = [
    _BankInfo('BCA', '888', Color(0xFF003087)),
    _BankInfo('Mandiri', '888', Color(0xFF003087)),
    _BankInfo('BNI', '8808', Color(0xFF004B87)),
    _BankInfo('BRI', '889', Color(0xFF00529B)),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final vaNumber = order.vaNumber ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card,
                size: 40,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Selesaikan Pembayaran via Virtual Account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Order #${order.id} · ${formatPrice(order.totalAmount)}',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Nomor Virtual Account'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    vaNumber,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vaNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor VA disalin'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Salin nomor VA',
                  color: primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 14, color: onSurface),
                ),
                Text(
                  formatPrice(order.totalAmount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Cara Pembayaran'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < _banks.length; i++) ...[
                  _BankStepTile(bank: _banks[i], vaNumber: vaNumber),
                  if (i < _banks.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          _CheckStatusButton(payStatus: payStatus, onPressed: onCheckStatus),
          const SizedBox(height: 16),
          if (payStatus == PaymentCheckStatus.idle)
            Center(
              child: Text(
                'Belum ada pembayaran terdeteksi',
                style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.5),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BankInfo {
  final String name;
  final String prefix;
  final Color color;
  const _BankInfo(this.name, this.prefix, this.color);
}

class _BankStepTile extends StatelessWidget {
  final _BankInfo bank;
  final String vaNumber;
  const _BankStepTile({required this.bank, required this.vaNumber});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bank.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            bank.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: bank.color,
            ),
          ),
        ),
      ),
      title: Text(
        bank.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      subtitle: Text(
        'Pilih Transfer → Virtual Account → masukkan nomor VA',
        style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5)),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Global Institute Pay Body
// ──────────────────────────────────────────────────────────────

class _GlobalInstitutePayBody extends StatelessWidget {
  final OrderModel order;
  final PaymentCheckStatus payStatus;
  final String Function(double) formatPrice;
  final bool payLaunched;
  final VoidCallback onOpenApp;
  final VoidCallback onCheckStatus;

  const _GlobalInstitutePayBody({
    required this.order,
    required this.payStatus,
    required this.formatPrice,
    required this.payLaunched,
    required this.onOpenApp,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final campusBlue = const Color(0xFF1A237E);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: campusBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              size: 46,
              color: campusBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Global Institute Pay',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Order #${order.id} · ${formatPrice(order.totalAmount)}',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Banner Keamanan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keamanan Terjamin: Pembayaran ini memerlukan verifikasi PIN dan 2FA di Dompet Kampus Global.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepItem(
                  number: '1',
                  text: payLaunched
                      ? 'Aplikasi Dompet Kampus sudah dibuka'
                      : 'Kamu akan diarahkan ke aplikasi Dompet Kampus Global',
                  done: payLaunched,
                ),
                const SizedBox(height: 14),
                _StepItem(
                  number: '2',
                  text:
                      'Konfirmasi pembayaran ${formatPrice(order.totalAmount)} dengan PIN + 2FA',
                  done: false,
                ),
                const SizedBox(height: 14),
                _StepItem(
                  number: '3',
                  text: 'Kembali ke aplikasi — status otomatis diperbarui',
                  done: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: campusBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: Text(
                payLaunched ? 'Buka Kembali Dompet Kampus' : 'Buka Dompet Kampus Global',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onOpenApp,
            ),
          ),
          const SizedBox(height: 12),
          _CheckStatusButton(payStatus: payStatus, onPressed: onCheckStatus),
          const SizedBox(height: 16),
          if (payStatus == PaymentCheckStatus.idle && payLaunched)
            Text(
              'Sedang menunggu konfirmasi pembayaran dari Dompet Kampus Global...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: onSurface.withOpacity(0.5)),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;
  final bool done;
  const _StepItem({
    required this.number,
    required this.text,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? Colors.green
                : Theme.of(context).colorScheme.primary.withOpacity(0.12),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: TextStyle(fontSize: 14, color: onSurface)),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared Widgets
// ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _CheckStatusButton extends StatelessWidget {
  final PaymentCheckStatus payStatus;
  final VoidCallback onPressed;
  const _CheckStatusButton({required this.payStatus, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isChecking = payStatus == PaymentCheckStatus.checking;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        icon: isChecking
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : const Icon(Icons.refresh_rounded),
        label: Text(
          isChecking ? 'Memeriksa Status...' : 'Cek Status Pembayaran',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: isChecking ? null : onPressed,
      ),
    );
  }
}
