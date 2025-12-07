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

== Profile