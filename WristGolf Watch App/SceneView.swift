//
//  SceneView.swift
//  WristGolf Watch App
//
//  Created by Giuseppe Francione on 18/06/24.
//

import SwiftUI
import SpriteKit

struct SceneView: View {
    var body: some View {
        SpriteView(scene: GameScene())
            .ignoresSafeArea()
    }
}

#Preview {
    SceneView()
}
