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
Pada bagian ini saya membuat sebuah halaman yang memungkinkan pengguna bisa mendaftarkan diri di aplikasi CinemaPro. yang mana nanti yang akan diinputkan adalah email, username, password, dan confirm password untuk konfirmasi apakah password yang diinputkan sama, disini saya juga menambahkan sistem validasi, seperti pada email, saya menambahkan aturan bahwa alamat harus menggunakan domain kampus `@student.univ.ac.id`, sehingga hanya mahasiswa yang bisa mendaftar dan masuk. Jika pengguna salah mengetik atau tidak mengisi, maka sistem langsung menampilkan pesan error dan border input berubah menjadi merah sebagai tanda visual. Hal yang sama juga berlaku pada password, di mana sistem memastikan password minimal enam karakter, dan jika tidak sesuai maka field akan ditandai dengan border merah, cuman disini saya menulis kodenya di file yang berbeda agar lebih rapih, bukan hanya sistem validasi, saya juga membuat sistem hashPassword untuk melakukan hashing password agar nantinya bisa digunakan untuk login.

#image("../images/register-normal.png", width: 50%) 

#image("../images/register-ditolak.png", width: 50%) 

berikut adalah kodenya untuk emailValidator_jabir.dart untuk validasi email,username,password, dan confirm password
```dart
/// emailValidator_jabir.dart
class EmailValidator {
  /// Validates if an email is in the format required: @student.univ.ac.id
  static bool isValidStudentEmail(String email) {
    // Regex pattern to match emails ending with @student.univ.ac.id
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@student\.univ\.ac\.id$');
    return emailRegex.hasMatch(email);
  }
}

/// Data structure for registration form validation (for UI validation)
class RegistrationForm {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;

  RegistrationForm({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  /// Validates all registration form fields
  String? validate() {
    // Email validation
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!EmailValidator.isValidStudentEmail(email)) {
      return 'Email must end with @student.univ.ac.id';
    }

    // Username validation
    if (username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Password validation
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Confirm password validation
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // All validations passed
  }
}
```

berikut adalah kodenya untuk register-jabir.dart, yang didalamnya melakukan check apakah sesuai dengan validasi yang sudah dibuat, lalu membuat sistem menampilkan pesan error atau pesan berhasil disini, selain itu melakukan hashing password disini.
```dart
  //register-jabir.dart
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      bool emailExists = await _userService.isEmailExists(_emailController.text.trim());
      if (emailExists) {
        throw Exception('email-already-in-use');
      }

      // Create user with hashed password in database
      bool success = await _userService.createUserWithPassword(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to home screen
        Navigator.pop(context);
      } else {
        throw Exception('Registration failed');
      }
    } on Exception catch (e) {
      String errorMessage = 'Registration failed';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'This email is already registered';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
```

Selanjutnya saya juga menyediakan file khusus untuk melakukan hash password menggunakan dependensi crypto dan kuncinya juga sudah kita siapkan didalam .env.

```dart
// passwordHash_jabir.dart
class PasswordHashUtil {
  /// Hash a password using SHA256 algorithm with the project's secret key as salt
  static Future<String> hashPassword(String password) async {
    // Load the hash key from .env file
    await dotenv.load(fileName: ".env");
    String hashKey = dotenv.env['HASH_KEY'];

    // Create salted password
    String saltedPassword = password + hashKey;

    // Hash using SHA256
    var bytes = utf8.encode(saltedPassword);
    var digest = sha256.convert(bytes);

    print('Hashing password: $password -> ${digest.toString()}'); // Debug log
    return digest.toString(); // Returns hex representation of the hash
  }

  /// Verify a password against its hash
  static Future<bool> verifyPassword(String password, String hash) async {
    try {
      // Recompute the hash using the same parameters and compare
      String computedHash = await hashPassword(password);
      print('Verifying: computed=$computedHash, stored=$hash, match=${computedHash == hash}'); // Debug log

      // Compare the computed hash with the stored hash
      return computedHash == hash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }
}
```

ini untuk kode .env nya

```env
HASH_KEY=ProjectNASA_Poliwangi_-_7878HAShPassWordiaxcc
```


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


Selain itu, saya menambahkan logika agar ketika tombol *Login* ditekan, aplikasi terlebih dahulu memvalidasi form. Jika valid, maka saya akan memanggil fungsi finduser yang sebelumnya sudah dibuat oleh jabir. Selama proses ini berlangsung, tombol login diganti dengan indikator loading agar pengguna tahu bahwa proses sedang berjalan. Jika login berhasil, muncul pesan *Login berhasil* dengan warna hijau, lalu pengguna diarahkan ke halaman utama `HomePage_dino` dan data login pengguna tersebut juga saya simpan di sharedpreferences yaitu uid nya. Sebaliknya, jika login gagal, sistem menampilkan pesan error berwarna merah
  
  ```dart
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isLoading = true;
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
        isLoading = false;
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