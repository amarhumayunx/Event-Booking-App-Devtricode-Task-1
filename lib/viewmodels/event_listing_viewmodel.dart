import '../models/event.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class EventListingViewModel extends BaseViewModel {
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  String? _selectedCategory;

  List<Event> get events => _filteredEvents.isEmpty ? _events : _filteredEvents;
  List<Event> get allEvents => _events;
  bool get hasEvents => _events.isNotEmpty;
  String? get selectedCategory => _selectedCategory;

  // Get all unique categories
  List<String> get categories {
    final categorySet = <String>{};
    for (var event in _events) {
      if (event.category.isNotEmpty) {
        categorySet.add(event.category);
      }
    }
    return categorySet.toList()..sort();
  }

  // Get events grouped by category
  Map<String, List<Event>> get eventsByCategory {
    final Map<String, List<Event>> grouped = {};
    for (var event in _events) {
      final category = event.category.isNotEmpty ? event.category : 'Uncategorized';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(event);
    }
    return grouped;
  }

  // Get events for a specific category
  List<Event> getEventsByCategory(String category) {
    if (category == 'All') {
      return _events;
    }
    return _events.where((event) => event.category == category).toList();
  }

  EventListingViewModel() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    setLoading(true);
    clearError();

    try {
      final fetchedEvents = await ApiService.getEvents();
      _events = fetchedEvents;
      _filteredEvents = _events;
      _selectedCategory = null;
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  void filterEvents(String query) {
    if (query.isEmpty) {
      _filteredEvents = _events;
    } else {
      _filteredEvents = _events.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.category.toLowerCase().contains(query.toLowerCase()) ||
            event.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    if (category == null || category == 'All') {
      _filteredEvents = _events;
    } else {
      _filteredEvents = _events.where((event) => event.category == category).toList();
    }
    update();
  }

  void clearFilter() {
    _filteredEvents = _events;
    _selectedCategory = null;
    update();
  }
}

