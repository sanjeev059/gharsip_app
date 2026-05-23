import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/firestore_service.dart';
import '../../providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  final String? preselectedService;
  const BookingScreen({super.key, this.preselectedService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;

  // Step 1: Services
  final Set<String> _selectedServices = {};

  // Step 2: Schedule
  DateTime? _pickupDate;
  String _timeSlot = '10am - 12pm';
  String _address = '';
  String _pincode = '';
  String _notes = '';

  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _loading = false;
  String? _bookingId;

  static const _timeSlots = [
    '10am - 12pm', '12pm - 2pm', '2pm - 4pm', '4pm - 6pm',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedService != null) {
      _selectedServices.add(widget.preselectedService!);
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final fs = FirestoreService();
      final id = await fs.createBooking(
        userId: auth.user!.uid,
        phone: auth.user!.phone,
        name: auth.user!.name,
        services: _selectedServices.toList(),
        pickupDate: _pickupDate!,
        timeSlot: _timeSlot,
        address: _addressCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      setState(() { _bookingId = id; _step = 3; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  bool get _canProceedStep0 => _selectedServices.isNotEmpty;
  bool get _canProceedStep1 =>
      _pickupDate != null &&
      _addressCtrl.text.trim().isNotEmpty &&
      _pincodeCtrl.text.trim().length == 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _step < 3
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              title: const Text('Book Home Pickup',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 3,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
      body: _step == 3 ? _SuccessView(bookingId: _bookingId!) : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _StepIndicator(current: _step),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _step == 0 ? _ServicesStep(
              selected: _selectedServices,
              onToggle: (s) => setState(() {
                if (_selectedServices.contains(s)) _selectedServices.remove(s);
                else _selectedServices.add(s);
              }),
            ) : _step == 1 ? _ScheduleStep(
              pickupDate: _pickupDate,
              timeSlot: _timeSlot,
              timeSlots: _timeSlots,
              addressCtrl: _addressCtrl,
              pincodeCtrl: _pincodeCtrl,
              notesCtrl: _notesCtrl,
              onDatePick: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (_, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (d != null) setState(() => _pickupDate = d);
              },
              onTimeSlot: (t) => setState(() => _timeSlot = t),
            ) : _ReviewStep(
              services: _selectedServices,
              pickupDate: _pickupDate!,
              timeSlot: _timeSlot,
              address: _addressCtrl.text,
              pincode: _pincodeCtrl.text,
              notes: _notesCtrl.text,
            ),
          ),
        ),
        _NavBar(
          step: _step,
          canNext: _step == 0 ? _canProceedStep0 : _step == 1 ? _canProceedStep1 : true,
          loading: _loading,
          onBack: () => setState(() => _step--),
          onNext: () {
            if (_step < 2) setState(() => _step++);
            else _confirmBooking();
          },
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  static const _labels = ['Services', 'Schedule', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final isDone = i < current;
          final isActive = i == current;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isDone || isActive ? AppColors.primary : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone || isActive ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text('${i + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textMuted,
                              fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 6),
                Text(_labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                    fontFamily: 'Poppins',
                  )),
                if (i < _labels.length - 1)
                  const Expanded(child: Divider(endIndent: 8, indent: 8)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ServicesStep extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _ServicesStep({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        const Text('Choose one or more services for your saree',
          style: TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        ...kSareeServices.entries.map((e) {
          final isSelected = selected.contains(e.key);
          return GestureDetector(
            onTap: () => onToggle(e.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(e.value['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value['name'] as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary, fontFamily: 'Poppins')),
                        Text(e.value['tagline'] as String,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(e.key),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  final DateTime? pickupDate;
  final String timeSlot;
  final List<String> timeSlots;
  final TextEditingController addressCtrl, pincodeCtrl, notesCtrl;
  final VoidCallback onDatePick;
  final ValueChanged<String> onTimeSlot;

  const _ScheduleStep({
    required this.pickupDate, required this.timeSlot, required this.timeSlots,
    required this.addressCtrl, required this.pincodeCtrl, required this.notesCtrl,
    required this.onDatePick, required this.onTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule Pickup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 16),

        _Label('Pickup Date *'),
        GestureDetector(
          onTap: onDatePick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pickupDate != null ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  pickupDate != null
                      ? DateFormat('EEEE, d MMMM yyyy').format(pickupDate!)
                      : 'Select pickup date',
                  style: TextStyle(
                    color: pickupDate != null ? AppColors.textPrimary : AppColors.textMuted,
                    fontFamily: 'Poppins',
                  )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _Label('Time Slot *'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: timeSlots.map((slot) {
            final isSelected = slot == timeSlot;
            return GestureDetector(
              onTap: () => onTimeSlot(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Text(slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecond,
                    fontSize: 13, fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        _Label('Pickup Address *'),
        TextField(
          controller: addressCtrl,
          maxLines: 2,
          decoration: _inputDeco('Door no., Street, Area, City'),
        ),
        const SizedBox(height: 12),

        _Label('PIN Code *'),
        TextField(
          controller: pincodeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: _inputDeco('560XXX').copyWith(counterText: ''),
        ),
        const SizedBox(height: 12),

        _Label('Special Instructions (optional)'),
        TextField(
          controller: notesCtrl,
          maxLines: 2,
          decoration: _inputDeco('Any specific requirements for your saree...'),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textSecond, fontFamily: 'Poppins')),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final Set<String> services;
  final DateTime pickupDate;
  final String timeSlot, address, pincode, notes;

  const _ReviewStep({
    required this.services, required this.pickupDate, required this.timeSlot,
    required this.address, required this.pincode, required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Booking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        _Section(title: 'Services Selected', children: [
          Wrap(
            spacing: 8, runSpacing: 6,
            children: services.map((s) {
              final svc = kSareeServices[s];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${svc?['emoji'] ?? ''} ${svc?['name'] ?? s}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark, fontFamily: 'Poppins')),
              );
            }).toList(),
          ),
        ]),
        _Section(title: 'Pickup Schedule', children: [
          _InfoRow(Icons.calendar_today_outlined,
            DateFormat('EEEE, d MMMM yyyy').format(pickupDate)),
          _InfoRow(Icons.access_time_outlined, timeSlot),
        ]),
        _Section(title: 'Pickup Address', children: [
          _InfoRow(Icons.location_on_outlined, address),
          _InfoRow(Icons.pin_drop_outlined, 'PIN: $pincode'),
          if (notes.isNotEmpty) _InfoRow(Icons.note_outlined, notes),
        ]),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('You will receive a confirmation and our team will contact you before pickup.',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontFamily: 'Poppins', height: 1.4)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int step;
  final bool canNext, loading;
  final VoidCallback onBack, onNext;

  const _NavBar({
    required this.step, required this.canNext, required this.loading,
    required this.onBack, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
          if (step > 0) const SizedBox(width: 12),
          Expanded(
            flex: step > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: canNext && !loading ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(step == 2 ? 'Confirm Booking' : 'Continue',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String bookingId;
  const _SuccessView({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryMuted, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.primary, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              const Text('We will contact you before the pickup.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecond, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Booking ID: $bookingId',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.primary, fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Home',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('View My Bookings',
                  style: TextStyle(color: AppColors.primary, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
