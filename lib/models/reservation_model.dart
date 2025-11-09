// lib/models/reservation_model.dart
class Reservation {
  final int? id;
  final int vehicleId;
  final int driverId;
  final String clientName;
  final String clientPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  Reservation({
    this.id,
    required this.vehicleId,
    required this.driverId,
    required this.clientName,
    required this.clientPhone,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = 'en_attente',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'vehicle_id': vehicleId,
    'driver_id': driverId,
    'client_name': clientName,
    'client_phone': clientPhone,
    'start_date': startDate.millisecondsSinceEpoch,
    'end_date': endDate.millisecondsSinceEpoch,
    'total_price': totalPrice,
    'status': status,
  };

  factory Reservation.fromMap(Map<String, dynamic> map) => Reservation(
    id: map['id'],
    vehicleId: map['vehicle_id'],
    driverId: map['driver_id'],
    clientName: map['client_name'],
    clientPhone: map['client_phone'],
    startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
    endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
    totalPrice: map['total_price'],
    status: map['status'],
  );
}