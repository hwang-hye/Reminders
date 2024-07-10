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
}

class PriorityViewModel {
    var inputPriorityTag: Observable<Priority> = Observable(.medium)
    var outputPriorityTag:Observable<String> = Observable("")

    init() {
        print("ViewModel Init")
        inputPriorityTag.bind { [weak self] _ in
            self?.validation()
        }
    }
    
    private func validation() {

        let priority = inputPriorityTag.value
        
        // inputPriorityTag의 값을 기반으로 outputPriorityTag 업데이트
        outputPriorityTag.value = priority.description
        
        // 여기에서 추가 로직 처리
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

