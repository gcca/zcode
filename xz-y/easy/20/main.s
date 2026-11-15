// x0: input argument; w0: boolean or character result.
.text
.p2align 2
.globl _IsOpening
_IsOpening:
    cmp w0, #123                  // '{'
    b.eq Lopening_yes
    cmp w0, #91                   // '['
    b.eq Lopening_yes
    cmp w0, #40                   // '('
    cset w0, eq
    ret
Lopening_yes:
    mov w0, #1
    ret

.p2align 2
.globl _ClosingOf
_ClosingOf:
    cmp w0, #125                  // '}'
    b.eq Lclosing_curly
    cmp w0, #93                   // ']'
    b.eq Lclosing_square
    cmp w0, #41                   // ')'
    b.eq Lclosing_round
    b _abort                      // Unsupported input violates the precondition.
Lclosing_curly:
    mov w0, #123
    ret
Lclosing_square:
    mov w0, #91
    ret
Lclosing_round:
    mov w0, #40
    ret

.p2align 2
.globl _ValidParenthesis
_ValidParenthesis:
    // Keep the frame and SP aligned to 16 bytes at every call.
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    // x19: input cursor, x20: heap stack, x21: stack size.
    // w22: current character, w23: result preserved across free().
    mov x19, x0
    bl _strlen
    cbz x0, Lvalid_empty
    bl _malloc
    cbz x0, Lvalid_abort
    mov x20, x0
    mov x21, #0
Lvalid_loop:
    ldrb w22, [x19], #1
    cbz w22, Lvalid_end
    mov w0, w22
    bl _IsOpening
    cbz w0, Lvalid_close
    strb w22, [x20, x21]
    add x21, x21, #1
    b Lvalid_loop
Lvalid_close:
    mov w0, w22
    bl _ClosingOf
    cbz x21, Lvalid_mismatch
    sub x21, x21, #1
    ldrb w8, [x20, x21]
    cmp w8, w0
    b.ne Lvalid_mismatch
    b Lvalid_loop
Lvalid_end:
    cmp x21, #0
    cset w23, eq
    b Lvalid_free
Lvalid_mismatch:
    mov w23, #0
Lvalid_free:
    mov x0, x20
    bl _free
    mov w0, w23
    b Lvalid_return
Lvalid_empty:
    mov w0, #1
Lvalid_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
Lvalid_abort:
    bl _abort
    brk #0

.p2align 2
.globl _main
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    // Each table entry has four 64-bit fields:
    // function pointer, argument, expected result, display name.
    // x19: cursor, x20: end, x21: failures, x22: expected, x23: name.
    adrp x19, Ltests@PAGE
    add x19, x19, Ltests@PAGEOFF
    adrp x20, Ltests_end@PAGE
    add x20, x20, Ltests_end@PAGEOFF
    mov x21, #0
