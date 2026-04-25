import SwiftUI
import AVKit

struct VideoLoopView: UIViewRepresentable {
    
    let videoName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView()
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ Video no encontrado: \(videoName)")
            return view
        }
        
        let player = AVPlayer(url: url)
        player.isMuted = true   // 🔇 audio mute
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill   // 🔥 cover real
        
        view.playerLayer = playerLayer
        view.layer.addSublayer(playerLayer)
        
        // 🔁 loop infinito
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        player.play()
        
        context.coordinator.player = player
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nada necesario aquí
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: AVPlayer?
    }
}


// 🔥 ESTA CLASE ES LA CLAVE (layout correcto)
class PlayerUIView: UIView {
    
    var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 🔥 ESQUINAS REDONDEADAS
        layer.cornerRadius = 20
        layer.masksToBounds = true   // MUY IMPORTANTE
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
