//
//  PlaceholderImageView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI
import WebKit

struct PlaceholderImageView: View {
    let selectedBodyParts: [ExtendedBodyPart]
    let colors: [String]
    let side: ViewSide
    let onBodyPartPress: ((ExtendedBodyPart, BodySide?) -> Void)?
    
    init(
        selectedBodyParts: [ExtendedBodyPart] = [],
        colors: [String] = ["#0984e3", "#74b9ff"],
        side: ViewSide = .front,
        onBodyPartPress: ((ExtendedBodyPart, BodySide?) -> Void)? = nil
    ) {
        self.selectedBodyParts = selectedBodyParts
        self.colors = colors
        self.side = side
        self.onBodyPartPress = onBodyPartPress
    }
    
    var body: some View {
        BodyWebView(
            selectedBodyParts: selectedBodyParts,
            colors: colors,
            side: side,
            onBodyPartPress: onBodyPartPress
        )
        .frame(height: 400)
        .cornerRadius(12)
    }
}

struct BodyWebView: UIViewRepresentable {
    let selectedBodyParts: [ExtendedBodyPart]
    let colors: [String]
    let side: ViewSide
    let onBodyPartPress: ((ExtendedBodyPart, BodySide?) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = generateSVGHTML()
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BodyWebView
        
        init(_ parent: BodyWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               url.scheme == "bodypart" {
                // Handle body part clicks
                let components = url.absoluteString.replacingOccurrences(of: "bodypart://", with: "").components(separatedBy: "/")
                if let slugString = components.first,
                   let slug = Slug(rawValue: slugString) {
                    let sideString = components.count > 1 ? components[1] : nil
                    let bodySide = sideString != nil ? BodySide(rawValue: sideString!) : nil
                    
                    let bodyPart = ExtendedBodyPart(slug: slug)
                    parent.onBodyPartPress?(bodyPart, bodySide)
                }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
    
    private func generateSVGHTML() -> String {
        let bodyData = side == .front ? bodyFront : bodyBack
        let mergedParts = mergeBodyParts(bodyData: bodyData)
        let svgPaths = generateSVGPaths(bodyParts: mergedParts)
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                }
                svg {
                    max-width: 100%;
                    height: 100vh;
                }
                .body-part {
                    cursor: pointer;
                    transition: opacity 0.2s;
                }
                .body-part:hover {
                    opacity: 0.8;
                }
            </style>
        </head>
        <body>
            <svg viewBox="\(side == .front ? "0 0 724 1448" : "724 0 724 1448")" xmlns="http://www.w3.org/2000/svg">
                \(svgPaths)
            </svg>
        </body>
        </html>
        """
    }
    // View box is: 724 0 724 1448 for side / back.
    // View box is: 0 0 724 1448 for front
    
    private func mergeBodyParts(bodyData: [BodyPart]) -> [BodyPart] {
        return bodyData.map { bodyPart in
            // Find if this body part is selected
            if let selectedPart = selectedBodyParts.first(where: { $0.slug == bodyPart.slug }) {
                // Create new body part with selected color
                let colorToUse = getColorToFill(for: selectedPart, defaultColor: bodyPart.color)
                return BodyPart(slug: bodyPart.slug, color: colorToUse, path: bodyPart.path)
            } else {
                // Return original with default color
                return bodyPart
            }
        }
    }
    
    private func getColorToFill(for bodyPart: ExtendedBodyPart, defaultColor: String) -> String {
        if let intensity = bodyPart.intensity, intensity > 0 && intensity <= colors.count {
            return colors[intensity - 1]
        } else if let color = bodyPart.color {
            return color
        } else {
            return defaultColor
        }
    }
    
    private func generateSVGPaths(bodyParts: [BodyPart]) -> String {
        var svgContent = ""
        
        for bodyPart in bodyParts {
            let selectedPart = selectedBodyParts.first { $0.slug == bodyPart.slug }
            
            // Common paths
            if let commonPaths = bodyPart.path.common {
                for (index, path) in commonPaths.enumerated() {
                    let fillColor = selectedPart != nil ? bodyPart.color : bodyPart.color
                    svgContent += generatePathElement(
                        path: path,
                        id: "\(bodyPart.slug.rawValue)-common-\(index)",
                        fill: fillColor,
                        slug: bodyPart.slug.rawValue,
                        side: nil
                    )
                }
            }
            
            // Left paths
            if let leftPaths = bodyPart.path.left {
                for (index, path) in leftPaths.enumerated() {
                    let isOnlyRight = selectedPart?.side == .right
                    let fillColor = isOnlyRight ? "#3f3f3f" : bodyPart.color
                    svgContent += generatePathElement(
                        path: path,
                        id: "\(bodyPart.slug.rawValue)-left-\(index)",
                        fill: fillColor,
                        slug: bodyPart.slug.rawValue,
                        side: "left"
                    )
                }
            }
            
            // Right paths
            if let rightPaths = bodyPart.path.right {
                for (index, path) in rightPaths.enumerated() {
                    let isOnlyLeft = selectedPart?.side == .left
                    let fillColor = isOnlyLeft ? "#3f3f3f" : bodyPart.color
                    svgContent += generatePathElement(
                        path: path,
                        id: "\(bodyPart.slug.rawValue)-right-\(index)",
                        fill: fillColor,
                        slug: bodyPart.slug.rawValue,
                        side: "right"
                    )
                }
            }
        }
        
        return svgContent
    }
    
    private func generatePathElement(path: String, id: String, fill: String, slug: String, side: String?) -> String {
        let clickURL = side != nil ? "bodypart://\(slug)/\(side!)" : "bodypart://\(slug)"
        return """
            <path id="\(id)" 
                  d="\(path)" 
                  fill="\(fill)" 
                  class="body-part"
                  onclick="window.location.href='\(clickURL)'" />
        """
    }
}

#Preview {
    PlaceholderImageView(
        selectedBodyParts: [
            ExtendedBodyPart(slug: .chest, intensity: 1),
            ExtendedBodyPart(slug: .biceps, intensity: 2, side: .left)
        ]
    )
    .padding()
}