Ltest_loop:
    cmp x19, x20
    b.eq Ltest_end
    ldp x16, x0, [x19]
    ldp x22, x23, [x19, #16]
    blr x16
    cmp x0, x22
    b.eq Ltest_pass
    add x21, x21, #1
    adrp x0, Lfail@PAGE
    add x0, x0, Lfail@PAGEOFF
    bl _puts
    b Ltest_name
Ltest_pass:
    adrp x0, Lpass@PAGE
    add x0, x0, Lpass@PAGEOFF
    bl _puts
Ltest_name:
    mov x0, x23
    bl _puts
    add x19, x19, #32
    b Ltest_loop
Ltest_end:
    cbnz x21, Ltest_failed
    adrp x0, Lsuccess@PAGE
    add x0, x0, Lsuccess@PAGEOFF
    bl _puts
    mov w0, #0
    b Ltest_return
Ltest_failed:
    adrp x0, Lfailure@PAGE
    add x0, x0, Lfailure@PAGEOFF
    bl _puts
    mov w0, #1
Ltest_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.section __TEXT,__const
Lpass: .asciz "PASS:"
Lfail: .asciz "FAIL:"
Lsuccess: .asciz "All 31 tests passed."
Lfailure: .asciz "Test failures detected."
Linput0: .asciz "()"
Linput1: .asciz "[]"
Linput2: .asciz "{}"
Linput3: .asciz "()[]{}"
Linput4: .asciz "{[()]}"
Linput5: .asciz "{[()()]([])}{}[({})]"
Linput6: .asciz "(()[{}])({[]})"
Linput7: .asciz ""
Linput8: .asciz "(]"
Linput9: .asciz "[(])"
Linput10: .asciz "("
Linput11: .asciz ")"
Linput12: .asciz "())"
Linput13: .asciz "(()"
Linput14: .asciz "{[()()]([])}{}[({})]]"
Linput15: .asciz "{[()()]([])}{}[({})]({"
Linput16: .asciz "{[()()]([)]}{}"
Linput17: .asciz "{[({[()]})]}[({[}])]"
Ldeep:
    .fill 5000, 1, 40
    .fill 5000, 1, 41
    .byte 0
Ladjacent:
    .rept 5000
    .ascii "[]"
    .endr
    .byte 0
Lmismatch:
    .fill 4999, 1, 40
    .byte 91
    .fill 5000, 1, 41
    .byte 0
Lname0: .asciz "opening ("
Lname1: .asciz "opening ["
Lname2: .asciz "opening {"
Lname3: .asciz "not opening )"
Lname4: .asciz "not opening ]"
Lname5: .asciz "not opening }"
Lname6: .asciz "not opening a"
Lname7: .asciz "closing }"
Lname8: .asciz "closing ]"
Lname9: .asciz "closing )"
Lname10: .asciz "valid '()'"
Lname11: .asciz "valid '[]'"
Lname12: .asciz "valid '{}'"
Lname13: .asciz "valid '()[]{}'"
Lname14: .asciz "valid '{[()]}'"
Lname15: .asciz "valid '{[()()]([])}{}[({})]'"
Lname16: .asciz "valid '(()[{}])({[]})'"
Lname17: .asciz "valid ''"
Lname18: .asciz "invalid '(]'"
Lname19: .asciz "invalid '[(])'"
Lname20: .asciz "invalid '('"
Lname21: .asciz "invalid ')'"
Lname22: .asciz "invalid '())'"
Lname23: .asciz "invalid '(()'"
Lname24: .asciz "invalid '{[()()]([])}{}[({})]]'"
Lname25: .asciz "invalid '{[()()]([])}{}[({})]({'"
Lname26: .asciz "invalid '{[()()]([)]}{}'"
Lname27: .asciz "invalid '{[({[()]})]}[({[}])]'"
Lname28: .asciz "deep nesting"
Lname29: .asciz "long adjacent pairs"
Lname30: .asciz "deep mismatch"

.section __DATA,__const
.p2align 3
Ltests:
    .quad _IsOpening, 40, 1, Lname0
    .quad _IsOpening, 91, 1, Lname1
    .quad _IsOpening, 123, 1, Lname2
    .quad _IsOpening, 41, 0, Lname3
    .quad _IsOpening, 93, 0, Lname4
    .quad _IsOpening, 125, 0, Lname5
    .quad _IsOpening, 97, 0, Lname6
    .quad _ClosingOf, 125, 123, Lname7
    .quad _ClosingOf, 93, 91, Lname8
    .quad _ClosingOf, 41, 40, Lname9
    .quad _ValidParenthesis, Linput0, 1, Lname10
    .quad _ValidParenthesis, Linput1, 1, Lname11
    .quad _ValidParenthesis, Linput2, 1, Lname12
    .quad _ValidParenthesis, Linput3, 1, Lname13
    .quad _ValidParenthesis, Linput4, 1, Lname14
    .quad _ValidParenthesis, Linput5, 1, Lname15
    .quad _ValidParenthesis, Linput6, 1, Lname16
    .quad _ValidParenthesis, Linput7, 1, Lname17
    .quad _ValidParenthesis, Linput8, 0, Lname18
    .quad _ValidParenthesis, Linput9, 0, Lname19
    .quad _ValidParenthesis, Linput10, 0, Lname20
    .quad _ValidParenthesis, Linput11, 0, Lname21
    .quad _ValidParenthesis, Linput12, 0, Lname22
    .quad _ValidParenthesis, Linput13, 0, Lname23
    .quad _ValidParenthesis, Linput14, 0, Lname24
    .quad _ValidParenthesis, Linput15, 0, Lname25
    .quad _ValidParenthesis, Linput16, 0, Lname26
    .quad _ValidParenthesis, Linput17, 0, Lname27
    .quad _ValidParenthesis, Ldeep, 1, Lname28
    .quad _ValidParenthesis, Ladjacent, 1, Lname29
    .quad _ValidParenthesis, Lmismatch, 0, Lname30
Ltests_end:
.subsections_via_symbols
