import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/features/payments/domain/usecases/initiate_payment.dart';
import 'package:ehealth/features/payments/presentation/providers/payments_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Loads the gateway URL returned by `POST doctor/payments/initiate` and
/// watches for the redirect the gateway sends the browser to afterwards.
/// The exact redirect URL pattern isn't specified by the backend doc, so
/// this matches on 'success'/'cancel'/'fail' appearing in the URL — adjust
/// once the real gateway's redirect URLs are known.
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
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  WebViewController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initiate();
  }

  Future<void> _initiate() async {
    final result = await ref.read(initiatePaymentProvider).call(
          InitiatePaymentParams(
            amount: widget.amount,
            userId: widget.userId,
            consultationId: widget.consultationId,
          ),
        );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _errorMessage = failure.message),
      (initiation) {
        setState(() {
          _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(onNavigationRequest: _onNavigationRequest),
            )
            ..loadRequest(Uri.parse(initiation.gatewayUrl));
        });
      },
    );
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url.toLowerCase();
    if (url.contains('success')) {
      _goToResult(success: true);
      return NavigationDecision.prevent;
    }
    if (url.contains('cancel') || url.contains('fail')) {
      _goToResult(success: false);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
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
