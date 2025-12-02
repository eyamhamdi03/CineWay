import '../models/cinema.dart';
import '../models/movie.dart';
import 'mock_movies.dart';

final List<Cinema> mockCinemas = [
  Cinema(
    id: 1,
    name: "Cinema Vox",
    imageUrl: "cinema_vox.jpg",
    address: "Avenue Habib Bourguiba, Tunis Centre Ville",
    latitude: 36.8008,
    longitude: 10.1843,
    phone: "+216 71 242 000",
    hasParking: false,
    isAccessible: true,
    amenities: ["2D", "3D", "Snack", "Dolby Sound"], city: '', createdAt: DateTime.now(),
  ),
  Cinema(
    id: 2,
    name: "La Palace",
    imageUrl: "Lapalace.jpg",
    address: "Mall of Tunisia, La Soukra",
    latitude: 36.8585,
    longitude: 10.1995,
    phone: "+216 71 888 444",
    hasParking: true,
    isAccessible: true,
    amenities: ["2D", "3D", "IMAX", "VIP Lounge"], city: '', createdAt: DateTime.now(),
  ),
  Cinema(
    id: 3,
    name: "Pathé Tunis City",
    imageUrl: "pathe_tunis.png",
    address: "Tunis City Mall, Ibn Khaldoun",
    latitude: 36.8101,
    longitude: 10.1380,
    phone: "+216 71 333 333",
    hasParking: true,
    isAccessible: false,
    amenities: ["2D", "4DX", "IMAX", "Snack"], city: '', createdAt: DateTime.now(),
  ),
];
