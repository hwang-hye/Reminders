//
//  PriorityViewModel.swift
//  Reminders
//
//  Created by hwanghye on 7/9/24.
//

import Foundation

enum Priority: Int {
    case high = 0
    case medium = 1
    case low = 2
    
    var description: String {
        switch self {
        case .high: return "높음"
        case .medium: return "보통"
        case .low: return "낮음"
        }
    }
    
    static func fromString(_ string: String) -> Priority {
        switch string {
        case "높음": return .high
        case "낮음": return .low
        default: return .medium
        }
    }
}

class PriorityViewModel {
    var inputPriorityTag: Observable<Priority> = Observable(.medium)
    var outputPriorityTag: Observable<String> = Observable("")
    
    init() {
        print("ViewModel Init")
        inputPriorityTag.bind { [weak self] _ in
            self?.validation()
        }
    }
    
    private func validation() {
        let priority = inputPriorityTag.value
        outputPriorityTag.value = priority.description
        
        switch priority {
        case .high:
            print("높은 우선순위 작업")
        case .medium:
            print("보통 우선순위 작업")
        case .low:
            print("낮은 우선순위 작업")
        }
    }
}
