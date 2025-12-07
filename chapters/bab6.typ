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

Nah, di initialScreen_dino saya membuat logika untuk menentukan halaman pertama yang muncul. Disini saya menggunakan sharedpreferences yang menyimpan user id. Kalau masih loading, tampil indikator bulat. Kalau pengguna ada di sharedpreferences, maka langsung diarahkan ke HomePage_dino. Sedangkan kalau user id di sharedpreferences tidak ada, otomatis diarahkan ke LoginPage_dino.

```dart
class initialScreen_dino extends StatelessWidget {
  const initialScreen_dino({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('user_uid'),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return const HomePage_dino();
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


Selain itu, saya menambahkan logika agar ketika tombol *Login* ditekan, aplikasi terlebih dahulu memvalidasi form. Jika valid, maka saya akan memanggil fungsi finduser yang sebelumnya sudah dibuat oleh jabir. Selama proses ini berlangsung, tombol login diganti dengan indikator loading agar pengguna tahu bahwa proses sedang berjalan. Jika login berhasil, muncul pesan *Login berhasil* dengan warna hijau, lalu pengguna diarahkan ke halaman utama `HomePage_dino` dan data login pengguna tersebut juga saya simpan di sharedpreferences yaitu uid nya. Sebaliknya, jika login gagal, sistem menampilkan pesan error berwarna merahFuture<void> _login_dino() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Use your custom service to find and verify user
    UserService userService = UserService();
    UserModelCheryl? user = await userService.findUserByEmailAndPassword(
      emailController.text.trim(),
      passwordController.text,
    );

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', user.uid);

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage_dino()),
        );
      }
    } else {
      // Login failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString()}'),
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