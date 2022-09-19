start:
    JEQ A, B, finish
    JGE A, B, sub_ab
sub_ba:
    SUB B, A
    JMP start
sub_ab:
    SUB A, B
    JMP start
finish:
    JMP finish
