//
//  PlaceholderImageView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI
import WebKit

/// A SwiftUI view that displays an interactive body diagram with selectable body parts
struct PlaceholderImageView: View {
    // MARK: - Constants
    private static let defaultColors = ["#0984e3", "#74b9ff"]
    private static let defaultBorder = "#dfdfdf"
    private static let defaultHeight: CGFloat = 400
    private static let defaultCornerRadius: CGFloat = 12
    
    // MARK: - Properties
    let selectedBodyParts: [ExtendedBodyPart]
    let colors: [String]
    let border: String
    let onBodyPartPress: ((ExtendedBodyPart, BodySide?) -> Void)?
    
    // MARK: - Initialization
    init(
        selectedBodyParts: [ExtendedBodyPart] = [],
        colors: [String] = PlaceholderImageView.defaultColors,
        border: String = PlaceholderImageView.defaultBorder,
        onBodyPartPress: ((ExtendedBodyPart, BodySide?) -> Void)? = nil
    ) {
        self.selectedBodyParts = selectedBodyParts
        self.colors = colors
        self.border = border
        self.onBodyPartPress = onBodyPartPress
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            BodyWebView(
                selectedBodyParts: selectedBodyParts,
                colors: colors,
                side: .front,
                border: border,
                onBodyPartPress: onBodyPartPress
            )
            .frame(height: Self.defaultHeight)
            .cornerRadius(Self.defaultCornerRadius)
            
            BodyWebView(
                selectedBodyParts: selectedBodyParts,
                colors: colors,
                side: .back,
                border: border,
                onBodyPartPress: onBodyPartPress
            )
            .frame(height: Self.defaultHeight)
            .cornerRadius(Self.defaultCornerRadius)
        }
    }
}

/// A UIViewRepresentable that wraps a WKWebView to display interactive SVG body diagrams
struct BodyWebView: UIViewRepresentable {
    // MARK: - Constants
    private static let frontViewBox = "0 0 724 1448"
    private static let backViewBox = "724 0 724 1448"
    private static let bodyPartScheme = "bodypart"
    private static let bodyPartPrefix = "bodypart://"
    private static let unselectedColor = "#3f3f3f"
    private static let strokeWidth = "2"
    
    // MARK: - Properties
    let selectedBodyParts: [ExtendedBodyPart]
    let colors: [String]
    let side: ViewSide
    let border: String
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
            guard let url = navigationAction.request.url,
                  url.scheme == BodyWebView.bodyPartScheme else {
                decisionHandler(.allow)
                return
            }
            
            handleBodyPartSelection(from: url)
            decisionHandler(.cancel)
        }
        
        private func handleBodyPartSelection(from url: URL) {
            let urlString = url.absoluteString.replacingOccurrences(of: BodyWebView.bodyPartPrefix, with: "")
            let components = urlString.components(separatedBy: "/")
            
            guard let slugString = components.first,
                  let slug = Slug(rawValue: slugString) else {
                return
            }
            
            let bodySide: BodySide?
            if components.count > 1 {
                bodySide = BodySide(rawValue: components[1])
            } else {
                bodySide = nil
            }
            
            let bodyPart = ExtendedBodyPart(slug: slug)
            parent.onBodyPartPress?(bodyPart, bodySide)
        }
    }
    
    private func generateSVGHTML() -> String {
        let bodyData = side == .front ? bodyFront : bodyBack
        let mergedParts = mergeBodyParts(bodyData: bodyData)
        let svgPaths = generateSVGPaths(bodyParts: mergedParts)
        let viewBox = side == .front ? Self.frontViewBox : Self.backViewBox
        
        return buildHTMLString(viewBox: viewBox, svgPaths: svgPaths)
    }
    
    private func buildHTMLString(viewBox: String, svgPaths: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                \(generateCSS())
            </style>
        </head>
        <body>
            <svg viewBox="\(viewBox)" xmlns="http://www.w3.org/2000/svg">
                \(generateOutlinePath())
                \(svgPaths)
            </svg>
        </body>
        </html>
        """
    }
    
    private func generateCSS() -> String {
        return """
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
        """
    }
    // MARK: - Private Methods
    
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
                    svgContent += generatePathElement(
                        path: path,
                        id: "\(bodyPart.slug.rawValue)-common-\(index)",
                        fill: bodyPart.color,
                        slug: bodyPart.slug.rawValue,
                        side: nil
                    )
                }
            }
            
            // Left paths
            if let leftPaths = bodyPart.path.left {
                svgContent += generateSidePaths(
                    paths: leftPaths,
                    bodyPart: bodyPart,
                    selectedPart: selectedPart,
                    pathSide: .left,
                    idSuffix: "left"
                )
            }
            
            // Right paths
            if let rightPaths = bodyPart.path.right {
                svgContent += generateSidePaths(
                    paths: rightPaths,
                    bodyPart: bodyPart,
                    selectedPart: selectedPart,
                    pathSide: .right,
                    idSuffix: "right"
                )
            }
        }
        
        return svgContent
    }
    
    private func generateSidePaths(
        paths: [String],
        bodyPart: BodyPart,
        selectedPart: ExtendedBodyPart?,
        pathSide: BodySide,
        idSuffix: String
    ) -> String {
        var content = ""
        
        for (index, path) in paths.enumerated() {
            let shouldDimPath = selectedPart?.side != nil && selectedPart?.side != pathSide
            let fillColor = shouldDimPath ? Self.unselectedColor : bodyPart.color
            
            content += generatePathElement(
                path: path,
                id: "\(bodyPart.slug.rawValue)-\(idSuffix)-\(index)",
                fill: fillColor,
                slug: bodyPart.slug.rawValue,
                side: idSuffix
            )
        }
        
        return content
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
    
    private func generateOutlinePath() -> String {
        guard border != "none" else { return "" }
        
        let pathToUse = side == .front ? bodyFrontOutlineString : bodyBackOutlineString
        
        return """
            <g stroke-width="\(Self.strokeWidth)" fill="none" stroke-linecap="butt">
                <path stroke="\(border)" vector-effect="non-scaling-stroke" d="\(pathToUse)" />
            </g>
        """
    }
}

#Preview {
    PlaceholderImageView(
        selectedBodyParts: [
            ExtendedBodyPart(slug: .chest, intensity: 1),
            ExtendedBodyPart(slug: .biceps, intensity: 2, side: .left)
        ],
        border: "#dfdfdf"
    )
    .padding()
}
