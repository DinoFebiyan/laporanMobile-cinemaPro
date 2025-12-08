= Auth & Profile

Dikerjakan oleh Backend Engineer & Frontend Engineer[cite: 42].

== Main

Pada bagian main ini, pertama tama yang saya lakukan adalah mengaktifkan Firebase agar aplikasi bisa terhubung dengan layanan login dan database. setelah itu saya menjalankannya dengan memanggil myapp

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp_dino());
}
```

Di dalam MyApp_dino, saya pakai MaterialApp untuk mengatur tema aplikasi, seperti warna biru sebagai warna utama, font Poppins, dan menghilangkan tulisan “debug” di pojok. Halaman awalnya saya arahkan ke initialScreen_dino.

```dart
class MyApp_dino extends StatelessWidget {
  const MyApp_dino({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CinemaPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        textTheme: Theme.of(context).textTheme,
      ),
      debugShowCheckedModeBanner: false,
      home: const initialScreen_dino(),
    );
  }
}
```

Nah, di initialScreen_dino saya membuat logika untuk menentukan halaman pertama yang muncul. Saya menggunakan StreamBuilder untuk mengecek status login pengguna. Kalau masih loading, tampil indikator bulat. Kalau pengguna sudah login, saya melakukan pengecekan data lagi di Firestore. Kalau datanya ada, langsung masuk ke HomePage_dino. Kalau datanya gagal dimuat, muncul pesan error. Sedangkan kalau pengguna belum login, otomatis diarahkan ke LoginPage_dino.

```dart
class initialScreen_dino extends StatelessWidget {
  const initialScreen_dino({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            
            builder: (context, userSnapshot) {
              
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                return HomePage_dino();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Gagal memuat data user')),
                );
              }
            },
          );
        }
        return const LoginPage_dino();
      },
    );
  }
```

== Auth Register
Struktur branch yang digunakan sesuai instruksi[cite: 49, 50, 51, 52, 53]:
- `feature/backend-setup`
- `feature/ui-widgets`
- `feature/auth-nav`
- `feature/cart-state`
- `feature/testing-docs`

== Auth Login
Pada bagian login ini saya membuat sebuah halaman yang memungkinkan pengguna masuk ke aplikasi menggunakan akun yang sudah terdaftar di Firebase. Tampilan login ini terdiri dari dua input utama, yaitu email dan password, yang masing-masing dilengkapi dengan validasi. Untuk email, saya menambahkan aturan bahwa alamat harus menggunakan domain kampus `@student.univ.ac.id`, sehingga hanya mahasiswa yang bisa mendaftar dan masuk. Jika pengguna salah mengetik atau tidak mengisi, maka sistem langsung menampilkan pesan error dan border input berubah menjadi merah sebagai tanda visual. Hal yang sama juga berlaku pada password, di mana sistem memastikan password minimal enam karakter, dan jika tidak sesuai maka field akan ditandai dengan border merah.  

#image("../images/login.png", width: 50%) 

```dart
class _LoginPageState_dino extends State<LoginPage_dino> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),                
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!EmailValidator.isValidStudentEmail(value)) {
                    return 'Email harus @student.univ.ac.id';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),  
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
```


Selain itu, saya menambahkan logika agar ketika tombol *Login* ditekan, aplikasi terlebih dahulu memvalidasi form. Jika valid, sistem akan mencoba masuk menggunakan `FirebaseAuth.signInWithEmailAndPassword`. Selama proses ini berlangsung, tombol login diganti dengan indikator loading agar pengguna tahu bahwa proses sedang berjalan. Jika login berhasil, muncul pesan *Login berhasil* dengan warna hijau, lalu pengguna diarahkan ke halaman utama `HomePage_dino`. Sebaliknya, jika login gagal, sistem menampilkan pesan error berwarna merah sesuai dengan alasan kegagalan dari Firebase.  

#image("../images/loginEror.png", width: 50%)

```dart
  _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login_dino,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Login'),
                    ),

              const SizedBox(height: 12),

Future<void> _login_dino() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage_dino()),
      );
    }

  } on FirebaseAuthException catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```


Di bagian bawah halaman, saya juga menyediakan opsi bagi pengguna yang belum memiliki akun. Terdapat teks *Tidak memiliki akun?* dengan tombol *Register* yang akan mengarahkan pengguna ke halaman pendaftaran. Dengan cara ini, halaman login tidak hanya berfungsi untuk login saja, tetapi juga menjadi navigator bagi pengguna baru untuk membuat akun. 

#image("../images/loginNavigatorRegister.png", width: 50%)

```dart
Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tidak memiliki akun?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
```

== Profile ==
Halaman profile untuk menampilkan identitas pengguna dan menampilkan riwayat transaksi.
pertama,untuk bagaian header profil, saya menggunakan FutureBuilder untuk mengambil data detail pengguna (Username, Email dan saldo) dari collection users berdasarkan UID pengguna
yang sedang login,kemudian data diambil dan di konversi menggunakan UserModelCheryl 
FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUserId) 
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Data user tidak ditemukan di database"),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final user = UserModelCheryl.fromMapCheryl(userData);

              return Container(
                color: Colors.blue,
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            "Saldo: Rp ${user.balance}",
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

Kedua, untuk bagaian Riwayat Tiket, saya menggunakan StreamBuilder.Penggunaan Stream dipilih agar daftar tiket dapat 
diperbarui secara real-time tanpa perlu me-refresh halaman jika ada transaksi baru,saya menerapkan query filtering menggunakan
.where('user_id', isEqualTo: currentUserId) untuk memastikan pengguna hanya melihat tiket miliknya sendiri.

Selain itu, sesuai spesifikasi teknis, saya mengimplementasikan library qr_flutter untuk meng generate QR CODE untuk secara otomatis berdasarkan booking_id dari setiap transaksi
 Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('user_id', isEqualTo: _currentUserId) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_creation_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Belum ada tiket yang dibeli.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final booking = BookingModelCheryl.fromMap_Cheryl(
                        doc.data() as Map<String, dynamic>, doc.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.movieTitle,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Kursi: ${booking.seats.join(', ')}"),
                                  Text(
                                    "Total: Rp ${booking.totalPrice}",
                                    style: const TextStyle(
                                        color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Tgl: ${booking.bookingDate.toString().substring(0, 10)}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            // QR Code
                            Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: QrImageView(
                                    data: booking.bookingId,
                                    version: QrVersions.auto,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text("Scan Me", style: TextStyle(fontSize: 9)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

#images("../images/HistoryPage.jpeg", width: 50%)