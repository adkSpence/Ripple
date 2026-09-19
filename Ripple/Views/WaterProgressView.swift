import SwiftUI

struct WaterProgressView: View {
    let progress: Double
    let amountML: Int
    let goalML: Int
    let animationTrigger: UUID?

    @State private var displayedProgress = 0.0
    @State private var dropletOffset: CGFloat = -130
    @State private var dropletOpacity = 0.0
    @State private var rippleScale = 0.2
    @State private var rippleOpacity = 0.0

    var body: some View {
        ZStack {
            Capsule().fill(.blue.opacity(0.08))

            TimelineView(.animation) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate * 1.4
                ZStack {
                    WaveShape(progress: displayedProgress, phase: phase, amplitude: 8)
                        .fill(LinearGradient(
                            colors: [.cyan.opacity(0.75), .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    WaveShape(progress: displayedProgress, phase: phase + .pi, amplitude: 5)
                        .fill(.cyan.opacity(0.25))
                }
            }
            .clipShape(Capsule())

            Circle()
                .stroke(.white.opacity(rippleOpacity), lineWidth: 3)
                .frame(width: 65, height: 24)
                .scaleEffect(rippleScale)
                .offset(y: 10)

            Image(systemName: "drop.fill")
                .font(.system(size: 28))
                .foregroundStyle(.cyan)
                .opacity(dropletOpacity)
                .offset(y: dropletOffset)

            VStack(spacing: 3) {
                Text("\(amountML.formatted()) ml")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text("of \(goalML.formatted()) ml")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .frame(width: 210, height: 270)
        .overlay { Capsule().stroke(.blue.opacity(0.18), lineWidth: 2) }
        .onAppear {
            withAnimation(.easeOut(duration: 1.1)) { displayedProgress = progress }
        }
        .onChange(of: progress) { _, value in
            withAnimation(.spring(duration: 1.2, bounce: 0.16)) { displayedProgress = value }
        }
        .onChange(of: animationTrigger) { _, _ in playDropAnimation() }
    }

    private func playDropAnimation() {
        dropletOffset = -130
        dropletOpacity = 1
        rippleScale = 0.2
        rippleOpacity = 0
        withAnimation(.easeIn(duration: 0.55)) { dropletOffset = 8 }
        withAnimation(.easeOut(duration: 0.18).delay(0.48)) { dropletOpacity = 0 }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            rippleScale = 2.2
            rippleOpacity = 0.9
        } completion: {
            withAnimation(.easeOut(duration: 0.25)) { rippleOpacity = 0 }
        }
    }
}

private struct WaveShape: Shape {
    var progress: Double
    var phase: Double
    var amplitude: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterLine = rect.maxY - rect.height * min(max(progress, 0), 1)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: waterLine))
        stride(from: rect.minX, through: rect.maxX, by: 2).forEach { x in
            let relativeX = (x - rect.minX) / rect.width
            let y = waterLine + sin(relativeX * .pi * 2.2 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
