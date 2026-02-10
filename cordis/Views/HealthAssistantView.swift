import SwiftUI
import SwiftData

struct HealthAssistantView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \StressEntry.timestamp, order: .reverse)
    private var entries: [StressEntry]

    @Query(sort: \UserStats.lastStreakDay, order: .reverse)
    private var stats: [UserStats]

    @Query private var settingsArr: [AppSettings]
    @Query(sort: \ChatMessage.timestamp, order: .forward) private var savedMessages: [ChatMessage]
    @Environment(\.modelContext) private var modelContext

    @State private var detected: String = ""
    @State private var inMemory: [TempMessage] = []

    private var userName: String {
        let raw = settingsArr.first?.preferredName ?? ""
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "amigo" : name
    }

    private var streakDays: Int { stats.first?.streakDays ?? 0 }
    private var context: AssistContext { AssistContext(entries: entries, streakDays: streakDays) }

    private var saveChat: Bool { settingsArr.first?.saveChatHistory ?? true }

    private var currentMessages: [TempMessage] {
        if saveChat {
            return savedMessages.map { TempMessage(id: $0.id, role: $0.role, text: $0.text) }
        } else {
            return inMemory
        }
    }

    private var faqItems: [FAQItem] {
        FAQItem.build(context: context, userName: userName)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 12) {

                        summaryCard(context)

                        if !detected.isEmpty {
                            Text(String(localized: "assistant_detected \(detected)"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if !currentMessages.isEmpty {
                            ForEach(currentMessages) { msg in
                                messageBubble(role: msg.role, text: msg.text)
                            }

                            Divider().padding(.vertical, 6)
                        }

                        Text(String(localized: "assistant_questions"))
                            .font(.headline)

                        VStack(spacing: 10) {
                            ForEach(faqItems) { item in
                                Button {
                                    tapQuestion(item)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: icon(for: item.category))
                                            .foregroundColor(.secondary)
                                            .frame(width: 24)
                                        Text(item.question)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer(minLength: 4)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        }

                        Spacer(minLength: 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(String(localized: "assistant_title"))
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common_close")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !currentMessages.isEmpty {
                        Button(String(localized: "assistant_clear")) { clearChat() }
                    }
                }
            }
        }
    }

    private func tapQuestion(_ item: FAQItem) {
        detected = item.category.rawValue
        append(role: "user", text: item.question)
        append(role: "assistant", text: item.answer(context))
    }

    private func append(role: String, text: String) {
        if saveChat {
            modelContext.insert(ChatMessage(role: role, text: text))
            try? modelContext.save()
        } else {
            inMemory.append(TempMessage(role: role, text: text))
        }
    }

    private func clearChat() {
        detected = ""
        if saveChat {
            for m in savedMessages { modelContext.delete(m) }
            try? modelContext.save()
        } else {
            inMemory.removeAll()
        }
    }

    private func summaryCard(_ c: AssistContext) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "assistant_summary")).font(.headline)
            Text(String(localized: "assistant_summary_detail \(c.lastBPMText) \(c.avg7Text) \(c.streakDays)"))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func messageBubble(role: String, text: String) -> some View {
        HStack {
            if role == "assistant" {
                Text(text)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Spacer()
            } else {
                Spacer()
                Text(text)
                    .padding(12)
                    .background(Color.orange.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func icon(for cat: Category) -> String {
        switch cat {
        case .bajar: return "wind"
        case .examen: return "book"
        case .sueno: return "moon.zzz"
        case .cafeina: return "cup.and.saucer"
        case .ejercicio: return "figure.walk"
        case .promedio: return "chart.line.uptrend.xyaxis"
        case .racha: return "flame"
        case .general: return "sparkles"
        }
    }
}

// MARK: - Mensaje temporal

struct TempMessage: Identifiable {
    let id: UUID
    let role: String
    let text: String

    init(id: UUID = UUID(), role: String, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

// MARK: - Contexto

struct AssistContext {
    let lastBPM: Int?
    let avg7: Int
    let streakDays: Int

    var lastBPMText: String { lastBPM != nil ? "\(lastBPM!) bpm" : "—" }
    var avg7Text: String { avg7 > 0 ? "\(avg7) bpm" : "—" }

    init(entries: [StressEntry], streakDays: Int) {
        self.streakDays = streakDays
        self.lastBPM = entries.first?.bpm

        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -7, to: .now) ?? .now
        let last7 = entries.filter { $0.timestamp >= start }

        self.avg7 = last7.isEmpty ? 0 : Int(last7.map(\.bpm).reduce(0, +) / last7.count)
    }
}

// MARK: - FAQ

enum Category: String {
    case bajar = "bajar ritmo"
    case examen = "examen"
    case sueno = "sueño"
    case cafeina = "cafeína"
    case ejercicio = "ejercicio"
    case promedio = "promedio"
    case racha = "racha"
    case general = "general"
}

struct FAQItem: Identifiable {
    let id = UUID()
    let category: Category
    let question: String
    let keywords: [String]
    let answer: (AssistContext) -> String

    static func build(context: AssistContext, userName: String) -> [FAQItem] {
        [
            // ===== 30 originales =====

            FAQItem(category: .bajar, question: String(localized: "faq_q_01"), keywords: ["bajar","ritmo","bpm","calmar","ansiedad","estres","nervioso"], answer: { c in
                String(localized: "faq_a_01 \(userName) \(c.lastBPMText) \(c.avg7Text)")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_02"), keywords: ["acelerado","rapido","rápido","latidos","ansiedad"], answer: { _ in
                String(localized: "faq_a_02")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_03"), keywords: ["relajar","calmar","estres","ansiedad"], answer: { _ in
                String(localized: "faq_a_03")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_04"), keywords: ["enojado","coraje","molesto","alteré","altere"], answer: { _ in
                String(localized: "faq_a_04")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_05"), keywords: ["nervios","todo el dia","todo el día","ansiedad","estresado"], answer: { _ in
                String(localized: "faq_a_05")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_06"), keywords: ["examen","escuela","tarea","presentación","presentacion","nervioso"], answer: { _ in
                String(localized: "faq_a_06")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_07"), keywords: ["miedo","fallar","reprobar","pánico","panico","examen"], answer: { _ in
                String(localized: "faq_a_07")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_08"), keywords: ["concentrarme","concentración","concentracion","distra","estudiar"], answer: { _ in
                String(localized: "faq_a_08")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_09"), keywords: ["presión","presion","escuela","tareas","estrés escolar","estres escolar"], answer: { _ in
                String(localized: "faq_a_09")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_10"), keywords: ["dormí","dormi","sueño","cansado","desvelado"], answer: { _ in
                String(localized: "faq_a_10")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_11"), keywords: ["antes de dormir","dormir","noche","descansar"], answer: { _ in
                String(localized: "faq_a_11")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_12"), keywords: ["me despierto","madrugada","no duermo","despierto"], answer: { _ in
                String(localized: "faq_a_12")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_13"), keywords: ["sueño en el día","sueño en el dia","me da sueño","cansancio"], answer: { _ in
                String(localized: "faq_a_13")
            }),

            FAQItem(category: .cafeina, question: String(localized: "faq_q_14"), keywords: ["café","cafe","cafeína","cafeina","energética","energetica"], answer: { _ in
                String(localized: "faq_a_14")
            }),

            FAQItem(category: .cafeina, question: String(localized: "faq_q_15"), keywords: ["cuanta","cuánta","cafeína","cafeina","cuánto café","cuanto cafe"], answer: { _ in
                String(localized: "faq_a_15")
            }),

            FAQItem(category: .cafeina, question: String(localized: "faq_q_16"), keywords: ["energética","energetica","monster","red bull","bebida energética"], answer: { _ in
                String(localized: "faq_a_16")
            }),

            FAQItem(category: .ejercicio, question: String(localized: "faq_q_17"), keywords: ["ejercicio","gym","corrí","corri","entrené","entrene","caminé","camine"], answer: { _ in
                String(localized: "faq_a_17")
            }),

            FAQItem(category: .ejercicio, question: String(localized: "faq_q_18"), keywords: ["ejercicio","estresado","estresada","ansiedad"], answer: { _ in
                String(localized: "faq_a_18")
            }),

            FAQItem(category: .ejercicio, question: String(localized: "faq_q_19"), keywords: ["me falta aire","correr","agotado","agotada","corrí","corri"], answer: { _ in
                String(localized: "faq_a_19")
            }),

            FAQItem(category: .promedio, question: String(localized: "faq_q_20"), keywords: ["promedio","media","estadísticas","estadisticas","tendencia"], answer: { c in
                String(localized: "faq_a_20 \(c.avg7Text)")
            }),

            FAQItem(category: .promedio, question: String(localized: "faq_q_21"), keywords: ["subió","subio","esta semana","promedio"], answer: { _ in
                String(localized: "faq_a_21")
            }),

            FAQItem(category: .promedio, question: String(localized: "faq_q_22"), keywords: ["bajo","medio","alto","significa","clasificación","clasificacion"], answer: { _ in
                String(localized: "faq_a_22")
            }),

            FAQItem(category: .racha, question: String(localized: "faq_q_23"), keywords: ["racha","constancia","diario","días seguidos","dias seguidos"], answer: { c in
                String(localized: "faq_a_23 \(c.streakDays)")
            }),

            FAQItem(category: .racha, question: String(localized: "faq_q_24"), keywords: ["olvid","perdí","perdi","racha","un día","un dia"], answer: { _ in
                String(localized: "faq_a_24")
            }),

            FAQItem(category: .racha, question: String(localized: "faq_q_25"), keywords: ["hora","cuando","cuándo","medir bpm","mejor medir"], answer: { _ in
                String(localized: "faq_a_25")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_26"), keywords: ["raro","extraño","mal","no sé","no se"], answer: { _ in
                String(localized: "faq_a_26")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_27"), keywords: ["hábitos","habitos","mejorar","rutina","salud"], answer: { _ in
                String(localized: "faq_a_27")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_28"), keywords: ["redes","tiktok","instagram","celular","pantalla","notificaciones"], answer: { _ in
                String(localized: "faq_a_28")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_29"), keywords: ["confundido","confundida","qué hago","que hago","no sé","no se"], answer: { _ in
                String(localized: "faq_a_29")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_30"), keywords: ["consejo","hoy","ayuda","recomendación","recomendacion"], answer: { c in
                String(localized: "faq_a_30 \(c.lastBPMText) \(c.avg7Text)")
            }),

            // ===== 20 nuevas (extras) =====

            FAQItem(category: .bajar, question: String(localized: "faq_q_31"), keywords: ["despertar","mañana","rapido","rápido","corazon","corazón"], answer: { _ in
                String(localized: "faq_a_31")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_32"), keywords: ["muy","estresado","estresada","primero","ansiedad"], answer: { _ in
                String(localized: "faq_a_32")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_33"), keywords: ["tenso","tension","hombros","cuello","mandíbula","mandibula"], answer: { _ in
                String(localized: "faq_a_33")
            }),

            FAQItem(category: .bajar, question: String(localized: "faq_q_34"), keywords: ["tarea","tareas","mucho","altero","estres"], answer: { _ in
                String(localized: "faq_a_34")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_35"), keywords: ["blanco","me quedo en blanco","examen","mente"], answer: { _ in
                String(localized: "faq_a_35")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_36"), keywords: ["exponer","exposición","exposicion","presentación","presentacion","nervioso"], answer: { _ in
                String(localized: "faq_a_36")
            }),

            FAQItem(category: .examen, question: String(localized: "faq_q_37"), keywords: ["celular","distraer","distraigo","estudiar","tiktok","instagram"], answer: { _ in
                String(localized: "faq_a_37")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_38"), keywords: ["no me puedo dormir","insomnio","sueño","noche","dormir"], answer: { _ in
                String(localized: "faq_a_38")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_39"), keywords: ["dormi tarde","dormí tarde","escuela","cansado","mañana"], answer: { _ in
                String(localized: "faq_a_39")
            }),

            FAQItem(category: .sueno, question: String(localized: "faq_q_40"), keywords: ["clase","me duermo","sueño","cansancio"], answer: { _ in
                String(localized: "faq_a_40")
            }),

            FAQItem(category: .cafeina, question: String(localized: "faq_q_41"), keywords: ["refresco","cola","azucar","azúcar","acelerado"], answer: { _ in
                String(localized: "faq_a_41")
            }),

            FAQItem(category: .cafeina, question: String(localized: "faq_q_42"), keywords: ["cuando","dejar","cafe","café","tarde","noche"], answer: { _ in
                String(localized: "faq_a_42")
            }),

            FAQItem(category: .ejercicio, question: String(localized: "faq_q_43"), keywords: ["recuperarme","despues","después","ejercicio","gym"], answer: { _ in
                String(localized: "faq_a_43")
            }),

            FAQItem(category: .ejercicio, question: String(localized: "faq_q_44"), keywords: ["maree","mareé","ejercicio","gym","cansado"], answer: { _ in
                String(localized: "faq_a_44")
            }),

            FAQItem(category: .promedio, question: String(localized: "faq_q_45"), keywords: ["mejorando","mejorar","progreso","avance","tendencia"], answer: { c in
                String(localized: "faq_a_45 \(c.avg7Text)")
            }),

            FAQItem(category: .promedio, question: String(localized: "faq_q_46"), keywords: ["un día","un dia","alto","bajo","cambia","variación","variacion"], answer: { _ in
                String(localized: "faq_a_46")
            }),

            FAQItem(category: .racha, question: String(localized: "faq_q_47"), keywords: ["para que","para qué","sirve","racha","constancia"], answer: { _ in
                String(localized: "faq_a_47")
            }),

            FAQItem(category: .racha, question: String(localized: "faq_q_48"), keywords: ["olvida","olvido","se me olvida","medir","racha"], answer: { _ in
                String(localized: "faq_a_48")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_49"), keywords: ["hoy","sentirme mejor","mejor","bienestar"], answer: { _ in
                String(localized: "faq_a_49")
            }),

            FAQItem(category: .general, question: String(localized: "faq_q_50"), keywords: ["plan","3 minutos","tres minutos","rápido","rapido"], answer: { _ in
                String(localized: "faq_a_50")
            }),
        ]
    }
}
