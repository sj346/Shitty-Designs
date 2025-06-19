import Foundation
import Vision
import UIKit

class ContentModerator: ObservableObject {
    @Published var isAnalyzing = false
    @Published var moderationResult: ModerationResult?
    
    enum ModerationResult {
        case approved
        case rejected(String)
        case needsReview(String)
    }
    
    struct ContentCheck {
        let hasExplicitContent: Bool
        let hasViolence: Bool
        let hasNudity: Bool
        let confidence: Float
        let reason: String?
    }
    
    // Keywords that might indicate inappropriate content
    private let inappropriateKeywords = [
        "explicit", "adult", "nsfw", "porn", "sexual", "nude", "naked",
        "violence", "gore", "blood", "weapon", "drugs", "illegal"
    ]
    
    func moderateContent(image: UIImage, title: String, description: String?) async -> ModerationResult {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // 1. Check text content
        let textCheck = await checkTextContent(title: title, description: description)
        if textCheck.hasExplicitContent {
            return .rejected("Inappropriate text content detected: \(textCheck.reason ?? "Contains explicit language")")
        }
        
        // 2. Check image content using Vision framework
        let imageCheck = await analyzeImage(image: image)
        if imageCheck.hasExplicitContent || imageCheck.hasNudity {
            return .rejected("Inappropriate image content detected. Please ensure your design is appropriate for all audiences.")
        }
        
        if imageCheck.hasViolence {
            return .needsReview("Image may contain violent content and will be reviewed by our team.")
        }
        
        // 3. Additional checks
        if await containsInappropriatePatterns(image: image) {
            return .rejected("Image contains patterns that violate our community guidelines.")
        }
        
        return .approved
    }
    
    private func checkTextContent(title: String, description: String?) async -> ContentCheck {
        let fullText = "\(title) \(description ?? "")".lowercased()
        
        // Check for inappropriate keywords
        for keyword in inappropriateKeywords {
            if fullText.contains(keyword) {
                return ContentCheck(
                    hasExplicitContent: true,
                    hasViolence: false,
                    hasNudity: false,
                    confidence: 0.8,
                    reason: "Contains keyword: \(keyword)"
                )
            }
        }
        
        // Check for excessive profanity
        let profanityCount = countProfanity(in: fullText)
        if profanityCount > 2 {
            return ContentCheck(
                hasExplicitContent: true,
                hasViolence: false,
                hasNudity: false,
                confidence: 0.7,
                reason: "Contains excessive profanity"
            )
        }
        
        return ContentCheck(
            hasExplicitContent: false,
            hasViolence: false,
            hasNudity: false,
            confidence: 1.0,
            reason: nil
        )
    }
    
    private func analyzeImage(image: UIImage) async -> ContentCheck {
        guard let cgImage = image.cgImage else {
            return ContentCheck(
                hasExplicitContent: false,
                hasViolence: false,
                hasNudity: false,
                confidence: 0.0,
                reason: "Unable to analyze image"
            )
        }
        
        // Use Vision framework for image analysis
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            if let observations = request.results {
                return await processVisionResults(observations)
            }
        } catch {
            print("Vision analysis failed: \(error)")
        }
        
        // Fallback: basic image analysis
        return await basicImageAnalysis(image: image)
    }
    
    private func processVisionResults(_ observations: [VNClassificationObservation]) async -> ContentCheck {
        var hasExplicitContent = false
        var hasViolence = false
        var hasNudity = false
        var confidence: Float = 0.0
        
        for observation in observations {
            let label = observation.identifier.lowercased()
            let confidenceScore = observation.confidence
            
            // Check for explicit content indicators
            if label.contains("adult") || label.contains("explicit") || label.contains("nsfw") {
                hasExplicitContent = true
                confidence = max(confidence, confidenceScore)
            }
            
            // Check for violence indicators
            if label.contains("violence") || label.contains("weapon") || label.contains("blood") {
                hasViolence = true
                confidence = max(confidence, confidenceScore)
            }
            
            // Check for nudity indicators
            if label.contains("nude") || label.contains("naked") || label.contains("body") {
                hasNudity = true
                confidence = max(confidence, confidenceScore)
            }
        }
        
        return ContentCheck(
            hasExplicitContent: hasExplicitContent,
            hasViolence: hasViolence,
            hasNudity: hasNudity,
            confidence: confidence,
            reason: nil
        )
    }
    
    private func basicImageAnalysis(image: UIImage) async -> ContentCheck {
        // Basic color analysis for skin tone detection
        let skinTonePercentage = await detectSkinTones(in: image)
        
        if skinTonePercentage > 0.7 {
            return ContentCheck(
                hasExplicitContent: false,
                hasViolence: false,
                hasNudity: true,
                confidence: 0.6,
                reason: "High skin tone percentage detected"
            )
        }
        
        return ContentCheck(
            hasExplicitContent: false,
            hasViolence: false,
            hasNudity: false,
            confidence: 0.5,
            reason: nil
        )
    }
    
    private func detectSkinTones(in image: UIImage) async -> Float {
        // Simplified skin tone detection
        // In a real implementation, you'd use more sophisticated algorithms
        guard let cgImage = image.cgImage else { return 0.0 }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 0.0 }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return 0.0 }
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var skinTonePixels = 0
        let totalPixels = width * height
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = Float(buffer[pixelIndex])
                let g = Float(buffer[pixelIndex + 1])
                let b = Float(buffer[pixelIndex + 2])
                
                // Basic skin tone detection
                if isSkinTone(r: r, g: g, b: b) {
                    skinTonePixels += 1
                }
            }
        }
        
        return Float(skinTonePixels) / Float(totalPixels)
    }
    
    private func isSkinTone(r: Float, g: Float, b: Float) -> Bool {
        // Basic skin tone detection algorithm
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min
        
        // Check if it's in the skin tone range
        let isInRange = r > 95 && g > 40 && b > 20 && max - min > 15
        let isNotGray = delta > 15
        let rDominant = r > g && r > b
        let gReasonable = g > 40 && g < 200
        
        return isInRange && isNotGray && rDominant && gReasonable
    }
    
    private func countProfanity(in text: String) -> Int {
        let profanityWords = ["fuck", "shit", "bitch", "ass", "damn", "hell"]
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        return words.filter { word in
            profanityWords.contains { profanity in
                word.contains(profanity)
            }
        }.count
    }
    
    private func containsInappropriatePatterns(image: UIImage) async -> Bool {
        // Check for common patterns that might indicate inappropriate content
        // This is a simplified version - in production, you'd use more sophisticated detection
        
        // Check image dimensions (very small images might be thumbnails of inappropriate content)
        if image.size.width < 100 || image.size.height < 100 {
            return true
        }
        
        // Check aspect ratio (very wide or tall images might be screenshots)
        let aspectRatio = image.size.width / image.size.height
        if aspectRatio > 3.0 || aspectRatio < 0.33 {
            return true
        }
        
        return false
    }
} 