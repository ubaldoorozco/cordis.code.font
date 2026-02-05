//
//  GuidedMeditationListView.swift
//  cordis
//

import SwiftUI

struct GuidedMeditationListView: View {
    @State private var cloudKit = CloudKitService()
    @State private var showBreathing = false

    var body: some View {
        ZStack {
            AnimatedGlassBackground(colorScheme: .calm)

            ScrollView {
                VStack(spacing: 20) {
                    breathingSection
                    guidedSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Meditación")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await cloudKit.fetchMeditations()
        }
        .fullScreenCover(isPresented: $showBreathing) {
            MeditationView()
        }
    }

    private var breathingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ejercicio de Respiración")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            Button {
                showBreathing = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "wind")
                        .font(.title2)
                        .foregroundColor(.purple)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Respiración 4-7-8")
                            .font(.body.bold())
                            .foregroundColor(.white)
                        Text("Inhala, mantén y exhala — 4 minutos")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }

    private var guidedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meditaciones Guiadas")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            if cloudKit.isLoading && cloudKit.meditations.isEmpty {
                loadingView
            } else if cloudKit.meditations.isEmpty {
                emptyView
            } else {
                meditationList
            }

            if cloudKit.errorMessage != nil, !cloudKit.meditations.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Mostrando versión guardada")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 4)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            Text("Cargando meditaciones...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.slash")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))

            if cloudKit.errorMessage != nil {
                Text("No se pudieron cargar las meditaciones")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                Button {
                    Task { await cloudKit.fetchMeditations() }
                } label: {
                    Label("Reintentar", systemImage: "arrow.clockwise")
                        .font(.subheadline.bold())
                        .foregroundColor(.purple)
                }
            } else {
                Text("No hay meditaciones disponibles")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var meditationList: some View {
        VStack(spacing: 12) {
            ForEach(cloudKit.meditations) { item in
                NavigationLink {
                    GuidedMeditationPlayerView(item: item, cloudKit: cloudKit)
                } label: {
                    meditationRow(item)
                }
            }
        }
    }

    private func meditationRow(_ item: GuidedMeditationItem) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "headphones")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(formatDuration(item.duration))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))

                    if !item.description.isEmpty {
                        Text("·")
                            .foregroundColor(.white.opacity(0.4))
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            if item.localAudioURL != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green.opacity(0.7))
            } else {
                Image(systemName: "icloud.and.arrow.down")
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(mins) min"
        }
        return "\(mins):\(String(format: "%02d", secs))"
    }
}
