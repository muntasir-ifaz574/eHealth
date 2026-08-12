import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/features/payments/domain/usecases/initiate_payment.dart';
import 'package:ehealth/features/payments/presentation/providers/payments_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.consultationId,
    required this.amount,
    required this.userId,
  });

  final int consultationId;
  final num amount;
  final int userId;

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  WebViewController? _controller;
  String? _errorMessage;
  String? _transactionId;

  @override
  void initState() {
    super.initState();
    _initiate();
  }

  Future<void> _initiate() async {
    final result = await ref
        .read(initiatePaymentProvider)
        .call(
          InitiatePaymentParams(
            amount: widget.amount,
            userId: widget.userId,
            consultationId: widget.consultationId,
          ),
        );
    if (!mounted) return;
    result.fold((failure) => setState(() => _errorMessage = failure.message), (
      initiation,
    ) {
      _transactionId = initiation.transactionId;
      setState(() {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(onNavigationRequest: _onNavigationRequest),
          )
          ..loadRequest(Uri.parse(initiation.gatewayUrl));
      });
    });
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url.toLowerCase();
    if (url.contains('success')) {
      _confirmSuccessAndNavigate(request.url);
      return NavigationDecision.prevent;
    }
    if (url.contains('cancel') || url.contains('fail')) {
      _goToResult(success: false);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _confirmSuccessAndNavigate(String redirectUrl) async {
    final queryParams = Uri.parse(redirectUrl).queryParameters;
    await ref.read(confirmPaymentSuccessProvider).call({
      ...queryParams,
      'consultationId': widget.consultationId,
      if (_transactionId != null) 'tran_id': _transactionId,
    });
    if (!mounted) return;
    _goToResult(success: true);
  }

  void _goToResult({required bool success}) {
    context.pushReplacementNamed(
      RouteNames.paymentResult,
      extra: {'success': success},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller!),
    );
  }
}
