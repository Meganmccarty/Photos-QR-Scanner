import SwiftUI
import Photos

struct ThumbnailView: View {
    let asset: PHAsset
    let isSelected: Bool
    let size: Double
    let onTap: () -> Void
    let qrCodeResult: String?
    
    @State private var thumbnail: NSImage?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: size, height: size)
            
            if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipped()
            } else {
                ProgressView()
                    .controlSize(.small)
            }
            
            if isSelected {
                Rectangle()
                    .fill(selectionColor.opacity(0.3))
                    .frame(width: size, height: size)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: selectionIcon)
                            .foregroundColor(.white)
                            .background(selectionColor)
                            .clipShape(Circle())
                            .padding(4)
                    }
                    Spacer()
                }
                if let qr = qrCodeResult, qr.isEmpty {
                    Text("No QR Code")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(4)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? selectionColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .onTapGesture {
            onTap()
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private var selectionColor: Color {
        if let qr = qrCodeResult, qr.isEmpty {
            return .red
        }
        return .blue
    }

    private var selectionIcon: String {
        if let qr = qrCodeResult, qr.isEmpty {
            return "xmark.circle.fill"
        }
        return "checkmark.circle.fill"
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = false
        
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let targetSize = CGSize(width: size * scale, height: size * scale)
        
        manager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                thumbnail = image
            }
        }
    }
}