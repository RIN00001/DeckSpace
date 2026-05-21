//
//  HomeView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var deckViewModel = DeckViewModel()
    
    // Mendapatkan nama hari saat ini (contoh: "Monday", "Tuesday", dst.)
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US") // Menyesuaikan dengan string array di _DeckFormView
        return formatter.string(from: Date())
    }
    
    // Menyaring deck yang aktif dan dijadwalkan hari ini
    private var scheduledDecks: [Deck] {
        deckViewModel.decks.filter { deck in
            deck.isScheduled && deck.scheduledDays.contains(currentDayName)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bagian Header Pengguna
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome, \(authViewModel.currentUser?.username ?? "User")")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Hari ini: \(getIndonesianDayName(currentDayName))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Bagian Daftar Jadwal Belajar Hari Ini
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Jadwal Belajar Hari Ini")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if deckViewModel.isLoading && deckViewModel.decks.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 150)
                        } else if scheduledDecks.isEmpty {
                            allCaughtUpView
                        } else {
                            ForEach(scheduledDecks) { deck in
                                NavigationLink {
                                    DeckDetailView(deck: deck)
                                } label: {
                                    scheduledDeckCard(deck: deck)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .task {
                await deckViewModel.fetchDecks()
            }
            .refreshable {
                await deckViewModel.fetchDecks()
            }
        }
    }

    // Tampilan jika tidak ada jadwal belajar hari ini
    private var allCaughtUpView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            
            Text("Semua Selesai!")
                .font(.headline)
            
            Text("Tidak ada deck yang dijadwalkan untuk hari ini. Silakan istirahat atau pelajari deck lain dari Library Anda.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // Komponen baris jadwal deck
    private func scheduledDeckCard(deck: Deck) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.opacity(0.14))
                    .frame(width: 56, height: 56)
                
                Image(systemName: deck.coverIconName ?? "book.closed.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(deck.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let time = deck.scheduledTime, !time.isEmpty {
                    Label(time, systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // Helper untuk mengubah nama hari ke Bahasa Indonesia di antarmuka
    private func getIndonesianDayName(_ englishDay: String) -> String {
        switch englishDay {
        case "Monday": return "Senin"
        case "Tuesday": return "Selasa"
        case "Wednesday": return "Rabu"
        case "Thursday": return "Kamis"
        case "Friday": return "Jumat"
        case "Saturday": return "Sabtu"
        case "Sunday": return "Minggu"
        default: return englishDay
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
