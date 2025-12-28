= State  Management & Logic

Dikerjakan oleh Logic Controller dan Frontend Engineer (Seat Matrix Module)[cite: 37].

== Seat Matrix Implementation
Bagian seat matrix dikerjakan oleh Rusydi Jabir Al Awfa (Frontend Engineer - Seat Matrix Module) untuk menampilkan dan mengelola pemilihan kursi dalam bioskop. Sistem ini memungkinkan pengguna untuk melihat status kursi (tersedia, dipilih, atau sudah dipesan) dan memilih kursi yang diinginkan.

=== Struktur Seat Matrix
Sistem seat matrix terdiri dari beberapa komponen utama:

- **SeatItemJabir**: Widget yang merepresentasikan satu kursi dengan status tertentu (available, selected, booked)
- **SeatMatrixJabir**: StatefulWidget utama yang menangani logika pemilihan kursi dan interaksi dengan pengguna
- **SeatStatus**: Enum yang mendefinisikan status kursi (available, selected, booked)

#image("../images/seat-matrix.jpg", width: 50%)

=== Implementasi Seat Item
Berikut adalah implementasi dari SeatItemJabir widget:

```dart
// SeatItem widget representing a single seat
class SeatItemJabir extends StatelessWidget {
  final String seatNumber;
  final SeatStatus status;
  final VoidCallback? onTap;
  final bool isSelected;

  const SeatItemJabir({
    Key? key,
    required this.seatNumber,
    required this.status,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    bool isInteractive = true;

    switch (status) {
      case SeatStatus.available:
        seatColor = isSelected ? Colors.blue : Colors.grey[300]!;
        break;
      case SeatStatus.selected:
        seatColor = Colors.blue;
        break;
      case SeatStatus.booked:
        seatColor = Colors.red;
        isInteractive = false;
        break;
      default:
        seatColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: isInteractive ? onTap : null,
      child: Container(
        width: 35,
        height: 35,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: status == SeatStatus.booked ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
```

=== State Management untuk Pemilihan Kursi
Sistem ini menggunakan state management untuk melacak status kursi dan kursi yang dipilih oleh pengguna:

```dart
class _SeatMatrixJabirState extends State<SeatMatrixJabir> {
  Map<String, SeatStatus> seatStatuses = {};
  List<String> selectedSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookedSeats(); // Fetch booked seats from Firestore
  }

  // Fungsi untuk memuat status kursi yang sudah dipesan dari Firestore
  Future<void> _loadBookedSeats() async {
    try {
      // Fetch all bookings for this movie
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('movie_title', isEqualTo: widget.movieTitle)
          .get();

      // Extract all booked seats from the query result
      Set<String> bookedSeatsSet = {};
      for (var doc in querySnapshot.docs) {
        final seats = doc.data()['seats'] as List;
        for (var seat in seats) {
          if (seat is String) {
            bookedSeatsSet.add(seat);
          }
        }
      }

      // Initialize seats based on booked status
      _initializeSeats(bookedSeatsSet.toList());
    } catch (e) {
      print('Error loading booked seats: $e');
      // Initialize seats as available if there's an error
      _initializeSeats([]);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menginisialisasi status kursi
  void _initializeSeats(List<String> bookedSeats) {
    // Initialize all seats as available or booked based on the fetched data
    for (int row = 0; row < 10; row++) {
      String rowLabel = String.fromCharCode(65 + row); // A, B, C, etc.
      for (int col = 1; col <= 5; col++) {
        String seatNumber = '${rowLabel}${col}';
        seatStatuses[seatNumber] = bookedSeats.contains(seatNumber)
            ? SeatStatus.booked
            : SeatStatus.available;
      }
    }
  }

  // Fungsi untuk mengganti status kursi (toggle seat selection)
  void _toggleSeat(String seatNumber) {
    if (seatStatuses[seatNumber] == SeatStatus.booked) {
      return; // Can't select booked seats
    }

    setState(() {
      if (seatStatuses[seatNumber] == SeatStatus.selected) {
        seatStatuses[seatNumber] = SeatStatus.available;
        selectedSeats.remove(seatNumber);
      } else {
        seatStatuses[seatNumber] = SeatStatus.selected;
        selectedSeats.add(seatNumber);
      }
    });
  }
}
```

== Integrasi dengan Booking Service
Setelah pengguna memilih kursi, sistem akan mengintegrasikan dengan booking service untuk menyimpan data pemesanan. Fungsi konfirmasi booking:

```dart
void _confirmBooking() {
  final booking = BookingServiceIsal();
  booking.bookingMovie_Isal(
    movieTitle: widget.movieTitle,
    basePrice: widget.totalPrice,
    selectedSeats: selectedSeats,
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil booking ${widget.movieTitle}!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
```

== Perhitungan Checkout
Total harga dihitung berdasarkan logika diskon NIM dan stok di Firebase berkurang otomatis (*Transaction Write*)[cite: 41].