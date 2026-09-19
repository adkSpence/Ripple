import SwiftUI

struct BottleOnboardingView: View {
    @Bindable var viewModel: BottleRegistrationViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.cyan.opacity(0.18), .blue.opacity(0.08), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 34)
                    hero
                    registrationOptions
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Text("Your bottle details stay on this iPhone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }.padding(24)
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isShowingForm },
            set: { if !$0 { viewModel.dismissForm() } }
        )) {
            BottleRegistrationForm(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var hero: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 116, height: 116)
                    .shadow(color: .blue.opacity(0.25), radius: 24, y: 12)
                Image(systemName: "drop.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white)
                Image(systemName: "wave.3.right")
                    .font(.title2.bold())
                    .foregroundStyle(.cyan)
                    .offset(x: 45, y: 35)
            }
            VStack(spacing: 8) {
                Text("Your water, one tap away")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("Connect a bottle tag and every scan becomes a drink logged.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var registrationOptions: some View {
        VStack(spacing: 14) {
            Button { viewModel.startNFCRegistration() } label: {
                HStack(spacing: 16) {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill").font(.title2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.isDetecting ? "Looking for your tag…" : "Register with NFC")
                            .font(.headline)
                        Text("Scan a writable tag, then add bottle details")
                            .font(.caption)
                            .opacity(0.8)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(18)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isDetecting)

            Button { viewModel.startManualRegistration() } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add a bottle manually")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(14)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isDetecting)
        }
    }
}
