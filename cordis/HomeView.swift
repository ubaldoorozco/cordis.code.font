//
//  HomeView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \StressEntry.timestamp, order: .reverse) private var entries: [StressEntry]
    @Query private var statsArr: [UserStats]
    @Query private var settingsArr: [AppSettings]

    @State private var bpmInput = ""
    @State private var explosion = false
    @State private var confetti = false
    @State private var showingMeditation = false

    @FocusState private var bpmFocused: Bool

    private var settings: AppSettings? { settingsArr.first }
    private var ageGroup: Int { settings?.ageGroup ?? 2 }

    private var ultimo: StressEntry? { entries.first }
    private var ultimoBPM: Int { ultimo?.bpm ?? 0 }
    private var necesitaMeditar: Bool {
        let t = StressEntry.thresholds(for: ultimo?.ageGroup ?? ageGroup)
        return ultimoBPM > t.max
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: explosion ? [.red, .black] : [.purple, .indigo],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: explosion)

                if confetti { ConfettiView() }

                ScrollView {
                    VStack(spacing: 24) {
                        Text("CORDIS")
                            .font(.system(size: 50, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 10)

                        VStack(spacing: 14) {
                            Text("¿Cuál fue tu BPM?")
                                .font(.title.bold())
                                .foregroundColor(.white)

                            TextField(
                                "",
                                text: $bpmInput,
                                prompt: Text("88").foregroundStyle(.white.opacity(0.5))
                            )
                            .font(.system(size: 70, weight: .black))
                            .foregroundStyle(.white)
#if os(iOS)
                            .keyboardType(.numberPad)
#endif
                            .multilineTextAlignment(.center)
                            .padding(30)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30).stroke(.white, lineWidth: 5)
                            )
                            .focused($bpmFocused)
                            .onTapGesture { bpmFocused = true }
                            .onChange(of: bpmInput) { _, newValue in
                                bpmInput = newValue.filter(\.isNumber)
                            }
#if os(iOS)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Listo") { bpmFocused = false }
                                }
                            }
#endif
                            .padding(.horizontal, 30)

                            VStack(alignment: .leading, spacing: 10) {
                                if let ultimo {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                        Text("Último registro: \(relativeString(since: ultimo.timestamp))")
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.95))

                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "sparkles").padding(.top, 2)
                                        Text(consejoPara(bpm: ultimo.bpm, ageGroup: ultimo.ageGroup))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                        Text("Aún no hay mediciones guardadas.")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                }

                                let days = statsArr.first?.streakDays ?? 0
                                HStack {
                                    Image(systemName: "flame.fill")
                                    Text(streakText(days: days))
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.95))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.14))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.white.opacity(0.25), lineWidth: 1)
                            )
                            .padding(.horizontal, 30)

                            Button("Analizar") { analizar() }
                                .font(.title.bold())
                                .frame(maxWidth: .infinity)
                                .padding(24)
                                .background(
                                    LinearGradient(colors: [.orange, .red],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .shadow(radius: 20)
                                .padding(.horizontal, 30)
                        }

                        if let ultimo = entries.first {
                            VStack(spacing: 12) {
                                Text("Nivel actual")
                                    .font(.title2).bold()
                                    .foregroundColor(.white.opacity(0.8))

                                Text(localizedStressLevel(ultimo.stressLevel))
                                    .font(.system(size: 36, weight: .black))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(ultimo.color.opacity(0.9))
                                    .cornerRadius(25)
                                    .padding(.horizontal, 30)

                                Text("\(ultimo.bpm) bpm")
                                    .font(.title3).bold()
                                    .foregroundColor(.white)
                            }
                        }

                        if necesitaMeditar {
                            Button {
                                showingMeditation = true
                            } label: {
                                Label("Meditación de emergencia", systemImage: "brain.head.profile")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(24)
                                    .background(.red.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                                    .shadow(radius: 20)
                            }
                            .padding(.horizontal, 30)
                            .sheet(isPresented: $showingMeditation) {
                                MeditationView()
                            }
                        }

                        Text("Mediciones guardadas: \(entries.count)")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))

                        Button(role: .destructive) {
                            borrarTodo()
                        } label: {
                            Label("Borrar historial", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding(14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.black.opacity(0.35))
                        .padding(.horizontal, 30)

                        Spacer(minLength: 90)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("CORDIS")
            .onAppear { ensureStatsExists() }
        }
    }

    private func ensureStatsExists() {
        if statsArr.isEmpty {
            context.insert(UserStats())
            do { try context.save() } catch { print("SAVE ERROR (stats bootstrap):", error) }
        }
    }

    private func analizar() {
        ensureStatsExists()

        let trimmed = bpmInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let bpm = Int(trimmed), (30...220).contains(bpm) else {
            bpmInput = ""
            return
        }

        let nuevo = StressEntry(bpm: bpm, ageGroup: ageGroup)
        context.insert(nuevo)
        updateStreak(for: Date())

        do { try context.save() } catch { print("SAVE ERROR (entry):", error) }

        bpmInput = ""
        bpmFocused = false

        let t = StressEntry.thresholds(for: ageGroup)

        if bpm >= t.min && bpm <= (t.min + 10) {
            confetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { confetti = false }
        }
        if bpm > t.max {
            explosion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { explosion = false }
        }
    }

    private func borrarTodo() {
        for e in entries { context.delete(e) }
        do { try context.save() } catch { print("SAVE ERROR (delete all):", error) }
    }

    private func updateStreak(for now: Date) {
        guard let stats = statsArr.first else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)

        guard let last = stats.lastStreakDay else {
            stats.streakDays = 1
            stats.lastStreakDay = today
            return
        }

        if cal.isDate(last, inSameDayAs: today) { return }

        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.isDate(last, inSameDayAs: yesterday) {
            stats.streakDays += 1
            stats.lastStreakDay = today
            return
        }

        stats.streakDays = 1
        stats.lastStreakDay = today
    }

    private func relativeString(since date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = .current
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func consejoPara(bpm: Int, ageGroup: Int) -> String {
        let t = StressEntry.thresholds(for: ageGroup)
        if bpm < t.min { return "Tu BPM está por debajo del rango esperado. Si te sientes mal, consulta a un médico." }
        if bpm > t.max { return "Tu BPM está alto. Respira profundo, descansa y considera la meditación." }

        if bpm < (t.min + 10) { return "¡Excelente! Tu ritmo está en un rango muy bueno." }
        if bpm < (t.max - 15) { return "Normal. Mantén buenos hábitos: sueño, agua y actividad ligera." }
        return "Elevado. Baja el ritmo: respira, siéntate y evita esfuerzo por un momento."
    }

    private func streakText(days: Int) -> String {
        if days <= 0 { return "Racha: 0 días" }
        return days == 1 ? "Racha: 1 día" : "Racha: \(days) días"
    }

    private func localizedStressLevel(_ raw: String) -> String {
        switch raw.lowercased() {
        case "excelente": return "Excelente"
        case "normal": return "Normal"
        case "elevado": return "Elevado"
        case "arritmia": return "Arritmia"
        case "paro cardiaco": return "Paro cardiaco"
        default: return raw
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
