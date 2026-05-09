class AuditLog {
  final int? id;
  final int? userId;
  final String action;
  final String? tableName;
  final int? recordId;
  final String? oldValue;
  final String? newValue;
  final String? timestamp;

  AuditLog({
    this.id,
    this.userId,
    required this.action,
    this.tableName,
    this.recordId,
    this.oldValue,
    this.newValue,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'old_value': oldValue,
      'new_value': newValue,
      'timestamp': timestamp ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'],
      userId: map['user_id'],
      action: map['action'] ?? '',
      tableName: map['table_name'],
      recordId: map['record_id'],
      oldValue: map['old_value'],
      newValue: map['new_value'],
      timestamp: map['timestamp'],
    );
  }

  @override
  String toString() =>
      'AuditLog(id: $id, action: $action, tableName: $tableName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
