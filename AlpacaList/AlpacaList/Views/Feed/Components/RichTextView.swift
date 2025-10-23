//
//  RichTextView.swift
//  AlpacaList
//
//  Rich text view with facets (mentions, links, hashtags)
//

import SwiftUI

/// Renders post text with rich text features (facets)
struct RichTextView: View {
    let text: String
    let facets: [Facet]?
    let onMentionTap: ((String) -> Void)?
    let onLinkTap: ((String) -> Void)?
    let onHashtagTap: ((String) -> Void)?
    
    init(
        text: String,
        facets: [Facet]? = nil,
        onMentionTap: ((String) -> Void)? = nil,
        onLinkTap: ((String) -> Void)? = nil,
        onHashtagTap: ((String) -> Void)? = nil
    ) {
        self.text = text
        self.facets = facets
        self.onMentionTap = onMentionTap
        self.onLinkTap = onLinkTap
        self.onHashtagTap = onHashtagTap
    }
    
    var body: some View {
        if let facets = facets, !facets.isEmpty {
            // Rich text with facets
            richTextView
        } else {
            // Plain text
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var richTextView: some View {
        // TODO: Full rich text implementation with AttributedString
        // For now, render as plain text with basic link detection
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        // Future implementation will:
        // 1. Parse facets into byte ranges
        // 2. Create AttributedString with clickable segments
        // 3. Style mentions (blue), links (blue underline), hashtags (blue)
        // 4. Handle tap gestures on interactive segments
    }
}

// MARK: - Rich Text Parser (Placeholder)

extension RichTextView {
    /// Parse text segments with facet information
    /// TODO: Implement full parsing logic
    struct TextSegment: Identifiable {
        let id = UUID()
        let text: String
        let type: SegmentType
        
        enum SegmentType {
            case plain
            case mention(did: String)
            case link(url: String)
            case hashtag(tag: String)
        }
    }
    
    private func parseSegments() -> [TextSegment] {
        guard let facets = facets, !facets.isEmpty else {
            return [TextSegment(text: text, type: .plain)]
        }
        
        // TODO: Implement facet parsing
        // This would:
        // 1. Convert byte indices to character indices
        // 2. Sort facets by position
        // 3. Split text into segments
        // 4. Create TextSegment for each part
        
        return [TextSegment(text: text, type: .plain)]
    }
}

// MARK: - Simple Link Detection (Fallback)

struct SimpleLinkText: View {
    let text: String
    let onLinkTap: ((String) -> Void)?
    
    var body: some View {
        // Simple URL detection using regex
        Text(detectLinks())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func detectLinks() -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Simple URL pattern
        let pattern = "https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=]+"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let urlString = String(text[range])
                    if let startIndex = AttributedString.Index(range.lowerBound, within: attributedString),
                       let endIndex = AttributedString.Index(range.upperBound, within: attributedString) {
                        attributedString[startIndex..<endIndex].foregroundColor = .blue
                        attributedString[startIndex..<endIndex].underlineStyle = .single
                        if let url = URL(string: urlString) {
                            attributedString[startIndex..<endIndex].link = url
                        }
                    }
                }
            }
        }
        
        return attributedString
    }
}

// MARK: - Previews

struct RichTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Plain text
            RichTextView(text: "This is a plain text post with no special formatting.")
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Text with link detection
            SimpleLinkText(text: "Check out this link: https://example.com", onLinkTap: nil)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Text with potential facets (rendered as plain for now)
            RichTextView(
                text: "Hey @alice.bsky.social check out https://bsky.app #bluesky",
                facets: nil
            )
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Multiline text
            RichTextView(text: """
                This is a longer post that spans multiple lines.
                It can contain various types of content and should
                wrap nicely within the available space.
                """)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

