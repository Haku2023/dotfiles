; extends

; Make function calls win vs variable highlight
; Subroutine calls
(subroutine_call
  subroutine: (identifier) @function.call
  (#set! priority 110))
; Remove character from @function.builtin and add to @type.builtin
"character" @type.builtin




