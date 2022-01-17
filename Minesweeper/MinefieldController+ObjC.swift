import AppKit

extension MinefieldController {
    @objc func relive(_: Any?) {
        if !minefield.stopAllAnimationsIfNeeded() {
            relive(redeploys: isAlive || sadMacBehavior == .redeploy)
        }
    }
    
    @objc func replay(_: Any?) {
        if !isBattling {
            return relive(redeploys: false)
        }
        
        showAlert(givingUpAlertWithoutNextDifficultyReminder) {response in
            if response == .alertFirstButtonReturn {
                self.relive(redeploys: false)
            }
        }
    }
    
    @objc func newGame(_: Any?) {
        if !isBattling {
            return relive(redeploys: true)
        }

        showAlert(givingUpAlert) {response in
            if response == .alertFirstButtonReturn {
                self.relive(redeploys: true)
            }
        }
    }
    
    @objc func newGameWithDifficulty(_ sender: NSMenuItem) {
        if !isBattling {
            return relive(redeploys: true, difficulty: Minefield.Difficulty(tag: sender.tag))
        }

        showAlert(givingUpAlert) {response in
            if response == .alertFirstButtonReturn {
                self.relive(redeploys: true, difficulty: Minefield.Difficulty(tag: sender.tag))
            }
        }
    }
    
    @objc func openPreferences(_: Any?) {
        minefield.stopAllAnimationsIfNeeded()
        
        // Pause game
        if isBattling && !isPaused {
            stopTimer()
        }
        
        let preferenceSheet = PreferenceSheet(difficulty: minefield.difficulty,
                                              mineStyle: mineStyle,
                                              sadMacBehavior: sadMacBehavior,
                                              useUncertain: minefield.useUncertain,
                                              quickMode: minefield.quickMode,
                                              autoPause: autoPause,
                                              isBattling: isBattling)
        
        minefield.window!.beginSheet(preferenceSheet) {_ in
            self.sadMacBehavior = preferenceSheet.sadMacBehavior
            self.autoPause = preferenceSheet.autoPause
            self.minefield.mineStyle = preferenceSheet.mineStyle
            self.minefield.useUncertain = preferenceSheet.useUncertain
            self.minefield.quickMode = preferenceSheet.quickMode
            self.setUserDefaults(for: [.sadMacBehavior, .mineStyle, .useUncertain, .quickMode, .autoPause])
            self.setSadType()
            
            // Resume game
            if self.isBattling && self.isPaused {
                self.startTimer()
            }
            
            if self.isBattling {
                if preferenceSheet.difficulty != self.minefield.difficulty {
                    if preferenceSheet.givesUpToApplyDifficulty {
                        self.relive(redeploys: true, difficulty: preferenceSheet.difficulty)
                    } else {
                        self.nextDifficulty = preferenceSheet.difficulty
                    }
                }
            } else {
                self.relive(redeploys: self.sadMacBehavior != .replay, difficulty: preferenceSheet.difficulty)
            }
        }
    }
    
    @objc func pauseGame(_: Any?) {
        pauseGame(autmatic: false)
    }
}
