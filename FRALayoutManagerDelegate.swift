/*
 Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg
 
 Current Maintainer (since 2016):
 Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

private var _sharedInstance: FRALayoutManagerDelegate? = nil;

class FRALayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {

    @objc class func sharedInstance() -> FRALayoutManagerDelegate {
        if (_sharedInstance == nil) {
            return FRALayoutManagerDelegate();
        }
        
        return _sharedInstance!;
    }

    override init() {
        super.init()
        _sharedInstance = self;
    }


    /// adjust line height to be all the same
    func layoutManager(_ layoutManager: NSLayoutManager, shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<NSRect>, lineFragmentUsedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>, in textContainer: NSTextContainer, forGlyphRange glyphRange: NSRange) -> Bool {
        
        let font = textContainer.textView!.font!
        let lineHeight = layoutManager.defaultLineHeight(for: font);
        lineFragmentRect.pointee.size.height = lineHeight;
        lineFragmentUsedRect.pointee.size.height = lineHeight;
        
        // use always same baseline offset
        baselineOffset.pointee = layoutManager.defaultBaselineOffset(for: font);
        
        return true
    }

}
