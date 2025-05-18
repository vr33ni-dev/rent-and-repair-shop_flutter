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
