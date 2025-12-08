= Auth & Profile

Dikerjakan oleh Backend Engineer & Frontend Engineer.

== Main

Pada bagian main ini, pertama tama yang saya lakukan adalah mengaktifkan Firebase agar aplikasi bisa terhubung dengan layanan login dan database. Setelah itu saya menjalankannya dengan memanggil myapp.

Di dalam MyApp, saya pakai MaterialApp untuk mengatur tema aplikasi, seperti warna biru sebagai warna utama, font Poppins, dan menghilangkan tulisan debug di pojok. Halaman awalnya saya arahkan ke initialScreen.

Nah, di initialScreen saya membuat logika untuk menentukan halaman pertama yang muncul. Disini saya menggunakan sharedpreferences yang menyimpan user id. Kalau masih loading, tampil indikator bulat. Kalau pengguna ada di sharedpreferences, maka langsung diarahkan ke HomePage. Sedangkan kalau user id di sharedpreferences tidak ada, otomatis diarahkan ke LoginPage.

== Auth Register

Pada bagian ini saya membuat sebuah halaman yang memungkinkan pengguna bisa mendaftarkan diri di aplikasi CinemaPro. Yang mana nanti yang akan diinputkan adalah email, username, password, dan confirm password untuk konfirmasi apakah password yang diinputkan sama. Disini saya juga menambahkan sistem validasi, seperti pada email, saya menambahkan aturan bahwa alamat harus menggunakan domain kampus student.univ.ac.id, sehingga hanya mahasiswa yang bisa mendaftar dan masuk.

#image("../images/register-normal.png", width: 50%)

#image("../images/register-ditolak.png", width: 50%)

Berikut adalah kodenya untuk emailValidator untuk validasi email, username, password, dan confirm password. File ini menggunakan Regular Expression untuk memvalidasi format email dengan domain student.univ.ac.id.

Berikut adalah kodenya untuk register, yang didalamnya melakukan check apakah sesuai dengan validasi yang sudah dibuat, lalu membuat sistem menampilkan pesan error atau pesan berhasil disini, selain itu melakukan hashing password disini.

Selanjutnya saya juga menyediakan file khusus untuk melakukan hash password menggunakan dependensi crypto dan kuncinya juga sudah kita siapkan didalam file environment.

Ini untuk kode environment nya yang berisi hash key untuk keamanan password.

== Auth Login

Pada bagian login ini saya membuat sebuah halaman yang memungkinkan pengguna masuk ke aplikasi menggunakan akun yang sudah terdaftar di Firebase. Tampilan login ini terdiri dari dua input utama, yaitu email dan password, yang masing-masing dilengkapi dengan validasi. Untuk email, saya menambahkan aturan bahwa alamat harus menggunakan domain kampus student.univ.ac.id, sehingga hanya mahasiswa yang bisa mendaftar dan masuk.

#image("../images/login.png", width: 50%)

Berikut kode untuk form login dengan validasi. Form ini menggunakan FormKey untuk validasi dan TextEditingController untuk mengambil input dari pengguna.

Selain itu, saya menambahkan logika agar ketika tombol Login ditekan, aplikasi terlebih dahulu memvalidasi form. Jika valid, maka saya akan memanggil fungsi finduser yang sebelumnya sudah dibuat oleh jabir. Selama proses ini berlangsung, tombol login diganti dengan indikator loading agar pengguna tahu bahwa proses sedang berjalan. Jika login berhasil, muncul pesan Login berhasil dengan warna hijau, lalu pengguna diarahkan ke halaman utama HomePage dan data login pengguna tersebut juga saya simpan di sharedpreferences yaitu uid nya. Sebaliknya, jika login gagal, sistem menampilkan pesan error berwarna merah.

Di bagian bawah halaman, saya juga menyediakan opsi bagi pengguna yang belum memiliki akun. Terdapat teks Tidak memiliki akun dengan tombol Register yang akan mengarahkan pengguna ke halaman pendaftaran. Dengan cara ini, halaman login tidak hanya berfungsi untuk login saja, tetapi juga menjadi navigator bagi pengguna baru untuk membuat akun.

#image("../images/loginNavigatorRegister.png", width: 50%)

== Profile

Halaman profile untuk menampilkan identitas pengguna dan menampilkan riwayat transaksi. Pertama, untuk bagian header profil, saya menggunakan FutureBuilder untuk mengambil data detail pengguna (Username, Email dan saldo) dari collection users berdasarkan UID pengguna yang sedang login, kemudian data diambil dan di konversi menggunakan UserModelCheryl.

Kedua, untuk bagian Riwayat Tiket, saya menggunakan StreamBuilder. Penggunaan Stream dipilih agar daftar tiket dapat diperbarui secara real-time tanpa perlu me-refresh halaman jika ada transaksi baru. Saya menerapkan query filtering menggunakan where untuk memastikan pengguna hanya melihat tiket miliknya sendiri.

Selain itu, sesuai spesifikasi teknis, saya mengimplementasikan library qr_flutter untuk generate QR CODE secara otomatis berdasarkan booking_id dari setiap transaksi.

#image("../images/HistoryPage.jpeg", width: 50%)