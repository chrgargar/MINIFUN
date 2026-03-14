/// Estados posibles de sincronización
enum SyncStatus {
  /// Sin cambios pendientes
  synced,

  /// Hay cambios pendientes de sincronizar
  pending,

  /// Sincronización en progreso
  syncing,

  /// Error en la última sincronización
  error,

  /// Sin conexión (offline)
  offline,
}

/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final int syncedItems;
  final int failedItems;
  final String? errorMessage;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.syncedItems = 0,
    this.failedItems = 0,
    this.errorMessage,
  }) : timestamp = DateTime.now();

  factory SyncResult.success(int count) => SyncResult(
        success: true,
        syncedItems: count,
      );

  factory SyncResult.failure(String message, {int failed = 0}) => SyncResult(
        success: false,
        failedItems: failed,
        errorMessage: message,
      );

  factory SyncResult.offline() => SyncResult(
        success: false,
        errorMessage: 'Sin conexión a internet',
      );
}

/// Elemento en la cola de sincronización
class SyncQueueItem {
  final int id;
  final String tableName;
  final int recordId;
  final SyncAction action;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'table_name': tableName,
        'record_id': recordId,
        'action': action.name,
        'data': data.toString(),
        'created_at': createdAt.toIso8601String(),
        'retry_count': retryCount,
        'last_error': lastError,
      };
}

/// Acciones de sincronización
enum SyncAction {
  insert,
  update,
  delete,
}
