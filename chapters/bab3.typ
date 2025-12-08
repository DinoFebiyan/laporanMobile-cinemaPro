= Arsitektur Backend

Dikerjakan oleh Backend Engineer & Data Seeder.

== Struktur Database (Firestore)

Menggunakan 3 Collection utama: Users, Movies, dan Bookings. Berikut Struktur field sebagai berikut:

*A. Collection: Users*

Menyimpan data profil pengguna

- uid: String (Primary key)
- email: String (Email pengguna, Validasi domain student.univ.ac.id)
- username: String (Nama tampilan pengguna)
- balance: Number(int) (Saldo awal, Default: 0)
- password: String (Password pengguna)
- created_at: Timestamp (Waktu registrasi akun)

*B. Collection: Movies*

Menyimpan data film

- movie_id: String (Primary key)
- title: String (Judul film)
- poster_url: String (Gambar poster film)
- base_price: Number(int) (Harga dasar tiket)
- rating: Number(Double) (Rating film, skala 1.0-5.0)
- duration: Number(int) (Durasi film dalam menit)

*C. Collection: Bookings*

Menyimpan riwayat transaksi pembelian tiket

- booking_id: String (Primary key)
- user_id: String (Foreign key ke collection Users)
- movie_title: String (Judul film yang di pesan)
- seats: Array(string) (Daftar kursi yang dipilih, contoh: A1, A2)
- total_price: Number(int) (Harga final setelah perhitungan pajak dan diskon)
- booking_date: Timestamp (Waktu transaksi dilakukan)

Screenshot Collection Users:

#image("../images/user mobile.png", width: 50%)

Screenshot Collection Movies:

#image("../images/movie firebase.png", width: 50%)

Screenshot Collection Bookings:

#image("../images/booking firebase.png", width: 50%)

== Data Seeding

Bukti seeding minimal 10 produk dummy ke Firebase. Untuk pengujian Logic Trap, maka ada seeding data sebanyak 10 film:

*1. Strategi Judul Pendek (kurang dari atau sama dengan 10 Karakter):*

Film: Up, Coco, Frozen, Venom, Dilan 1990. Ini untuk menguji bahwa harga tiket tidak dikenakan pajak tambahan.

*2. Strategi Judul Panjang (lebih dari 10 Karakter):*

Film: Spider-Man: No Way Home, Avengers: Endgame, Pengabdi Setan 2: Communion, Demon Slayer: Kimetsu no Yaiba - The Movie: Infinity Castle, KKN di Desa Penari. Ini untuk logika yang menambahkan harga sebesar Rp. 2.500.

Berikut kode untuk otomatis seeding data ke firebase (file seedMovies function):

#image("../images/movie firebase.png", width: 50%)

Proses seeding berhasil memasukkan 10 data film ke dalam Firebase Firestore dengan struktur collection Movies yang sudah ditentukan.