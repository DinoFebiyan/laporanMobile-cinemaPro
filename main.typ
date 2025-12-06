// main.typ
#import "conf.typ": project
#import "cover.typ": cover_page

// Data Kelompok (Sesuaikan dengan peran di soal)
#let members_data = (
  (name: "Nama Mhs 1", nim: "NIM001", role: "Backend Architect"), // [cite: 23]
  (name: "Nama Mhs 2", nim: "NIM002", role: "UI Engineer"),       // [cite: 28]
  (name: "Nama Mhs 3", nim: "NIM003", role: "Auth & Navigation"), // [cite: 33]
  (name: "Nama Mhs 4", nim: "NIM004", role: "Transaction Logic"), // [cite: 37]
  (name: "Nama Mhs 5", nim: "NIM005", role: "QA Lead & Integ."),  // [cite: 42]
)

#show: doc => project(
  title: "Laporan Final Project: Smart E-Kantin",
  semester: "Ganjil 2024/2025",
  team_number: "05",
  members: members_data,
  doc
)

// Generate Cover
#cover_page(
  title: "Laporan Final Project: Smart E-Kantin",
  semester: "Ganjil 2024/2025",
  team_number: "05",
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