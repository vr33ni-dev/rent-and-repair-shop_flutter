import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';

enum RentalStatus {
  created,
  returned,
  unknown, // fallback case
}

RentalStatus rentalStatusFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'CREATED':
      return RentalStatus.created;
    case 'RETURNED':
      return RentalStatus.returned;
    default:
      return RentalStatus.unknown;
  }
}

String rentalStatusToString(RentalStatus status) {
  switch (status) {
    case RentalStatus.created:
      return 'CREATED';
    case RentalStatus.returned:
      return 'RETURNED';
    case RentalStatus.unknown:
    default:
      return 'UNKNOWN';
  }
}

extension RentalStatusX on RentalStatus {
  /// Looks up the localized name via your AppLocalizations
  String localized(AppLocalizations loc) {
    switch (this) {
      case RentalStatus.created:
        return loc.translate('rentals_status_created');
      case RentalStatus.returned:
        return loc.translate('rentals_status_returned');
      case RentalStatus.unknown:
      default:
        return loc.translate('rentals_status_unknown');
    }
  }
}
