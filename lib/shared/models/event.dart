class EventAuraData {
  final int totalAttendees;
  final int soloAttendees;
  final int photographers;
  final int students;
  final int trainTravelers;
  final int cyclists;

  const EventAuraData({
    required this.totalAttendees,
    required this.soloAttendees,
    required this.photographers,
    required this.students,
    required this.trainTravelers,
    required this.cyclists,
  });
}

class EventModel {
  final String id;
  final String title;
  final String category;
  final String venue;
  final String area;
  final String city;
  final DateTime startsAt;
  final String priceRange;
  final String imageUrl;
  final String description;
  final bool isFree;
  final EventAuraData aura;

  const EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.venue,
    required this.area,
    required this.city,
    required this.startsAt,
    required this.priceRange,
    required this.imageUrl,
    required this.description,
    required this.isFree,
    required this.aura,
  });
}
