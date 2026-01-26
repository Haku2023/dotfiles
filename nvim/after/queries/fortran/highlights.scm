;; extends

; Match the subroutine field in subroutine_call
(subroutine_call
  subroutine: (identifier) @function.call
  (#set! priority 150))

[
  "allocate"
  "case"
  "only"
  ; "deallocate"
] @keyword

(call_expression
  (identifier) @keyword.builtin
  (#any-of? @keyword.builtin
    "allocate"
   "deallocate"
    ))
; Also match intrinsic functions when used in expressions (function_call node)
(call_expression
  (identifier) @function
  (#any-of? @function
    ; Math functions
    "abs" "acos" "asin" "atan" "atan2" "ceiling" "cos" "cosh" "exp" "floor"
    "log" "log10" "max" "min" "mod" "sign" "sin" "sinh" "sqrt" "tan" "tanh"
    "real" "int" "nint" "aint" "anint" "dble" "cmplx"
    ; Array functions
    "size" "shape" "lbound" "ubound" "allocated" "associated"
    "matmul" "dot_product" "sum" "product" "maxval" "minval" "count"
    "any" "all" "merge" "pack" "unpack" "reshape" "transpose" "spread"
    ; String functions
    "len" "len_trim" "trim" "adjustl" "adjustr" "index" "scan" "verify"
    ; Type inquiry
    "kind" "selected_int_kind" "selected_real_kind" "precision" "range"
    ; Bit functions
    "iand" "ior" "ieor" "not" "ishft" "ishftc" "btest" "ibset" "ibclr"
    ; Miscellaneous
    "present" "null" "transfer" "huge" "tiny" "epsilon"
    ))

[
  "&"
] @punctuation.special (#set! "priority" 200)

[
  "=>"
] @operator.pointer (#set! "priority" 200)

(block_label) @label.fortran
(block_label_start_expression) @label.fortran
(name) @label.fortran
(type_name) @label.fortran
(end_block_construct_statement) @keyword

