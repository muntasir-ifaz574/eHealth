import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/prescriptions/presentation/providers/prescriptions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrescriptionListScreen extends ConsumerWidget {
  const PrescriptionListScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionsForConsultationProvider(consultationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: AsyncValueWidget(
        value: prescriptionsAsync,
        onRetry: () => ref.invalidate(prescriptionsForConsultationProvider(consultationId)),
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return const Center(child: Text('No prescriptions for this consultation yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(prescription.fileName),
                  subtitle: Text('Issued ${prescription.createdAt.toString().substring(0, 16)}'),
                  trailing: FilledButton(
                    onPressed: () => context.pushNamed(
                      RouteNames.prescriptionVerify,
                      pathParameters: {'prescriptionId': prescription.prescriptionId.toString()},
                    ),
                    child: const Text('Verify'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
