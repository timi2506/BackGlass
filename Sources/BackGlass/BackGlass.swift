// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public extension View {
    func backportGlassEffect<S: Shape>(_ glass: CustomGlass = .regular, in shape: S = Capsule()) -> some View {
        if #available(iOS 26, macOS 26, tvOS 26, *) {
            return self.glassEffect(glass.glass(), in: shape)
        } else {
            return self.background {
                shape
                    .foregroundStyle(glass.shapeStyle())
            }
        }
    }
}

public struct CustomGlass {
    public static let regular = CustomGlass(type: .regular, interactive: false)
    public static let clear = CustomGlass(type: .clear, interactive: false)
    
    private let type: GlassType
    private var interactive: Bool
    private var tint: Color?
    
    public func interactive(_ value: Bool = true) -> CustomGlass {
        var copy = self
        copy.interactive = value
        return copy
    }
    public func tint(_ color: Color?) -> CustomGlass {
        var copy = self
        copy.tint = color
        return copy
    }
    
    fileprivate func shapeStyle() -> AnyShapeStyle {
        if let tint {
            return AnyShapeStyle(tint)
        }
        switch self.type {
        case .regular:
            return AnyShapeStyle(.regularMaterial)
        case .clear:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }
    
    @available(iOS 26, macOS 26, tvOS 26, *)
    fileprivate func glass() -> Glass {
        switch self.type {
        case .regular:
            return .regular.interactive(interactive).tint(tint)
        case .clear:
            return .clear.interactive(interactive).tint(tint)
        }
    }
    
    public enum GlassType {
        case regular
        case clear
    }
}

public extension View {
    @ViewBuilder func buttonStyle(_ customStyle: CustomStyle) -> some View {
        switch customStyle {
        case .glassBackport:
            if #available(iOS 26, macOS 26, tvOS 26, *) {
                self.buttonStyle(.glass)
            } else {
                self.buttonStyle(.bordered)
            }
        case .glassProminentBackport:
            if #available(iOS 26, macOS 26, tvOS 26, *) {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.borderedProminent)
            }
        }
    }
}

public enum CustomStyle {
    case glassBackport
    case glassProminentBackport
}
