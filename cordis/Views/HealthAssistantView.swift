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

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {

                        summaryCard(context)

                        if !detected.isEmpty {
                            Text(String(localized: "assistant_detected \(detected)"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
                                        Text(item.question)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
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
                    .padding()
                }
            }
            .navigationTitle(String(localized: "assistant_title"))
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common_close")) { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !currentMessages.isEmpty {
                        Button(String(localized: "assistant_clear")) { clearChat() }
                            .foregroundStyle(.white)
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
            Text("Resumen").font(.headline)
            Text("Último: \(c.lastBPMText) • 7 días: \(c.avg7Text) • Racha: \(c.streakDays) días")
                .foregroundColor(.secondary)
        }
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

            FAQItem(category: .bajar, question: "¿Cómo bajo mi ritmo ahora?", keywords: ["bajar","ritmo","bpm","calmar","ansiedad","estres","nervioso"], answer: { c in
                """
                \(userName), tus datos:
                • Último: \(c.lastBPMText)
                • Promedio 7 días: \(c.avg7Text)

                Para bajarlo ahora (2–3 min):
                • Inhala 4s, exhala 6–8s (6 veces)
                • Toma agua
                • Baja estímulos 5–10 min
                """
            }),

            FAQItem(category: .bajar, question: "Me siento acelerado, ¿qué hago?", keywords: ["acelerado","rapido","rápido","latidos","ansiedad"], answer: { _ in
                """
                Haz una pausa:
                • Siéntate recto
                • Exhala lento (más largo que inhalar)
                • 6 ciclos de 4s / 6–8s
                • Agua y descansa 5 min
                """
            }),

            FAQItem(category: .bajar, question: "¿Cómo me relajo rápido?", keywords: ["relajar","calmar","estres","ansiedad"], answer: { _ in
                """
                Rápido:
                • Inhala 4s
                • Exhala 6–8s
                • Repite 1 minuto
                Después: agua y pausa sin pantalla 5 min.
                """
            }),

            FAQItem(category: .bajar, question: "¿Qué hago si estoy enojado y mi ritmo sube?", keywords: ["enojado","coraje","molesto","alteré","altere"], answer: { _ in
                """
                Cuando te enojas, el cuerpo se prende.
                • Exhala lento 10 veces
                • Suelta hombros y mandíbula
                • Aléjate 2 minutos de la situación
                """
            }),

            FAQItem(category: .bajar, question: "¿Qué hago si siento nervios todo el día?", keywords: ["nervios","todo el dia","todo el día","ansiedad","estresado"], answer: { _ in
                """
                Mini plan del día:
                • 3 pausas de respiración (1 min cada una)
                • 10 min caminata suave
                • Menos pantallas en la tarde
                • Dormir a la misma hora
                """
            }),

            FAQItem(category: .examen, question: "Estoy nervioso por un examen", keywords: ["examen","escuela","tarea","presentación","presentacion","nervioso"], answer: { _ in
                """
                Plan rápido (2–3 min):
                • 6 respiraciones lentas (4s / 6–8s)
                • Relaja hombros y mandíbula
                • Enfócate en la primera pregunta y avanza paso a paso
                """
            }),

            FAQItem(category: .examen, question: "Me da miedo fallar en un examen", keywords: ["miedo","fallar","reprobar","pánico","panico","examen"], answer: { _ in
                """
                Truco mental:
                • “Solo hago el siguiente paso”
                • Respira 6 veces lento
                • Empieza por la pregunta más fácil
                """
            }),

            FAQItem(category: .examen, question: "No puedo concentrarme estudiando", keywords: ["concentrarme","concentración","concentracion","distra","estudiar"], answer: { _ in
                """
                Método rápido:
                • 10 min enfoque (sin celular)
                • 2 min descanso
                • Repite 3 veces
                """
            }),

            FAQItem(category: .examen, question: "Me siento presionado por la escuela", keywords: ["presión","presion","escuela","tareas","estrés escolar","estres escolar"], answer: { _ in
                """
                Baja la presión en pasos:
                • Escribe 3 tareas (solo 3)
                • Empieza por la más corta
                • Descanso 2 min cada 10–15 min
                """
            }),

            FAQItem(category: .sueno, question: "No dormí bien", keywords: ["dormí","dormi","sueño","cansado","desvelado"], answer: { _ in
                """
                Hoy:
                • Evita cafeína si te acelera
                • Toma agua
                • Siesta corta 15–25 min si puedes
                • Duerme más temprano
                """
            }),

            FAQItem(category: .sueno, question: "¿Qué hago antes de dormir para descansar mejor?", keywords: ["antes de dormir","dormir","noche","descansar"], answer: { _ in
                """
                Antes de dormir:
                • Apaga pantallas 30 min antes
                • Luz baja
                • Respiración lenta 2 min
                • Estiramiento suave 1 min
                """
            }),

            FAQItem(category: .sueno, question: "Me despierto en la noche", keywords: ["me despierto","madrugada","no duermo","despierto"], answer: { _ in
                """
                Si te despiertas:
                • No agarres el celular
                • Respira lento 1 minuto
                • Vuelve a acostarte cómodo
                """
            }),

            FAQItem(category: .sueno, question: "Tengo sueño en el día", keywords: ["sueño en el día","sueño en el dia","me da sueño","cansancio"], answer: { _ in
                """
                Para aguantar:
                • Agua
                • Caminar 5–10 min
                • Luz natural
                • Siesta 15–20 min si puedes
                """
            }),

            FAQItem(category: .cafeina, question: "Tomé café y me siento acelerado", keywords: ["café","cafe","cafeína","cafeina","energética","energetica"], answer: { _ in
                """
                La cafeína puede subir el ritmo.
                • No tomes más hoy
                • Agua + respiración lenta 2–3 min
                • Descansa sin pantallas
                """
            }),

            FAQItem(category: .cafeina, question: "¿Cuánta cafeína debería tomar?", keywords: ["cuanta","cuánta","cafeína","cafeina","cuánto café","cuanto cafe"], answer: { _ in
                """
                Depende de tu cuerpo.
                Si te acelera:
                • Toma menos
                • Evita en la tarde/noche
                • Cambia por agua
                """
            }),

            FAQItem(category: .cafeina, question: "Tomé energética, ¿qué hago?", keywords: ["energética","energetica","monster","red bull","bebida energética"], answer: { _ in
                """
                Haz esto:
                • No tomes otra
                • Agua
                • Respiración lenta 2–3 min
                • Baja estímulos
                """
            }),

            FAQItem(category: .ejercicio, question: "Vengo de ejercicio", keywords: ["ejercicio","gym","corrí","corri","entrené","entrene","caminé","camine"], answer: { _ in
                """
                Si venías de ejercicio es normal.
                • Camina suave 3–5 min
                • Respira lento (exhala más largo)
                • Hidrátate
                """
            }),

            FAQItem(category: .ejercicio, question: "¿Está bien hacer ejercicio si estoy estresado?", keywords: ["ejercicio","estresado","estresada","ansiedad"], answer: { _ in
                """
                Sí, pero suave:
                • Caminata 10–20 min
                • Estiramiento
                • Evita intensidad alta si ya estás acelerado
                """
            }),

            FAQItem(category: .ejercicio, question: "Me falta aire después de correr", keywords: ["me falta aire","correr","agotado","agotada","corrí","corri"], answer: { _ in
                """
                Baja el ritmo:
                • Camina suave
                • Respira lento
                • Agua
                Si no mejora, pide ayuda a un adulto.
                """
            }),

            FAQItem(category: .promedio, question: "¿Cómo va mi promedio?", keywords: ["promedio","media","estadísticas","estadisticas","tendencia"], answer: { c in
                """
                Tu promedio 7 días: \(c.avg7Text)
                Lo importante es ver patrones.
                Si sube varios días: revisa sueño, cafeína, agua y respiración.
                """
            }),

            FAQItem(category: .promedio, question: "¿Por qué mi promedio subió esta semana?", keywords: ["subió","subio","esta semana","promedio"], answer: { _ in
                """
                Cosas comunes:
                • dormir poco
                • más cafeína
                • más estrés
                • menos agua
                Revisa qué cambió esta semana.
                """
            }),

            FAQItem(category: .promedio, question: "¿Qué significa Bajo / Medio / Alto?", keywords: ["bajo","medio","alto","significa","clasificación","clasificacion"], answer: { _ in
                """
                Es una guía simple:
                • Bajo: debajo de lo esperado
                • Medio: dentro del rango esperado
                • Alto: arriba de lo esperado
                Lo ideal es ver patrones, no un solo registro.
                """
            }),

            FAQItem(category: .racha, question: "¿Cómo subo mi racha?", keywords: ["racha","constancia","diario","días seguidos","dias seguidos"], answer: { c in
                """
                Tu racha: \(c.streakDays) días.
                • Mide 1 vez al día a la misma hora
                • Pon un recordatorio
                • Consistencia > perfección
                """
            }),

            FAQItem(category: .racha, question: "Se me olvidó un día, ¿perdí mi racha?", keywords: ["olvid","perdí","perdi","racha","un día","un dia"], answer: { _ in
                """
                A veces pasa.
                • Retoma hoy
                • Pon recordatorio
                • Lo importante es volver
                """
            }),

            FAQItem(category: .racha, question: "¿A qué hora es mejor medir mi BPM?", keywords: ["hora","cuando","cuándo","medir bpm","mejor medir"], answer: { _ in
                """
                Ideal:
                • Misma hora cada día
                • En reposo (calmado)
                Ej: al despertar o antes de dormir.
                """
            }),

            FAQItem(category: .general, question: "¿Por qué me siento raro hoy?", keywords: ["raro","extraño","mal","no sé","no se"], answer: { _ in
                """
                Puede ser por sueño, estrés, comida, agua o cafeína.
                Dime:
                1) ¿Dormiste bien?
                2) ¿Tomaste cafeína?
                3) ¿Venías de ejercicio?
                """
            }),

            FAQItem(category: .general, question: "¿Qué hábitos mejoran mi ritmo en general?", keywords: ["hábitos","habitos","mejorar","rutina","salud"], answer: { _ in
                """
                Hábitos simples:
                • Dormir bien
                • Tomar agua
                • Caminar 10–20 min
                • Menos pantallas en la noche
                • Respiración 2 min al día
                """
            }),

            FAQItem(category: .general, question: "¿Qué hago si me estreso por redes sociales?", keywords: ["redes","tiktok","instagram","celular","pantalla","notificaciones"], answer: { _ in
                """
                Prueba:
                • Pausa 10 min sin notificaciones
                • Agua
                • Respiración lenta 1–2 min
                • Vuelve y limita el tiempo
                """
            }),

            FAQItem(category: .general, question: "¿Qué hago si no sé qué me pasa?", keywords: ["confundido","confundida","qué hago","que hago","no sé","no se"], answer: { _ in
                """
                Vamos en orden:
                1) Respira lento 1 minuto
                2) Toma agua
                3) Siéntate 2 minutos
                """
            }),

            FAQItem(category: .general, question: "Dame un consejo para hoy", keywords: ["consejo","hoy","ayuda","recomendación","recomendacion"], answer: { c in
                """
                Consejo de hoy:
                • 10 min caminata suave
                • 2 vasos de agua extra
                • 1 minuto de respiración lenta

                Tus datos: último \(c.lastBPMText) • 7 días \(c.avg7Text).
                """
            }),

            // ===== 20 nuevas (extras) =====

            FAQItem(category: .bajar, question: "Siento mi corazón rápido al despertar", keywords: ["despertar","mañana","rapido","rápido","corazon","corazón"], answer: { _ in
                """
                Al despertar puede pasar por estrés, poco sueño o cafeína del día anterior.
                • Respira lento 1 minuto (exhala más largo)
                • Toma agua
                • Muévete suave 2–3 min
                """
            }),

            FAQItem(category: .bajar, question: "Estoy muy estresado, ¿qué hago primero?", keywords: ["muy","estresado","estresada","primero","ansiedad"], answer: { _ in
                """
                Primero baja el modo alarma:
                1) Exhala lento 10 veces
                2) Toma agua
                3) Siéntate 2 minutos sin pantalla
                """
            }),

            FAQItem(category: .bajar, question: "Me siento tenso (hombros/cuello)", keywords: ["tenso","tension","hombros","cuello","mandíbula","mandibula"], answer: { _ in
                """
                • Hombros arriba 3s y suelta (x5)
                • Afloja mandíbula
                • 6 respiraciones lentas
                """
            }),

            FAQItem(category: .bajar, question: "Me altero cuando tengo mucha tarea", keywords: ["tarea","tareas","mucho","altero","estres"], answer: { _ in
                """
                • Elige 1 tarea pequeña y empieza 5 minutos
                • Descansa 2 minutos
                • Repite
                """
            }),

            FAQItem(category: .examen, question: "¿Qué hago si me quedo en blanco en el examen?", keywords: ["blanco","me quedo en blanco","examen","mente"], answer: { _ in
                """
                • Respira 3 veces lento
                • Lee la pregunta despacio
                • Empieza por lo más fácil
                """
            }),

            FAQItem(category: .examen, question: "Estoy nervioso antes de exponer", keywords: ["exponer","exposición","exposicion","presentación","presentacion","nervioso"], answer: { _ in
                """
                • 6 respiraciones lentas
                • Suelta hombros
                • Habla más lento de lo normal
                """
            }),

            FAQItem(category: .examen, question: "¿Cómo estudio sin distraerme con el celular?", keywords: ["celular","distraer","distraigo","estudiar","tiktok","instagram"], answer: { _ in
                """
                • Celular lejos
                • 10 min estudio / 2 min descanso
                • En el descanso: agua, no redes
                """
            }),

            FAQItem(category: .sueno, question: "Tengo sueño pero no me puedo dormir", keywords: ["no me puedo dormir","insomnio","sueño","noche","dormir"], answer: { _ in
                """
                • Apaga pantalla
                • Respira lento 2 min
                • Relaja cuerpo (mandíbula/hombros)
                """
            }),

            FAQItem(category: .sueno, question: "¿Qué hago si dormí tarde y hoy tengo escuela?", keywords: ["dormi tarde","dormí tarde","escuela","cansado","mañana"], answer: { _ in
                """
                • Agua y luz natural
                • Comida ligera
                • Siesta 15–20 min si puedes
                • Hoy duerme más temprano
                """
            }),

            FAQItem(category: .sueno, question: "Me duermo en clase", keywords: ["clase","me duermo","sueño","cansancio"], answer: { _ in
                """
                • Agua
                • Respira profundo 5 veces
                • Estira espalda/hombros discretamente
                """
            }),

            FAQItem(category: .cafeina, question: "Tomé refresco y me siento acelerado", keywords: ["refresco","cola","azucar","azúcar","acelerado"], answer: { _ in
                """
                • Agua
                • Respiración lenta 2 min
                • Evita más azúcar hoy
                """
            }),

            FAQItem(category: .cafeina, question: "¿Cuándo debo dejar de tomar café en el día?", keywords: ["cuando","dejar","cafe","café","tarde","noche"], answer: { _ in
                """
                Si te afecta el sueño:
                • Evita cafeína desde la tarde
                • Mejor agua o algo sin cafeína
                """
            }),

            FAQItem(category: .ejercicio, question: "¿Qué hago para recuperarme después del ejercicio?", keywords: ["recuperarme","despues","después","ejercicio","gym"], answer: { _ in
                """
                • Camina suave 3–5 min
                • Agua
                • Respira lento
                """
            }),

            FAQItem(category: .ejercicio, question: "Me mareé un poco después de hacer ejercicio", keywords: ["maree","mareé","ejercicio","gym","cansado"], answer: { _ in
                """
                • Siéntate
                • Agua
                • Respira lento
                Si sigue fuerte, pide ayuda a un adulto.
                """
            }),

            FAQItem(category: .promedio, question: "¿Cómo sé si estoy mejorando?", keywords: ["mejorando","mejorar","progreso","avance","tendencia"], answer: { c in
                """
                Señales:
                • Promedio 7 días baja o se mantiene estable
                • Te sientes más calmado
                Hoy: \(c.avg7Text).
                """
            }),

            FAQItem(category: .promedio, question: "¿Por qué un día salió alto y otro día bajo?", keywords: ["un día","un dia","alto","bajo","cambia","variación","variacion"], answer: { _ in
                """
                Es normal por:
                • Sueño, cafeína, estrés o ejercicio
                Lo importante es el patrón de varios días.
                """
            }),

            FAQItem(category: .racha, question: "¿Para qué sirve la racha?", keywords: ["para que","para qué","sirve","racha","constancia"], answer: { _ in
                """
                La racha te ayuda a ser constante para ver patrones reales.
                """
            }),

            FAQItem(category: .racha, question: "¿Qué hago si se me olvida medir?", keywords: ["olvida","olvido","se me olvida","medir","racha"], answer: { _ in
                """
                • Pon recordatorio
                • Elige una hora fija
                • Únelo a un hábito (dientes / antes de dormir)
                """
            }),

            FAQItem(category: .general, question: "¿Qué puedo hacer hoy para sentirme mejor?", keywords: ["hoy","sentirme mejor","mejor","bienestar"], answer: { _ in
                """
                • Agua
                • 10 min caminata
                • 2 min respiración lenta
                • Menos pantalla en la tarde
                """
            }),

            FAQItem(category: .general, question: "Dame un plan rápido de 3 minutos", keywords: ["plan","3 minutos","tres minutos","rápido","rapido"], answer: { _ in
                """
                Plan 3 min:
                1) Respira lento 1 min
                2) Estira hombros/cuello 1 min
                3) Agua + pausa sin pantalla 1 min
                """
            }),
        ]
    }
}
