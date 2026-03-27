import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../core/data/local/app_database.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../bloc/conflict_bloc.dart';
import '../bloc/conflict_event.dart';
import '../bloc/conflict_state.dart';
import '../../../../l10n/app_localizations.dart';

class ConflictScreen extends StatelessWidget {
  const ConflictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    if (authState is! auth.AuthAuthenticatedWithStore) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.conflicts)),
        body: Center(child: Text(l10n.unauthorized)),
      );
    }

    // authState is guaranteed to be AuthAuthenticatedWithStore here (type promotion)
    final storeId = authState.storeId;

    return BlocProvider(
      create: (context) => ConflictBloc(context.read<AppDatabase>())
        ..add(LoadPendingConflicts(storeId)),
      child: _ConflictView(storeId: storeId, userId: authState.user.id),
    );
  }
}

class _ConflictView extends StatelessWidget {
  final String storeId;
  final String userId;

  const _ConflictView({
    required this.storeId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conflicts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ConflictBloc>().add(
              LoadPendingConflicts(storeId),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ConflictBloc, ConflictState>(
        listener: (context, state) {
          if (state is ConflictResolved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.conflictResolved),
                backgroundColor: Colors.green,
              ),
            );
            // Reload conflicts after resolution
            context.read<ConflictBloc>().add(LoadPendingConflicts(storeId));
          } else if (state is ConflictError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConflictLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConflictLoaded) {
            if (state.conflicts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noConflicts,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          label: l10n.pending,
                          value: state.pendingCount.toString(),
                          color: Colors.orange,
                        ),
                        _StatCard(
                          label: l10n.resolved,
                          value: state.resolvedCount.toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),

                // Conflict List
                Expanded(
                  child: ListView.builder(
                    itemCount: state.conflicts.length,
                    itemBuilder: (context, index) {
                      final conflict = state.conflicts[index];
                      return _ConflictCard(
                        conflict: conflict,
                        userId: userId,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final SyncConflict conflict;
  final String userId;

  const _ConflictCard({
    required this.conflict,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localData = jsonDecode(conflict.localValue) as Map<String, dynamic>;
    final remoteData = jsonDecode(conflict.remoteValue) as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          conflict.status == 'pending' ? Icons.warning : Icons.check_circle,
          color: conflict.status == 'pending' ? Colors.orange : Colors.green,
        ),
        title: Text('${conflict.conflictTableName} - ${conflict.recordId}'),
        subtitle: Text(_formatDateTime(conflict.detectedAt)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Local Value
                Text(
                  l10n.localValue,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    _formatData(localData),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),

                // Remote Value
                Text(
                  l10n.remoteValue,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _formatData(remoteData),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),

                // Timestamps
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.localUpdatedAt}: ${_formatDateTime(conflict.localUpdatedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${l10n.remoteUpdatedAt}: ${_formatDateTime(conflict.remoteUpdatedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resolution Buttons (only for pending conflicts)
                if (conflict.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.read<ConflictBloc>().add(
                          ResolveWithLocal(
                            conflictId: conflict.id,
                            resolvedBy: userId,
                            notes: 'Manually resolved: chose local value',
                          ),
                        ),
                        icon: const Icon(Icons.phone_android),
                        label: Text(l10n.keepLocal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.read<ConflictBloc>().add(
                          ResolveWithRemote(
                            conflictId: conflict.id,
                            resolvedBy: userId,
                            notes: 'Manually resolved: chose remote value',
                          ),
                        ),
                        icon: const Icon(Icons.cloud),
                        label: Text(l10n.keepRemote),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                else
                  // Show resolution info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.status}: ${conflict.status}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (conflict.resolvedAt != null)
                          Text(
                            '${l10n.resolvedAt}: ${_formatDateTime(conflict.resolvedAt!)}',
                          ),
                        if (conflict.resolutionNotes != null)
                          Text('${l10n.notes}: ${conflict.resolutionNotes}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatData(Map<String, dynamic> data) {
    return data.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  String _formatDateTime(int milliseconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
