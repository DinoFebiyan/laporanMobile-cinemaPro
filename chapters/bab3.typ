
= Arsitektur Backend

Dikerjakan oleh Backend Engineer & Data Seeder[cite: 23].

== Struktur Database (Firestore)
Menggunakan 3 Collection utama: `Users`, `Movies`, dan `Bookings`[cite: 13, 15, 17].
Berikut Struktur field sebagai berikut:
A.Collection: Users
Menyimpan data profil pengguna 
Field name  Tipe data   Deskripsi
uid         String      Primary key
email       String      Email pengguna (Validasi @student.univ.ac.id).
username    String      Nama tampilan pengguna
balance     Number(int) Saldo awal (Default: 0)
password    String      Password pengguna
created_at  Timestamp   Waktu registrasi akun

B.Collection: Movies
Menyimpan data film
Field name  Tipe data      Deskripsi
movide_id   String         Primary key
title       String         Judul film
poster_url  String         Gambar poster film
base_price  Number(int)    Harga dasar tiket
rating      Number(Double) Rating film (skala 1.0-5.0)
duration    Number(int)    Durasi film dalam menit

C.Collection: Bookings
Menyimpan riwayat transaksi pembelian tiket
Field name   Tipe data     Deskripsi 
booking_id   String        Primary key
user_id      String        Foreign key ke collection Users
movie_title  String        Judul film yang di pesan
seats        Array(string) Daftar kursi yang dipilih (Contoh:["A1", "A2"])
total_price  Number(int)   Harga final setelah perhitungan pajak&diskon
booking_date Timestamp     Waktu transaksi dilakukan

A.Collection Users
#images("../images/user mobile.png", width: 50%)

B.Collection Movies
#images("../images/movie firebase.png", width: 50%)

C.Collection Bookings
#images("../images/booking firebase.png", width: 50%)

== Data Seeding
Bukti seeding minimal 10 produk dummy ke Firebase[cite: 27].
Untuk pengujian Logic Trap,maka ada seeding data sebanyak 10 film
1. Strategi Judul Pendek (≤ 10 Karakter):
 - Film: up, Coco, Frozen, Venom, Dilan 1990
  ini untuk menguji bahwa harga tiket tidak dikenakan pajak tambahkan

2. Staregi Judul Panjang (> 10 Karakter)
 - Film: Spider-Man: No Way Home, Avengers: Endgame, Pengabdi Setan2: Communion, Demon Slayer: Kimestsu no Yaiba - The Movie: Infinity Castle, KKN di Desa Penari
  ini untuk logix yang penambahan harga sebesar Rp.2.500

Future<void> seedMovies() async {
    final CollectionReference movieRef = FirebaseFirestore.instance.collection('movies');

    try {
      print("Memulai proses seeding...");

      for (var movie in _moviesData) {
        await movieRef.doc(movie.movieID).set(movie.toMap_Cheryl());

        print("berhasil upload: ${movie.title}");
      }
      print("10 data dilm berhasil seed ke database");
    } catch (e) {
      print("Gagal seeding: $e");
    }
  }
}

kode ini untuk automatis seeding data ke firebase

#images("../images/movie firebase.png", width: 50%)
