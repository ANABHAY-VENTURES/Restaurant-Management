// Anabhay Ventures — Staff Management & Attendance Screen
// Phase 6: Staff Roster, Employment Details, Daily Attendance Timesheet & Performance Metrics

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/staff_models.dart';
import '../providers/staff_providers.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRoleFilter = 'All Roles';
  String _searchQuery = '';
  DateTime _selectedAttendanceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditStaffDialog([StaffMember? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final salaryCtrl = TextEditingController(text: existing != null ? existing.monthlySalary.toStringAsFixed(0) : '30000');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    StaffRole selectedRole = existing?.role ?? StaffRole.waiter;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? 'Edit Staff Member' : 'Add New Staff Member', style: AppTypography.headlineSmall),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textTertiary, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 20),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                    decoration: const InputDecoration(labelText: 'Full Name *', isDense: true),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                          decoration: const InputDecoration(labelText: 'Phone Number *', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                          decoration: const InputDecoration(labelText: 'Email Address *', isDense: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<StaffRole>(
                          value: selectedRole,
                          dropdownColor: AppColors.surfaceCard,
                          style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
                          decoration: const InputDecoration(labelText: 'Job Role *', isDense: true),
                          items: StaffRole.values.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedRole = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: salaryCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                          decoration: const InputDecoration(labelText: 'Monthly Salary (₹) *', isDense: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                    decoration: const InputDecoration(labelText: 'Residential Address', isDense: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                    decoration: const InputDecoration(labelText: 'Operational Notes & Specialization', isDense: true),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.champagneGold,
                          foregroundColor: AppColors.matteBlack,
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          final email = emailCtrl.text.trim();
                          final salary = double.tryParse(salaryCtrl.text.trim()) ?? 25000.0;
                          final address = addressCtrl.text.trim();
                          final notes = notesCtrl.text.trim();

                          if (name.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name and Phone are required!'), backgroundColor: AppColors.errorRed),
                            );
                            return;
                          }

                          if (isEditing) {
                            ref.read(staffProvider.notifier).updateStaff(
                                  existing.copyWith(
                                    name: name,
                                    phone: phone,
                                    email: email,
                                    role: selectedRole,
                                    monthlySalary: salary,
                                    address: address,
                                    notes: notes,
                                  ),
                                );
                          } else {
                            ref.read(staffProvider.notifier).addStaff(
                                  name: name,
                                  phone: phone,
                                  email: email,
                                  role: selectedRole,
                                  monthlySalary: salary,
                                  address: address,
                                  notes: notes,
                                );
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Create Staff Member'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkAttendanceDialog(StaffMember staff) {
    AttendanceStatus status = AttendanceStatus.present;
    final inCtrl = TextEditingController(text: '10:30 AM');
    final outCtrl = TextEditingController(text: '07:30 PM');
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mark Attendance: ${staff.name}', style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Text('Date: ${_selectedAttendanceDate.toLocal().toString().split(' ')[0]} • Role: ${staff.role.label}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const Divider(color: AppColors.borderSubtle, height: 20),
                Row(
                  children: AttendanceStatus.values.map((s) {
                    final isSelected = status == s;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(s.label),
                          selected: isSelected,
                          selectedColor: s.color,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          onSelected: (_) => setDialogState(() => status = s),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (status != AttendanceStatus.absent) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inCtrl,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                          decoration: const InputDecoration(labelText: 'Check-in Time', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: outCtrl,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                          decoration: const InputDecoration(labelText: 'Check-out Time', isDense: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: noteCtrl,
                  style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                  decoration: const InputDecoration(hintText: 'Notes (e.g. Approved leave / late arrival)', isDense: true),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                      ),
                      onPressed: () {
                        ref.read(attendanceProvider.notifier).markAttendance(
                              staffId: staff.id,
                              staffName: staff.name,
                              date: _selectedAttendanceDate,
                              status: status,
                              checkInTime: status != AttendanceStatus.absent ? inCtrl.text.trim() : null,
                              checkOutTime: status != AttendanceStatus.absent ? outCtrl.text.trim() : null,
                              notes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                            );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Marked ${staff.name} as ${status.label}!'), backgroundColor: AppColors.successGreen),
                        );
                      },
                      child: const Text('Record Attendance'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffList = ref.watch(staffProvider);
    final metrics = ref.watch(staffMetricsProvider);
    final attendanceList = ref.watch(attendanceProvider);

    final filteredStaff = staffList.where((s) {
      if (_selectedRoleFilter != 'All Roles' && s.role.label != _selectedRoleFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = s.name.toLowerCase().contains(q);
        final matchesPhone = s.phone.toLowerCase().contains(q);
        final matchesRole = s.role.label.toLowerCase().contains(q);
        if (!matchesName && !matchesPhone && !matchesRole) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Staff Management',
                              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.champagneGold,
                              foregroundColor: AppColors.matteBlack,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () => _showAddEditStaffDialog(),
                            icon: const Icon(Icons.person_add_rounded, size: 16),
                            label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Team roster, daily attendance & performance', style: AppTypography.bodySmall),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Staff Management', style: AppTypography.headlineLarge),
                        const SizedBox(height: 2),
                        Text('Team roster, daily attendance, work schedules & service performance', style: AppTypography.bodySmall),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => _showAddEditStaffDialog(),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Add Staff Member', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Top KPI Metrics Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Total Staff',
                      value: '${metrics.totalStaff}',
                      icon: Icons.people_alt_outlined,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Active Accounts',
                      value: '${metrics.activeStaff}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'On-Duty Today',
                      value: '${metrics.onDutyToday}',
                      icon: Icons.badge_outlined,
                      color: AppColors.copper,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Absent Today',
                      value: '${metrics.absentToday}',
                      icon: Icons.event_busy_rounded,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Navigation Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.champagneGold,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.champagneGold,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.badge_rounded, size: 18), text: 'Staff Roster'),
                Tab(icon: Icon(Icons.fact_check_outlined, size: 18), text: 'Daily Attendance'),
                Tab(icon: Icon(Icons.trending_up_rounded, size: 18), text: 'Performance & Orders'),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRosterTab(filteredStaff),
                  _buildAttendanceTab(staffList, attendanceList),
                  _buildPerformanceTab(staffList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterTab(List<StaffMember> staff) {
    return Column(
      children: [
        // Filter & Search Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                decoration: InputDecoration(
                  hintText: 'Search staff by name, phone or role...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.champagneGold),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButton<String>(
                value: _selectedRoleFilter,
                dropdownColor: AppColors.surfaceCard,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                items: ['All Roles', ...StaffRole.values.map((r) => r.label)].map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoleFilter = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Staff List Table
        Expanded(
          child: staff.isEmpty
              ? const Center(child: Text('No staff members found matching criteria.', style: TextStyle(color: AppColors.textTertiary)))
              : ListView.builder(
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    final s = staff[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: s.isActive ? AppColors.borderSubtle : AppColors.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: s.role.color.withValues(alpha: 0.2),
                            child: Text(
                              s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                              style: TextStyle(fontWeight: FontWeight.bold, color: s.role.color),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(s.name, style: AppTypography.titleMedium),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: s.role.color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: s.role.color.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(s.role.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s.role.color)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('${s.phone} • ${s.email}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('₹${s.monthlySalary.toStringAsFixed(0)} / mo', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                Text('Joined: ${s.joiningDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                          // Status Switch
                          Row(
                            children: [
                              Text(s.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: s.isActive ? AppColors.successGreen : AppColors.errorRed)),
                              Transform.scale(
                                scale: 0.75,
                                child: Switch(
                                  value: s.isActive,
                                  activeThumbColor: AppColors.successGreen,
                                  onChanged: (_) => ref.read(staffProvider.notifier).toggleActive(s.id),
                                ),
                              ),
                            ],
                          ),
                          // Action buttons
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                            onPressed: () => _showAddEditStaffDialog(s),
                            tooltip: 'Edit Details',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                            onPressed: () => _confirmDelete(s),
                            tooltip: 'Delete Staff',
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab(List<StaffMember> staff, List<StaffAttendance> attendance) {
    final dateOnly = DateTime(_selectedAttendanceDate.year, _selectedAttendanceDate.month, _selectedAttendanceDate.day);
    final todayRecords = attendance.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate == dateOnly;
    }).toList();

    return Column(
      children: [
        // Date Selector Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.champagneGold),
                  const SizedBox(width: 8),
                  Text(
                    'Attendance Date: ${dateOnly.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.champagneGold,
                      side: const BorderSide(color: AppColors.champagneGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedAttendanceDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) setState(() => _selectedAttendanceDate = picked);
                    },
                    icon: const Icon(Icons.date_range, size: 14),
                    label: const Text('Change Date', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Staff Attendance List
        Expanded(
          child: ListView.builder(
            itemCount: staff.length,
            itemBuilder: (context, index) {
              final member = staff[index];
              final record = todayRecords.firstWhere(
                (r) => r.staffId == member.id,
                orElse: () => StaffAttendance(
                  id: '',
                  staffId: member.id,
                  staffName: member.name,
                  date: dateOnly,
                  status: AttendanceStatus.absent,
                ),
              );

              final isMarked = record.id.isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: AppTypography.titleMedium),
                          Text(member.role.label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    // Times
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMarked && record.status != AttendanceStatus.absent
                                ? 'In: ${record.checkInTime ?? '--'} | Out: ${record.checkOutTime ?? 'On Duty'}'
                                : 'No Times Recorded',
                            style: const TextStyle(fontSize: 11, color: AppColors.warmIvory),
                          ),
                          if (record.notes != null && record.notes!.isNotEmpty)
                            Text(record.notes!, style: const TextStyle(fontSize: 10, color: AppColors.champagneGold, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: record.status.color),
                      ),
                      child: Text(
                        isMarked ? record.status.label.toUpperCase() : 'NOT MARKED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: record.status.color),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Mark Action
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.champagneGold,
                        side: const BorderSide(color: AppColors.champagneGold),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () => _showMarkAttendanceDialog(member),
                      child: Text(isMarked ? 'Update' : 'Mark', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab(List<StaffMember> staff) {
    return ListView.builder(
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final s = staff[index];
        final workingDays = 26;
        final attendancePercent = 95;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: s.role.color.withValues(alpha: 0.2),
                child: Text(s.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: s.role.color)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: AppTypography.titleMedium),
                    Text('${s.role.label} • Active Staff', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Orders Handled', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('${s.ordersHandled}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attendance Rate', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('$attendancePercent%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Working Days', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('$workingDays days / mo', style: const TextStyle(fontSize: 12, color: AppColors.warmIvory)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(StaffMember s) {
    AppDialog.show(
      context: context,
      title: 'Delete Staff Member',
      subtitle: 'Are you sure you want to remove ${s.name} from the staff records?',
      content: const Text(
        'This record and linked attendance records will be removed.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () {
        ref.read(staffProvider.notifier).deleteStaff(s.id);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
