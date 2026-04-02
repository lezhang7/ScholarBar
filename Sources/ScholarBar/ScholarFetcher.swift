import Foundation

struct ScholarData {
    let totalCitations: Int
    let hIndex: Int
    let i10Index: Int
    let userName: String
}

final class ScholarFetcher {
    func fetch(userID: String) async throws -> ScholarData {
        let urlString = "https://scholar.google.com/citations?hl=zh-CN&user=\(userID)&view_op=list_works&sortby=pubdate"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }

        return try parse(html: html)
    }

    private func parse(html: String) throws -> ScholarData {
        // Parse citation stats from <td class="gsc_rsb_std"> tags
        // Order: [all-citations, recent-citations, all-h-index, recent-h-index, all-i10, recent-i10]
        let statsPattern = #"<td class="gsc_rsb_std">(\d+)</td>"#
        let statsRegex = try NSRegularExpression(pattern: statsPattern)
        let range = NSRange(html.startIndex..., in: html)
        let matches = statsRegex.matches(in: html, range: range)

        var values: [Int] = []
        for match in matches {
            if let valueRange = Range(match.range(at: 1), in: html) {
                if let val = Int(html[valueRange]) {
                    values.append(val)
                }
            }
        }

        guard values.count >= 5 else {
            throw URLError(.cannotParseResponse)
        }

        // Parse user name from <div id="gsc_prf_in">Name</div>
        let namePattern = #"<div id="gsc_prf_in"[^>]*>([^<]+)</div>"#
        let nameRegex = try NSRegularExpression(pattern: namePattern)
        var userName = "Scholar"
        if let nameMatch = nameRegex.firstMatch(in: html, range: range),
           let nameRange = Range(nameMatch.range(at: 1), in: html) {
            userName = String(html[nameRange]).trimmingCharacters(in: .whitespaces)
        }

        return ScholarData(
            totalCitations: values[0],
            hIndex: values[2],
            i10Index: values[4],
            userName: userName
        )
    }
}
