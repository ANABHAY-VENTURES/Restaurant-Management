// Anabhay Ventures — Staff & Attendance Riverpod Providers
// Phase 6: Staff Management, Daily Attendance, and Staff Performance State

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/staff_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../../pos/data/restaurant_storage_repository.dart';

class StaffNotifier extends StateNotifier<List<StaffMember>> {
  final RestaurantStorageRepository _repo;

  StaffNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadStaff();
  }

  Future<void> addStaff({
    required String name,
    required String phone,
    required String email,
    required StaffRole role,
    required double monthlySalary,
    String address = '',
    String notes = '',
  }) async {
    final newMember = StaffMember(
      id: 'stf-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      role: role,
      monthlySalary: monthlySalary,
      address: address,
      notes: notes,
      joiningDate: DateTime.now(),
      isActive: true,
      ordersHandled: 0,
    );

    state = [...state, newMember];
    await _repo.saveStaff(state);
  }

  Future<void> updateStaff(StaffMember updated) async {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s,
    ];
    await _repo.saveStaff(state);
  }

  Future<void> toggleActive(String id) async {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(isActive: !s.isActive) else s,
    ];
    await _repo.saveStaff(state);
  }

  Future<void> deleteStaff(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _repo.saveStaff(state);
  }

  Future<void> incrementOrdersHandled(String id, [int count = 1]) async {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(ordersHandled: s.ordersHandled + count) else s,
    ];
    await _repo.saveStaff(state);
  }
}

final staffProvider = StateNotifierProvider<StaffNotifier, List<StaffMember>>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return StaffNotifier(repo);
});

class AttendanceNotifier extends StateNotifier<List<StaffAttendance>> {
  final RestaurantStorageRepository _repo;

  AttendanceNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadAttendance();
  }

  Future<void> markAttendance({
    required String staffId,
    required String staffName,
    required DateTime date,
    required AttendanceStatus status,
    String? checkInTime,
    String? checkOutTime,
    String? notes,
  }) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final existingIndex = state.indexWhere((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return a.staffId == staffId && aDate == dateOnly;
    });

    if (existingIndex >= 0) {
      final updated = List<StaffAttendance>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        status: status,
        checkInTime: checkInTime ?? updated[existingIndex].checkInTime,
        checkOutTime: checkOutTime ?? updated[existingIndex].checkOutTime,
        notes: notes ?? updated[existingIndex].notes,
      );
      state = updated;
    } else {
      final newRecord = StaffAttendance(
        id: 'att-${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        staffName: staffName,
        date: dateOnly,
        status: status,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        notes: notes,
      );
      state = [newRecord, ...state];
    }

    await _repo.saveAttendance(state);
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<StaffAttendance>>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return AttendanceNotifier(repo);
});

class StaffMetrics {
  final int totalStaff;
  final int activeStaff;
  final int onDutyToday;
  final int absentToday;

  const StaffMetrics({
    required this.totalStaff,
    required this.activeStaff,
    required this.onDutyToday,
    required this.absentToday,
  });
}

final staffMetricsProvider = Provider<StaffMetrics>((ref) {
  final staff = ref.watch(staffProvider);
  final attendance = ref.watch(attendanceProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayAttendance = attendance.where((a) {
    final aDate = DateTime(a.date.year, a.date.month, a.date.day);
    return aDate == today;
  }).toList();

  final onDuty = todayAttendance.where((a) => a.status == AttendanceStatus.present || a.status == AttendanceStatus.halfDay).length;
  final absent = todayAttendance.where((a) => a.status == AttendanceStatus.absent).length;

  return StaffMetrics(
    totalStaff: staff.length,
    activeStaff: staff.where((s) => s.isActive).length,
    onDutyToday: onDuty,
    absentToday: absent,
  );
});
