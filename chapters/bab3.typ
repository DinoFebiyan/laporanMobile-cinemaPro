
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
// Masukkan Screenshot Firebase Console di sini

== Data Seeding
Bukti seeding minimal 10 produk dummy ke Firebase[cite: 27].
