//
//  TagViewModel.swift
//  Reminders
//
//  Created by hwanghye on 7/15/24.
//

import Foundation

class TagViewModel {
    var tag: Observable<String> = Observable("")
    var isTagSelected: Observable<Bool> = Observable(false)
    
    var error: Observable<String?> = Observable(nil)
    
    func updateTag(_ newTag: String) {
        tag.value = newTag
    }
    
    func selectTag() {
        if !tag.value.isEmpty {
            isTagSelected.value = true
        } else {
            isTagSelected.value = true
            error.value = nil
        }
    }
}
