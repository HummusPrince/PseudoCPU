start:
    JWZ A, finish
    JWZ B, finish

shifta:
    JBZ A, shiftb
    SHF A
    JMP shifta

shiftb:
    JBZ B, bigger
    SHF B
    JMP shiftb

bigger:
    JGE A, B, a_bigger

b_bigger:
    SUB B, A
    JMP start

a_bigger:
    SUB A, B
    JMP start

finish:
    JMP finish
