//
//  AnalyticsViewModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 07/11/23.
//

import Foundation

class AnalyticsViewModel: ObservableObject {
    @Published var data: [ToyShape] = [
        .init(type: "Cube", count: 5),
        .init(type: "Sphere", count: 4),
        .init(type: "Pyramid", count: 4)
    ]
}
