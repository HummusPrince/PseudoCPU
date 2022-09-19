start:
    JGE A, B, sub
finish:
    JMP finish
sub:
    SUB A, B
    JMP start
