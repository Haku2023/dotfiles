;; extends

(function) @function.outer
((function
  (function_statement) @_header
  (end_function_statement) @_footer) @function.inner
 (#fortran-body! @function.inner @_header @_footer))

(subroutine) @function.outer
; (subroutine_statement) @function.inner
; 
((subroutine
  (subroutine_statement) @_header
  (end_subroutine_statement) @_footer) @function.inner
 (#fortran-body! @function.inner @_header @_footer))

(module_procedure_statement) @function.outer
(module_procedure_statement) @function.inner

((if_statement
  "then" @_header
  (end_if_statement) @_footer) @conditional.inner
 (#fortran-body! @conditional.inner @_header @_footer))
(if_statement) @conditional.outer

((do_loop
  (do_statement) @_header
  (end_do_loop_statement) @_footer) @loop.inner
 (#fortran-body! @loop.inner @_header @_footer))
(do_loop) @loop.outer
