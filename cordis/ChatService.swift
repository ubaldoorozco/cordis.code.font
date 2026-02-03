import Foundation

struct ChatAPIResponse: Decodable {
    let answer: String
}

final class ChatService {
    /// Cambia esto por tu URL real del backend (Cloudflare/Vercel/Firebase/etc)
    var endpoint: URL = URL(string: "https://TU-DOMINIO.com/chat")!

    func ask(text: String, context: String) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "text": text,
            "context": context
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "ChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: body.isEmpty ? "Error del servidor" : body])
        }

        return try JSONDecoder().decode(ChatAPIResponse.self, from: data).answer
    }
}
