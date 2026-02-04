import 'package:flutter/foundation.dart';

import '../../models/ticket.dart';
import '../../repository/ticket_repository.dart';
import '../session/session_viewmodel.dart';

class MyBookingsViewModel extends ChangeNotifier {
  final TicketRepository _ticketRepository;
  final SessionViewModel _session;

  MyBookingsViewModel({
    required TicketRepository ticketRepository,
    required SessionViewModel session,
  })  : _ticketRepository = ticketRepository,
        _session = session;

  bool _loading = false;
  String? _error;
  List<Ticket> _tickets = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Ticket> get tickets => _tickets;

  List<Ticket> get upcoming =>
      _tickets.where((t) => t.status != 'cancelled').toList()
        ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

  List<Ticket> get past =>
      _tickets.where((t) => t.status == 'cancelled').toList()
        ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

  Future<void> load() async {
    final token = _session.accessToken;
    if (token == null || token.isEmpty) {
      _error = 'You must be signed in to view your bookings.';
      _tickets = const [];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _tickets = await _ticketRepository.getMyTickets(token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _tickets = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

