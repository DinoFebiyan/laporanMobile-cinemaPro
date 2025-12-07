// main.typ
#import "conf.typ": project
#import "cover.typ": cover_page

// Data Kelompok (Sesuaikan dengan peran di soal)
#let members_data = (
  (name: "Dino Febiyan", nim: "NIM001", role: "Frontend Engineer (Home Module)"), // [cite: 23]
  (name: "Cheryl Aurellya Bangun Jaya", nim: "NIM002", role: "Backend Engineer & Data Seeder"),       // [cite: 28]
  (name: "Rusydi Jabir Al Awfa", nim: "362458302044", role: "Frontend Engineer (Seat Matrix Module)."), // [cite: 33]
  (name: "Mohammad Faisal", nim: "NIM004", role: "Logic Controller (The Brain)."), // [cite: 37]
 // (name: "Semua", nim: "", role: "QA Lead, Auth & Profile"),  // [cite: 42]
)

#show: doc => project(
  title: "Laporan Final Project : CINE-BOOKING APP",
  semester: "Ganjil 2025/2026",
  team_number: "07",
  members: members_data,
  doc
)

// Generate Cover
#cover_page(
  title: "Laporan Final Project: Cine-Booking App",
  semester: "Ganjil 2025/2026",
  team_number: "07",
  members: members_data
)

// Include Bab-bab
#include "chapters/bab1.typ"
#include "chapters/bab2.typ"
#include "chapters/bab3.typ"
#include "chapters/bab4.typ"
#include "chapters/bab5.typ"
#include "chapters/bab6.typ"
#include "chapters/bab7.typ"
