= Implementasi UI Home & Detail

Dikerjakan oleh Frontend Engineer (Home Module) //[cite: 28, 33].

== UI Home

Halaman UI Home ini dirancang untuk menampilkan koleksi film dalam format grid beserta dengan judul nya. Dengan halaman ini, diharapkan pengguna akan bisa melihat berbagai film secara bersamaan dengan susunan yang rapi dan mudah untuk diakses. Ketika sebuah poster dipilih, aplikasi akan menggunakan konsep Hero widget agar muncul animasi transisi ke detail page, sehingga perpindahan menuju halaman detail film diharapkan akan lebih bagus dan menarik.

#image("../images/homePage.png", width: 50%)

 === Membuat tampilan Grid Film (SliverGridDelegate).     //[cite: 36].

Pada bagian ini saya membuat tampilan daftar film dalam bentuk grid dengan memanfaatkan GridView.builder. Untuk mengatur susunan grid, saya menggunakan SliverGridDelegateWithMaxCrossAxisExtent, di mana saya menentukan lebar maksimal setiap item sebesar 200 pixel. Dengan cara ini, tampilan home akan menjadi lebih bagus karena jumlah kolom akan menyesuaikan ukuran layar. Selain itu, saya juga menambahkan jarak antar item menggunakan crossAxisSpacing dan mainAxisSpacing, serta mengatur rasio tinggi-lebar dengan childAspectRatio agar poster film lebih rapi. Data film saya ambil dari Firebase melalui snapshot.data!.docs kemudian saya taruh ke model MovieModelCheryl. Setiap item grid saya bungkus dengan GestureDetector sehingga ketika pengguna menekan sebuah poster, aplikasi akan diarahkan ke halaman detail film (DetailPage_dino).
 
#image("../images/gridHomePage.png", width: 50%)

```dart
return GridView.builder(
  padding: const EdgeInsets.all(16.0),
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    crossAxisSpacing: 16.0,
    mainAxisSpacing: 16.0,
    childAspectRatio: 0.65,
  ),
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    final doc = snapshot.data!.docs[index];
    final movieData = doc.data() as Map<String, dynamic>;
    final movie = MovieModelCheryl.fromMap_Cheryl(movieData, doc.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage_dino(movie: movie),
          ),
        );
      },
    );
  },
);
```

 === Menggunakan widget Hero pada gambar poster agar ada animasi saat pindah ke detail.

 Untuk menampilkan poster film, saya menggunakan Image.network agar gambar bisa langsung diambil dari link URL. Poster tersebut saya bungkus dengan widget Hero yang memiliki tag unik berdasarkan ID film. Dengan cara ini, ketika pengguna menekan sebuah poster, Flutter otomatis menampilkan animasi transisi dari poster di grid menuju poster di halaman detail. Efek animasi ini akan membuat perpindahan menjadi lebih bagus. Selain itu, saya menambahkan ClipRRect agar memberikan efek sudut melengkung pada gambar, serta errorBuilder dan loadingBuilder ketika ada kondisi gambar rusak atau masih dalam proses loading.

#image("../images/hero1.png", width: 20%) #image("../images/hero2.png", width: 20%) #image("../images/hero3.png", width: 20%) #image("../images/hero4.png", width: 20%) #image("../images/hero5.png", width: 20%)

```dart
child: ClipRRect(
  borderRadius: const BorderRadius.vertical(
    top: Radius.circular(12),
  ),
  child: Hero(
    tag: movie.movieID,
    child: Image.network(
      movie.posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Image.asset(
              'assets/icons/gambarRusak.png', 
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              color: Colors.grey, 
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
  ),
);

```

==  UI Detail

