/*
Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg

Current Maintainer (since 2016):
Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

import Foundation

func OK_BUTTON() -> String {
    return NSLocalizedString("OK", comment: "OK-button")
}

func CANCEL_BUTTON() -> String {
    return NSLocalizedString("Cancel", comment: "Cancel-button")
}

func DELETE_BUTTON() -> String {
    return NSLocalizedString("Delete", comment: "Delete-button")
}

func UNTITLED_PROJECT_NAME() -> String {
    return NSLocalizedString("Untitled project", comment: "Untitled project")
}



func FRADefaults() -> Any {
    return NSUserDefaultsController.shared.values
}

func FRACurrentProject() -> FRAProject? {
    return FRAProjectsController.shared.currentDocument as? FRAProject
}

func FRACurrentDocument() -> Any? {
    return (FRAProjectsController.shared as! FRAProjectsController).currentFRADocument
}

func FRACurrentTextView() -> FRATextView? {
    return (FRAProjectsController.shared as! FRAProjectsController).currentTextView()
}

func FRACurrentText() -> String? {
    return (FRAProjectsController.shared as! FRAProjectsController).currentText()
}

func FRACurrentWindow() -> NSWindow? {
    return FRACurrentProject()?.windowControllers[0].window
}

// bridge define existing in Objective-C
func NSLocalizedStringFromTable(_ key: String, _ tbl: String, _ comment: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: tbl)
}
