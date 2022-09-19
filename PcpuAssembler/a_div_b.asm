start:
    JGE A, B, sub
shift:
    SHF B
    JBZ B, finish
    JMP start
sub:
    SUB A, B
    JMP shift
finish:
    JMP finish


