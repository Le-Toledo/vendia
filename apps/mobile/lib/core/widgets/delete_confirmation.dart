import 'package:flutter/material.dart';
import '../network/api_client.dart';

Future<bool> confirmDeletion(BuildContext context, String item) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Excluir $item?'),
          content: const Text('Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ) ??
      false;
}

String deletionError(Object error, String item) {
  if (error is ApiException) {
    if (error.statusCode == 401) {
      return 'Sua sessão expirou. Entre novamente para excluir o $item.';
    }
    if (error.statusCode == 404) {
      return 'Este $item não foi encontrado. Atualize a lista e tente novamente.';
    }
    if (error.statusCode == 403) {
      return 'Você não tem permissão para excluir este $item.';
    }
    if (error.statusCode == 409) return error.message;
    if (error.statusCode == null) {
      return 'Não foi possível confirmar a exclusão do $item. Verifique sua conexão e atualize a lista antes de tentar novamente.';
    }
  }
  return 'Não foi possível excluir o $item. Tente novamente em instantes.';
}
