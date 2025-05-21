import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';

enum RepairStatus { created, completed, cancelled, unknown }

/// Parse from the raw backend string (e.g. "CREATED", "COMPLETED", "CANCELED")
RepairStatus repairStatusFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'CREATED':
      return RepairStatus.created;
    case 'COMPLETED':
      return RepairStatus.completed;
    case 'CANCELED': // or 'CANCELLED' if you spell it with two Ls
    case 'CANCELLED':
      return RepairStatus.cancelled;
    default:
      return RepairStatus.unknown;
  }
}

/// Back to the wire format, if you ever need it
String repairStatusToString(RepairStatus status) {
  switch (status) {
    case RepairStatus.created:
      return 'CREATED';
    case RepairStatus.completed:
      return 'COMPLETED';
    case RepairStatus.cancelled:
      return 'CANCELLED';
    case RepairStatus.unknown:
    default:
      return 'UNKNOWN';
  }
}

/// Extension to get a localized display string
extension RepairStatusX on RepairStatus {
  String localized(AppLocalizations loc) {
    switch (this) {
      case RepairStatus.created:
        return loc.translate('repairs_status_created');
      case RepairStatus.completed:
        return loc.translate('repairs_status_completed');
      case RepairStatus.cancelled:
        return loc.translate('repairs_status_cancelled');
      case RepairStatus.unknown:
      default:
        return loc.translate('repairs_status_unknown');
    }
  }
}
