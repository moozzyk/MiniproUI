//
//  OperationResult.swift
//  Visual Minipro
//

enum OperationResult: Hashable, Identifiable {
    case success
    case failure(String)

    var id: Self { self }
}
