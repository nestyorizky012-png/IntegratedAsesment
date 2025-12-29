import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../providers/assessment_provider.dart';

import '../../widgets/bottom_nav.dart';


class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();
    final items = p.portfolio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portofolio Digital'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (_) => false,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (_) => false,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text('Belum ada portofolio. Selesaikan asesmen dan isi refleksi.'),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final e = items[i];
                          return Card(
                            child: ExpansionTile(
                              title: Text('Asesmen • ${_fmt(e.createdAt)}'),
                              subtitle: Text(
                                'Skor: ${e.answerScore}/${e.totalQuestions} • Alasan: ${e.reasoningScore}/${e.totalQuestions}',
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                const SizedBox(height: 8),
                                _block(context, '1) Yang paling dipahami', e.q1Reflection),
                                _block(context, '2) Yang masih sulit', e.q2Reflection),
                                _block(context, '3) Strategi selanjutnya', e.q3Reflection),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _block(BuildContext context, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}
