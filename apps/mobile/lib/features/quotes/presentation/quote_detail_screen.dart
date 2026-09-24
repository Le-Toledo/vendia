import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/delete_confirmation.dart';
import 'package:flutter/foundation.dart';

class QuoteDetailScreen extends ConsumerStatefulWidget {
  const QuoteDetailScreen({super.key, required this.quote});
  final Map<String, dynamic> quote;

  @override
  ConsumerState<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends ConsumerState<QuoteDetailScreen> {
  late Map<String, dynamic> _quote = widget.quote;
  bool _busy = false;

  Future<void> _updateStatus(String status) async {
    final items = (_quote['items'] as List? ?? const []);
    setState(() => _busy = true);
    try {
      _quote = await ref.read(businessRepositoryProvider).save('/quotes', {
        'clientId': _quote['clientId'],
        'discount': double.parse(_quote['discount'].toString()),
        'notes': _quote['notes'] ?? '',
        'status': status,
        'items': items
            .map(
              (item) => {
                'description': item['description'],
                'quantity': item['quantity'],
                'unitPrice': double.parse(item['unitPrice'].toString()),
              },
            )
            .toList(),
      }, id: _quote['id'] as String);
      ref.invalidate(quotesProvider);
      if (mounted) setState(() => _busy = false);
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        _showError(error);
      }
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .get<List<int>>(
            '/quotes/${_quote['id']}/pdf',
            options: Options(responseType: ResponseType.bytes),
          );
      final code = (_quote['codeNumber'] ?? 'orcamento').toString().replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );

      if (!mounted) return;

      final size = MediaQuery.sizeOf(context);

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(response.data!),
                mimeType: 'application/pdf',
                name: 'Orcamento_$code.pdf',
              ),
            ],
            title: 'Orçamento $code',
            text: 'Segue o orçamento $code.',
            sharePositionOrigin: Rect.fromCenter(
              center: size.center(Offset.zero),
              width: 1,
              height: 1,
            ),
          ),
        );
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/Orcamento_$code.pdf');

        await file.writeAsBytes(response.data!, flush: true);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/pdf')],
            title: 'Orçamento $code',
            text: 'Segue o orçamento $code.',
            sharePositionOrigin: Rect.fromCenter(
              center: size.center(Offset.zero),
              width: 1,
              height: 1,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _duplicate() async {
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .post('/quotes/${_quote['id']}/duplicate');
      final copy = ref
          .read(apiClientProvider)
          .unwrap<Map<String, dynamic>>(response);
      ref.invalidate(quotesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Orçamento duplicado.')));
        context.replace('/quotes/detail', extra: copy);
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    await context.push('/quotes/new', extra: _quote);
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      _quote = await ref
          .read(businessRepositoryProvider)
          .get('/quotes/${_quote['id']}');
      ref.invalidate(quotesProvider);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final confirmed = await confirmDeletion(context, 'orçamento');
      if (!mounted || !confirmed) return;
      await ref
          .read(businessRepositoryProvider)
          .delete('/quotes/${_quote['id']}');
      if (!mounted) return;
      ref.invalidate(quotesProvider);
      ref.invalidate(clientsProvider);
      ref.invalidate(dashboardProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Orçamento excluído.')));
      context.go('/quotes');
    } catch (error) {
      if (mounted) _showError(deletionError(error, 'orçamento'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(error.toString())));

  @override
  Widget build(BuildContext context) {
    final items = _quote['items'] as List? ?? const [];
    final status = _quote['status'] as String? ?? 'DRAFT';
    return Scaffold(
      appBar: AppBar(
        title: Text(_quote['codeNumber']?.toString() ?? 'Orçamento'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: _busy ? null : _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            enabled: !_busy,
            tooltip: 'Ações do orçamento',
            onSelected: (value) {
              if (value == 'duplicate') _duplicate();
              if (value == 'delete') _delete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir orçamento')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) const LinearProgressIndicator(),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_quote['client'] as Map?)?['name']?.toString() ?? 'Cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items:
                      const {
                            'DRAFT': 'Rascunho',
                            'SENT': 'Enviado',
                            'APPROVED': 'Aprovado',
                            'REJECTED': 'Rejeitado',
                            'CANCELLED': 'Cancelado',
                          }.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                  onChanged: _busy ? null : (value) => _updateStatus(value!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Itens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item['description'].toString()),
              subtitle: Text(
                '${item['quantity']} × ${Formatters.currency(double.parse(item['unitPrice'].toString()))}',
              ),
              trailing: Text(
                Formatters.currency(
                  double.parse(item['totalPrice'].toString()),
                ),
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                Formatters.currency(double.parse(_quote['total'].toString())),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
          if ((_quote['notes'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Observações', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(_quote['notes'].toString()),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir orçamento'),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _busy ? null : _sharePdf,
            icon: const Icon(Icons.ios_share),
            label: const Text('Compartilhar PDF'),
          ),
        ],
      ),
    );
  }
}
