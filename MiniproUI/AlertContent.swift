//
//  AlertContent.swift
//  Visual Minipro
//

struct AlertContent: Hashable, Identifiable {
    let title: String
    let message: String

    var id: Self { self }
}
