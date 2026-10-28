//
//  File.swift
//  BackGlass
//
//  Created by Tim on 31.05.26.
//

import SwiftUI

#if os(iOS) 
internal struct _ShowcaseView: View {
    @State var log: [String] = []
    @State var backgroundStyle: Wallpaper = .colorful

    var body: some View {
        NavigationView {
            ZStack {
                backgroundStyle
                VStack {
                    VStack {
                        Button("Bordered Button") {
                            withAnimation {
                                log.append("[tap] Bordered Button")
                            }
                        }
                        .buttonStyle(.glassBackport)
                        Button("Bordered Prominent Button") {
                            withAnimation {
                                log.append("[tap] Bordered Prominent Button")
                            }
                        }
                        .buttonStyle(.glassProminentBackport)
                        NavigationLink {
                            glassBlobView
                        } label: {
                            HStack {
                                Text("glassEffect")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(.glassBackport)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        HStack {
                            Text("Log")
                            Spacer()
                            Button("Clear") {
                                withAnimation {
                                    log.removeAll()
                                }
                            }
                            .buttonStyle(.glassProminentBackport)
                            .tint(.red)
                            .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
Divider()
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack {
                                    if log.isEmpty {
                                        Text("No Log Messages yet")
                                            .foregroundStyle(.secondary)
                                    }
                                    ForEach(log, id: \.self) { item in
                                        Text(item)
                                        Divider()
                                    }
                                    Spacer()
                                        .frame(height: 5)
                                        .id("Bottom")
                                }
                                .padding(15)
                            }
                            .onChange(of: log) { _ in
                                withAnimation {
                                    proxy.scrollTo("Bottom")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .backportGlassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 25))
                    .padding()
                }
            }
            .navigationTitle("Showcase")

        }
        .navigationViewStyle(.stack)
    }
    @State var interactive = false
    @State var tint = false
    @State var tintColor: Color = .accentColor
    @State var glassItems: [GlassItem] = [.init(interactive: false, enableTint: false, tintColor: .accentColor)]
    
    var glassBlobView: some View {
        VStack {
            Spacer()
            ZStack {
                ForEach($glassItems) { item in
                    Text("Hello")
                        .foregroundStyle(item.wrappedValue.enableTint ? item.wrappedValue.tintColor.bestForegroundColor : .primary)
                        .padding()
                        .backportGlassEffect(.regular.interactive(item.wrappedValue.interactive).tint(item.wrappedValue.enableTint ? item.wrappedValue.tintColor : nil))
                        .contentShape(.capsule)
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    if item.wrappedValue.movable {
                                        let last = item.wrappedValue.lastOffset
                                        item.offset.wrappedValue = CGSize(width: last.width + value.translation.width, height: last.height + value.translation.height)
                                    }
                                }
                                .onEnded { _ in
                                    if item.wrappedValue.movable {
                                        item.wrappedValue.lastOffset = item.wrappedValue.offset
                                    }
                                }
                        )
                        .offset(item.wrappedValue.offset)
                }
            }
            Spacer()
            TabView {
                ForEach($glassItems) { item in
                    Form {
                        Section {
                            Toggle("Interactive", isOn: item.interactive.animation())
                            Toggle("Draggable", isOn: item.movable)
                        } header: {
                            HStack {
                                if let index = glassItems.firstIndex(of: item.wrappedValue) {
                                    Text("Item \(index + 1)")
                                } else {
                                    Text("Item")
                                }
                                Spacer()
                                if glassItems.count > 1 {
                                    Button("Delete") {
                                        glassItems.removeAll(where: { $0.id == item.wrappedValue.id })
                                    }
                                }
                            }
                        } footer: {
                            if item.wrappedValue.offset != .zero {
                                HStack {
                                    if #available(iOS 16, *) {
                                        Text("\(item.wrappedValue.offset.width), \(item.wrappedValue.offset.height)")
                                            .contentTransition(.numericText(countsDown: false))
                                            .animation(.default, value: item.wrappedValue.offset)
                                    } else {
                                        Text("\(item.wrappedValue.offset.width), \(item.wrappedValue.offset.height)")
                                    }
                                    Spacer()
                                    Button("Reset Position") {
                                        item.wrappedValue.offset = .zero
                                        item.wrappedValue.lastOffset = .zero
                                    }
                                }
                            }
                        }

                        Section("Tint") {
                            Toggle("Enable", isOn: item.enableTint.animation())
                            ColorPicker("Color", selection: item.tintColor.animation())
                                .disabled(!item.enableTint.wrappedValue)
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 300)
            .padding(.bottom, -35)
        }
        .background {
            backgroundStyle
        }
        .toolbar {
            Button("New Item", systemImage: "plus") {
                withAnimation {
                    glassItems.append(GlassItem(interactive: false, enableTint: false, tintColor: .accentColor))
                }
            }
        }
        .navigationTitle("Glass")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct GlassItem: Identifiable, Hashable {
        let id = UUID()
        var interactive: Bool
        var enableTint: Bool
        var tintColor: Color
        var offset: CGSize = .zero
        var lastOffset: CGSize = .zero
        var movable: Bool = false
    }
    
    enum Wallpaper: View {
        case plain
        case colorful
        case color(_ color: Color)
        
        var body: some View {
            switch self {
            case .plain:
                Color.clear
            case .colorful:
                LinearGradient(colors: [.red, .green, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
            case .color(let color):
                color
            }
        }
    }
}

#Preview {
    _ShowcaseView()
}
#elseif os(macOS)
internal struct _ShowcaseView: View {
    @State var log: [String] = []
    @State var backgroundStyle: Wallpaper = .colorful
    @State var showGlassEffectView = false
    
    var body: some View {
        if showGlassEffectView {
            glassBlobView
        } else {
            ZStack {
                backgroundStyle
                VStack {
                    VStack {
                        Button("Bordered Button") {
                            withAnimation {
                                log.append("[tap] Bordered Button")
                            }
                        }
                        .buttonStyle(.glassBackport)
                        Button("Bordered Prominent Button") {
                            withAnimation {
                                log.append("[tap] Bordered Prominent Button")
                            }
                        }
                        .buttonStyle(.glassProminentBackport)
                        Button {
                            showGlassEffectView = true
                            let w = NSWindow(contentViewController: NSHostingController(rootView: Text("Hi")))
                            w.styleMask = [.closable, .titled]
                            w.makeKeyAndOrderFront(nil)
                        } label: {
                            HStack {
                                Text("glassEffect")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(.glassBackport)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack {
                        HStack {
                            Text("Log")
                            Spacer()
                            Button("Clear") {
                                withAnimation {
                                    log.removeAll()
                                }
                            }
                            .buttonStyle(.glassProminentBackport)
                            .tint(.red)
                            .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        Divider()
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack {
                                    if log.isEmpty {
                                        Text("No Log Messages yet")
                                            .foregroundStyle(.secondary)
                                    }
                                    ForEach(log, id: \.self) { item in
                                        Text(item)
                                        Divider()
                                    }
                                    Spacer()
                                        .frame(height: 5)
                                        .id("Bottom")
                                }
                                .padding(15)
                            }
                            .onChange(of: log) { _ in
                                withAnimation {
                                    proxy.scrollTo("Bottom")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .backportGlassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 25))
                    .padding()
                }
            }
        }
    }
    @State var interactive = false
    @State var tint = false
    @State var tintColor: Color = .accentColor
    @State var glassItems: [GlassItem] = [.init(interactive: false, enableTint: false, tintColor: .accentColor)]
    
    var glassBlobView: some View {
        VStack {
            Spacer()
            ZStack {
                ForEach($glassItems) { item in
                    Text("Hello")
                        .foregroundStyle(item.wrappedValue.enableTint ? item.wrappedValue.tintColor.bestForegroundColor : .primary)
                        .padding()
                        .backportGlassEffect(.regular.interactive(item.wrappedValue.interactive).tint(item.wrappedValue.enableTint ? item.wrappedValue.tintColor : nil))
                        .contentShape(.capsule)
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    if item.wrappedValue.movable {
                                        let last = item.wrappedValue.lastOffset
                                        item.offset.wrappedValue = CGSize(width: last.width + value.translation.width, height: last.height + value.translation.height)
                                    }
                                }
                                .onEnded { _ in
                                    if item.wrappedValue.movable {
                                        item.wrappedValue.lastOffset = item.wrappedValue.offset
                                    }
                                }
                        )
                        .offset(item.wrappedValue.offset)
                }
            }
            Spacer()
            TabView {
                ForEach($glassItems) { item in
                    Form {
                        Section {
                            Toggle("Interactive", isOn: item.interactive.animation())
                            Toggle("Draggable", isOn: item.movable)
                        } header: {
                            HStack {
                                if let index = glassItems.firstIndex(of: item.wrappedValue) {
                                    Text("Item \(index + 1)")
                                } else {
                                    Text("Item")
                                }
                                Spacer()
                                if glassItems.count > 1 {
                                    Button("Delete") {
                                        glassItems.removeAll(where: { $0.id == item.wrappedValue.id })
                                    }
                                }
                            }
                        } footer: {
                            if item.wrappedValue.offset != .zero {
                                HStack {
                                    if #available(macOS 13, *) {
                                        Text("\(item.wrappedValue.offset.width), \(item.wrappedValue.offset.height)")
                                            .contentTransition(.numericText(countsDown: false))
                                            .animation(.default, value: item.wrappedValue.offset)
                                    } else {
                                        Text("\(item.wrappedValue.offset.width), \(item.wrappedValue.offset.height)")
                                    }
                                    Spacer()
                                    Button("Reset Position") {
                                        item.wrappedValue.offset = .zero
                                        item.wrappedValue.lastOffset = .zero
                                    }
                                }
                            }
                        }

                        Section("Tint") {
                            Toggle("Enable", isOn: item.enableTint.animation())
                            ColorPicker("Color", selection: item.tintColor.animation())
                                .disabled(!item.enableTint.wrappedValue)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .padding(.bottom, -85)
                    .tabItem {
                        if let index = glassItems.firstIndex(of: item.wrappedValue) {
                            Text("Item \(index + 1)")
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding(.bottom, -35)
        }
        .background {
            backgroundStyle
        }
        .toolbar {
            Button("New Item", systemImage: "plus") {
                withAnimation {
                    glassItems.append(GlassItem(interactive: false, enableTint: false, tintColor: .accentColor))
                }
            }
        }
        .navigationTitle("Glass")
    }
    
    struct GlassItem: Identifiable, Hashable {
        let id = UUID()
        var interactive: Bool
        var enableTint: Bool
        var tintColor: Color
        var offset: CGSize = .zero
        var lastOffset: CGSize = .zero
        var movable: Bool = false
    }
    
    enum Wallpaper: View {
        case plain
        case colorful
        case color(_ color: Color)
        
        var body: some View {
            switch self {
            case .plain:
                Color.clear
            case .colorful:
                LinearGradient(colors: [.red, .green, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
            case .color(let color):
                color
            }
        }
    }
}

#Preview {
    _ShowcaseView()
}
#endif

#if os(iOS) || os(tvOS)
typealias PlatformColor = UIColor
#elseif os(macOS)
typealias PlatformColor = NSColor
#endif
extension Color {
    var bestForegroundColor: Color {
        let color = PlatformColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness > 0.5 ? .black : .white
    }
}