Pada bagian UI Detail ini, saya membuat tampilan khusus yang berfungsi untuk menampilkan informasi lengkap mengenai film yang dipilih oleh pengguna. Halaman ini menjadi lanjutan dari UI Home, sehingga setelah pengguna menekan salah satu poster film, mereka akan diarahkan ke halaman detail. Tujuan utama dari UI Detail adalah memberikan informasi dari film, di mana pengguna bisa melihat detail film sekaligus melakukan tindakan pemesanan tiket dengan mudah.
#image("../images/detailPage.png", width: 50%)
=== Menampilkan info film.     //[cite: 34].
Untuk menampilkan informasi film, saya memanfaatkan data yang sudah diambil dari Firebase dan kemudian ditampilkan dalam bentuk teks maupun gambar. Informasi yang saya tampilkan yaitu judul film, poster, serta harga tiket yang diformat menggunakan fungsi formatPrice_dino. Fungsi ini saya buat agar harga tiket ditampilkan dalam format rupiah dengan penulisan yang rapi, misalnya “Rp 25.000”. Poster film ditampilkan menggunakan Image.network sehingga gambar bisa langsung diambil dari URL, dan saya tambahkan ClipRRect untuk memberikan efek sudut melengkung. Selain itu, saya juga menambahkan errorBuilder dan loadingBuilder untuk menangani kondisi ketika gambar rusak atau masih dalam proses loading.
#image("../images/dataFilmDetailPage.png", width: 50%)
```dart
String _formatPrice_dino(int price) {
  final priceStr = price.toString();
  final buffer = StringBuffer('Rp ');
  for (int i = 0; i < priceStr.length; i++) {
    if (i > 0 && (priceStr.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(priceStr[i]);
  }
  return buffer.toString();
}

Widget buildMovieInfo_dino(MovieModelCheryl movie) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            movie.posterUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 220,
                color: Colors.grey[300],
                child: Center(
                  child: Image.asset(
                    'assets/icons/gambarRusak.png',
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          movie.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatPrice_dino(movie.basePrice),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blueAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (movie.overview != null && movie.overview!.isNotEmpty)
          Text(
            movie.overview!,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
      ],
    ),
  );
}
```

=== Tombol ”Book Ticket” melayang (Floating Action Button) di bawah. 

Di bagian bawah halaman, saya menambahkan tombol Book Ticket yang melayang menggunakan Positioned dan ElevatedButton.icon. Tombol ini saya bungkus dengan GestureDetector sehingga posisinya bisa digeser oleh pengguna, sehingga bisa digeser sesuai kebutuhan. Saat tombol ditekan, sistem akan memeriksa apakah pengguna sudah login melalui Firebase Authentication. Jika belum login, akan muncul pesan peringatan menggunakan SnackBar. Namun jika sudah login, aplikasi akan menampilkan pesan “Sedang memproses pemesanan” dan langsung mengarahkan pengguna ke halaman pemilihan kursi (SeatMatrixJabir). Dengan adanya tombol ini, proses pemesanan tiket menjadi lebih praktis karena pengguna bisa langsung melakukan booking dari halaman detail film.

#image("../images/floating1.png", width: 30%) #image("../images/floating2.png", width: 30%) #image("../images/floating3.png", width: 30%)

```dart
double posX = 16;
double posY = 0;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final screenHeight = MediaQuery.of(context).size.height;
    setState(() {
      posY = screenHeight - 50;
    });
  });
}

Positioned(
  left: posX,
  top: posY,
  child: GestureDetector(
    onPanUpdate: (details) {
      setState(() {
        posX += details.delta.dx;
        posY += details.delta.dy;
      });
    },
    child: ElevatedButton.icon(
      onPressed: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harap Login Terlebih Dahulu!')),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sedang memproses pemesanan')),
        );
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeatMatrixJabir(
                movieTitle: movie.title,
                userId: user.uid,
                totalPrice: movie.basePrice,
              ),
            ),
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: Image.asset(
        'assets/icons/ticket.png',
        width: 24,
        height: 24,
        color: Colors.white,
      ),
      label: const Text(
        'Book Ticket',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
)
```

==  Constraint
=== Layout harus responsif di HP kecil maupun besar.

Pada bagian constraint ini, saya akan memberikan bukti bahwa tampilan aplikasi benar benar responsif, artinya bisa menyesuaikan dengan berbagai ukuran layar ponsel. Sebelumnya saya menggunakan SliverGridDelegateWithMaxCrossAxisExtent untuk menampilkan daftar film dalam bentuk grid. Dengan cara ini, setiap item grid akan memiliki lebar maksimal tertentu, sehingga jumlah kolom akan otomatis menyesuaikan ukuran layar.
#image("../images/homePage.png", width: 40%) #image("../images/homePageTablet.png", width: 40%)
Ketika saya mencoba aplikasi di emulator dengan layar kecil, grid hanya menampilkan dua kolom agar poster tetap terlihat jelas dan tidak terlalu sempit. Sebaliknya, saat saya jalankan di layar yang lebih besar, jumlah kolom bertambah, sehingga ruang kosong bisa dimanfaatkan dengan baik. Hal ini menunjukkan bahwa penggunaan sliver membuat layout lebih fleksibel dan tetap rapi di berbagai ukuran layar.

Dengan cara ini, constraint “layout harus responsif” terbukti sudah terpenuhi, karena tampilan aplikasi tidak pecah atau berantakan meskipun dicoba di perangkat dengan resolusi berbeda. Bukti implementasi dapat dilihat langsung saat aplikasi dijalankan di emulator atau ponsel dengan ukuran layar berbeda, grid film tetap rapi serta poster tidak terpotong.