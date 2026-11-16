// Anabhay Ventures — Staff & Attendance Domain Models
// Phase 6: Staff Management, Employment Details, Attendance and Performance

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum StaffRole {
  manager('Manager'),
  cashier('Cashier'),
  waiter('Waiter'),
  chef('Chef'),
  kitchenHelper('Kitchen Helper'),
  deliveryStaff('Delivery Staff'),
  cleaner('Cleaner');

  final String label;
  const StaffRole(this.label);

  Color get color {
    switch (this) {
      case StaffRole.manager:
        return AppColors.champagneGold;
      case StaffRole.cashier:
        return AppColors.successGreen;
      case StaffRole.waiter:
        return AppColors.warningAmber;
      case StaffRole.chef:
        return AppColors.copper;
      case StaffRole.kitchenHelper:
        return AppColors.warmIvory;
      case StaffRole.deliveryStaff:
        return Colors.lightBlueAccent;
      case StaffRole.cleaner:
        return AppColors.mutedGrey;
    }
  }

  static StaffRole fromString(String val) {
    return StaffRole.values.firstWhere(
      (r) => r.name.toLowerCase() == val.toLowerCase() || r.label.toLowerCase() == val.toLowerCase(),
      orElse: () => StaffRole.waiter,
    );
  }
}

enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  halfDay('Half Day');

  final String label;
  const AttendanceStatus(this.label);

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return AppColors.successGreen;
      case AttendanceStatus.absent:
        return AppColors.errorRed;
      case AttendanceStatus.halfDay:
        return AppColors.warningAmber;
    }
  }

  static AttendanceStatus fromString(String val) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == val.toLowerCase() || s.label.toLowerCase() == val.toLowerCase(),
      orElse: () => AttendanceStatus.present,
    );
  }
}

class StaffMember {
  final String id;
  final String name;
  final String? photoUrl;
  final String phone;
  final String email;
  final String address;
  final StaffRole role;
  final DateTime joiningDate;
  final double monthlySalary;
  final bool isActive;
  final String notes;
  final int ordersHandled;

  const StaffMember({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.phone,
    required this.email,
    this.address = '',
    required this.role,
    required this.joiningDate,
    required this.monthlySalary,
    this.isActive = true,
    this.notes = '',
    this.ordersHandled = 0,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? phone,
    String? email,
    String? address,
    StaffRole? role,
    DateTime? joiningDate,
    double? monthlySalary,
    bool? isActive,
    String? notes,
    int? ordersHandled,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      joiningDate: joiningDate ?? this.joiningDate,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      ordersHandled: ordersHandled ?? this.ordersHandled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'phone': phone,
        'email': email,
        'address': address,
        'role': role.name,
        'joiningDate': joiningDate.toIso8601String(),
        'monthlySalary': monthlySalary,
        'isActive': isActive,
        'notes': notes,
        'ordersHandled': ordersHandled,
      };

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['id'] as String,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        address: json['address'] as String? ?? '',
        role: StaffRole.fromString(json['role'] as String? ?? 'waiter'),
        joiningDate: json['joiningDate'] != null ? DateTime.parse(json['joiningDate'] as String) : DateTime.now(),
        monthlySalary: (json['monthlySalary'] as num?)?.toDouble() ?? 25000.0,
        isActive: json['isActive'] as bool? ?? true,
        notes: json['notes'] as String? ?? '',
        ordersHandled: json['ordersHandled'] as int? ?? 0,
      );
}

class StaffAttendance {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? notes;

  const StaffAttendance({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
  });

  StaffAttendance copyWith({
    String? id,
    String? staffId,
    String? staffName,
    DateTime? date,
    AttendanceStatus? status,
    String? checkInTime,
    String? checkOutTime,
    String? notes,
  }) {
    return StaffAttendance(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'staffName': staffName,
        'date': date.toIso8601String(),
        'status': status.name,
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'notes': notes,
      };

  factory StaffAttendance.fromJson(Map<String, dynamic> json) => StaffAttendance(
        id: json['id'] as String,
        staffId: json['staffId'] as String,
        staffName: json['staffName'] as String,
        date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
        status: AttendanceStatus.fromString(json['status'] as String? ?? 'present'),
        checkInTime: json['checkInTime'] as String?,
        checkOutTime: json['checkOutTime'] as String?,
        notes: json['notes'] as String?,
      );
}
