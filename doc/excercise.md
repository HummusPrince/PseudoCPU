# Excersice - Pseudo-Processor

## Preface
This excercise is meant to bridge the gap between "naive" state-machines usually shown in introductory courses to digital design, and fully-fledged CPU designs shown in computer-architecture introductory courses.

That is - How did the simple concepts and design practices of small FSMs (Transition graphs synthesized using Karnaugh maps) developed into the very specific (and complex) structure of modern CPUs?

To tackle this issue and give intuition to "how CPUs have developed into what we know today", it's helpful to examine a borderline problem - too simple for full CPUs, yet too complex to efficiently solve with naive methods.

Our model problem would be GCD computation - using the Binary Euclidian Algorithm - and our design would include proper datapath-control seperation, table-based state-machines, and degenerate appearances of the ALU and register-file concepts.

## The algorithm
Let us examine the problem we're about to solve, and the solutions used to solve it.

Notice that for the purpose of this excersice, it isn't necessary to understand the whole details of the algorithm, proving that it works, and it's applications.

Therefore this part will include minimal explanations of the math and algorithm.
However, you're encouraged to learn more about this exciting topic at your free time.

### Greatest Common Divisor
Consider 2 natural numbers, a and b. Both always have a common natural number g', which divides them both. This number is call a _Common Divider_, and g'=1 is always a valid common divider for any natural a and b.

For some a,b 1 is the only common divider. But for others, bigger g' exists. For example, for a = 4 and b = 6, 2 is also a common divider.
There should always exist such maximal common divider g for each a,b, called the _Greatest Common Divider_, or GCD.

That simple notion is highly important in Number Theory, and scholars have studied it well before the 3rd century B.C.

### Euclidean Algorithm
In his Elements, Euclid described an efficient algorithm for finding the GCD of two numbers, today named after him.

This algorithm is actually of logarithmic complexity in the integer sizes, and is considered the first efficient non-trivial algorithm in human history.

The principle behind the algorithm is dividing the problem into a series of repeating steps, each decreases the numbers further, until some condition is met.

In the Euclidian Algorithm, this step is taking the reminder by devision of the larger number by the smaller one, and replacing the bigger number by that reminder.

The algorithm will stop when 0 is met, that is the bigger number is the GCD.

In C-like pseudocode, it looks thus:

```
int a, b;
while((a!=0)&&(b!=0)){
	if(a<b) b=a%b;
	else a=b%a;
}
return a ? a : b;
```

It can be shown that the algorithm run with logarithmic complexity, given reminder calculation at O(1). Thus it can be considered the first efficient algorithm in human history.

### Stein's algorithm
Computing general reminders is not easy. One way is using division by repeated subtraction, which in the general case can be inefficient.

```
while(a<b){
	b-=a;
}
```

Better techniques in hardware require complex designs. Thus for hardware, a better-suited algorithm is useful.

Division by 2 is simple in hardware - it's simply a shift right. substraction is simple, too. Thus, a variant of the Euclidean Algorithm using both operations can yield a better solution.

This algorithm is called _Binary Euclidean Algorithm_ or _Stein's Algorithm_, and it keeps the structure of the regular Euclidean Algorithm, only replacing the iterative step with another.

In Stein's algorithm, we divide by 2 (== shift right) whenever a or b are even, until they're both odd. Then we decrease the smaller one from the bigger.

In C-like pseudocode:

```
int a,b;
while (a!=b){
	while(a&0x0000001) a>>=1;
	while(b&0x0000001) b>>=1;

	if (a==b) break;
	
	if(a<b) b-=a;
	else a-=b;
}
return a;
```

Notice that the code above has a quirk - if both a,b are even, false GCD will return - it will be the greatest **odd** Common Divider. To accomodate that we must ensure that at least one of a,b is odd, or divide both by 2 repeatedly until one is odd, later multiplying both by that multiple of 2:

```
int a,b;
int p=0;
while((a&0x00000001==0)&&(b&0x00000001==0)){
	p++;
	a>>=1;
	b>>=1;
}
return binary_gcd(a,b)<<p;
```

For simplicity, let's consider only the case where at least one of a,b is odd.

### Examples
Let take for example `a=91`, `b=154`. Their GCD should be `7`, as `a=13*7` and `b=2*7*11`.

Lets see how it can be found using Euclid's Algorithm:

```
start:
a = 91, b = 154

reduce: (b is bigger)
b%a = 154%91 = 154 - 1*91 = 63

now:
a = 91, b = 63

reduce: (a is bigger):
a%b = 91%63 = 91 - 1*63 = 28

now:
a=28, b=63

reduce: (b is bigger)
b%a = 63%28 = 63 - 2*28 = 7

now:
a=28, b=7

reduce: (a is bigger)
a%b = 28%7 = 28 - 4*7 = 0

finish:(a is zero!)
b = 7

GCD(a,b) = 7
```

That's nice! Let's do the same with Stein's Algorithm:

```
start:
a = 91, b = 154

divide by 2: (b is even)
b>>1 = 154/2 = 77 (odd)

reduce: (a is bigger)
a - b = 91 - 77 = 14

now:
a = 14, b = 77

divide by 2: (a is even)
a>>1 = 7 (odd)

reduce: (b is bigger)
b - a = 77 - 7 = 70

now:
a = 7, b = 70

divide by 2: (b is even)
b>>1 = 35 (odd)

reduce: (b is bigger)
b - a = 35 - 7 = 28

now:
a = 7, b = 28

divide by 2: (b is even)
a>>1 = 14 (even)
a>>1 = 7 (odd)

finish (a == b):
a = 7

GCD(a,b) = 7
```

It can be noticed that the flow of Stein's algorithm is a bit more complex, yet it avoids the dreaded modulo operator.

You're encouraged to try it for yourself with different numbers, such as 352 and 198.

## The Hardware
Let's consider how to implement it in hardware.
We'll go with a simple, one operation at a time architecture.

The Datapath will be designed first, and the control afterwards to handle it's operation.

The design will not be "optimal" by any concrete mean such as troughput or gate-count, but will have several structural advantages that cosiderably ease development.

### Datapath
First, only 2 registers are needed, for both a and b. These should be write-enabled seperately.

Several arithmetic operations using both are needed, these are:
- a>>1
- b>>1
- a-b
- b-a

These outputs, the bit width of a and b each, should be written back to a and b.

Also, some logical operations should be implemented to allow branching. These include:

- a==b
- a<b
- a%2 (a&0x01==1)
- b%2 (b&0x01==1)

The result bit should be fed into the control section and manage the logic flow.

It can be noticed that most operations on this list are actually the same operator with the other operand (unary), or the operands swapped (binary). Thus, it's only logical to add a "swap" block that switches the operands, and be left with the following __operators__ rather than __operations__:

- minus
- shift 1 right
- equal
- bigger than
- modulo 2

These are 2 arithmetic operands and 3 logic ones. A reasonable approach is to calculate all these 5, and choose the output using 2 MUXes sharing the 2 selector bits: one for the logic result and one for the arithmetic, where the arithmetic result is fed back to the registers and the logic one is fed into the control module.

Schematically, it should look thus:

![](pseudocpu-Datapath.drawio.svg)

The datapath is controlled by 5 control signals:

- WA = Write Enable for register A
- WB = Write Enable for register B
- SW = Swap the operands A and B
- OP [1:0] = 2 selector bits to select operand

Their value at each clock will determine the exact logic executed.

### Control
The other part in the design is the controller. The controller can be formulated as a classic state machine, but the logic of Stein's algorithm is complex enough to make that uncomfortable.

To make our life easier, we'll take a different approach - a "table based" state machine.

In this approach, most of the FSM is implemented as a table, or ROM, where each address represents a state, and the word stored at each address is the output of the FSM, effectively the control bits or state information.

The state information will be broken into 2 sets of control bits - the outputs (e.g control bits for the datapath), and the next-state control bits.

We will design the controller as a Moore FSM, that is - the outputs of the controller  will be solely determined by the current state. The next state depends on both the current state and the data.

What size is that table? Lets begin with the depth - we'll show later that for our algorithm no more that 16 states/ops are needed. Thus the table will be of depth 16, that is 4 address bits.

Now for the width. Each word should contain at least 5 control bits, which directly control the ALU - these are the output bits.

what about next-state control? The most basic thing is the next state - that means that the next address should be stored in the word too, and that's 4 additional bits.

How do we branch? We need to store another 4 bits, for the other next-address option. As this is expensive, another approach is cheaper and mathmatically equivalent - the next state/address is by default the current address incremented by 1, and the branch-to address is the only one stored.

We'll have to include 1 extra bit in the next-state control, to tell wether it's an _coditional jump_, dependent on the CRES from the datapath, or regular flow.

Also needed sometimes is _uncoditional jump_, that is a non-data-dependent next state at arbitrary address. These will be JC and JU, respectively.

So we've got 5 control bits, 4 address bits and 2 jump bits - that's an oddball 11 bit word.

The whole control logic should look thus:

![](pseudocpu-Control.drawio.svg)

JC and JU can be seen as "control bits of the controller", and by setting their values in each word we define the type of the operation done at that state.

### The code
We have designed a hardware module that can perform our algorithm - but it can't yet, as something's still missing.

The secret sauce we have not added yet are the states themselves, encoded as words in the table at the control section.

The table allow us to describe each as an operation, and describe the whole logic as some kind of "code", without considering the nitty-gritty details of the hardware implementation.

Thus, the pseudo-code for Stein's algorithm can be "compiled" into some sort of assembly language for this particular hardware design:

```
start:
    JEQ A, B, finish

shifta:
    JBZ A, shiftb
    SHF A
    JMP shifta

shiftb:
    JBZ B, bigger
    SHF B
    JMP shiftb

bigger:
    JEQ A, B, finish
    JGE A, B, a_bigger

b_bigger:
    SUB B, A
    JMP start

a_bigger:
    SUB A, B
    JMP start

finish:
    JMP finish
```

Where:

- `JMP label = uncoditional jump to the address of that label
- `JEQ X, Y, label` = conditional jump to the address of the label given that X equals Y
- `JGE X, Y, label` = conditional jump to the address of the label given that A is greater than B
- `JBZ X, label` = conditional jump to the address of the label given that X%2==0 (LSB is zero)
- `SUB X, Y` = substract Y from X, store the result in X
- `SHF X` = shift X one place right (that is, divide by 2), store the result in X

You should go over the code, maybe running the previous example line by line in your mind, and be convinced that the assembly shown correctly implement Stein's Algorithm (again when at least one input is odd).

How does that assembly translate into state-word stored in the control table? That is, how does it map into machine language?

Lets look at `SHF` for example. both JC and JU should be 0, as it's an arithmetic operation, whose flow does not depend on the result. Thus, the next address bytes are X, a don't care value.

The OP bits should choose the shift operation and not the minus operation. The specific value depend on the way the mux is configured. For `SHF A`, SW should be zero, but for `SHF B` it should be 1. WA and WB should be 1 and 0, or the opposite, respectively.

For JMP label, the control bits do not matter much - WAA and WB should both be 0 as to not write anything, while OP and SW are X, as their value doesn't matter. JU should be one, and as it override JC it can be X too. The ADDR should be the address of the next state.

The order of the bits in the word is arbitrary, and it's up to the designer to choose it.

## Conclusion
Now that we have described the whole system, we can discuss our design choices and other considerations we had along the way.

### The power of our design
The design we've chosen is by no means optimal - each iteration takes multiple cycles, and most of the hardware is idle at any given moment. It's possible to make it either faster, or cheaper in gates, than our design.

The power of our design is in the _simplicity_ and _modularity_ that it offers.

The datapath consists of different computation blocks that can be developed independent of each other and of the whole datapath. It makes it easy to modify the datapath to support different operations, and thus other algorithms.

The control hardware is a complete module that needs to be designed and implemented only once for any variation of this type of hardware, only changing the table dimensions. The brains are in the entries themselves, the code, that can be developed (programmed) independent from the development of the hardware.

This design essentialy divides the system into several independent subsystems. It makes this type of design a strong framework for computation systems.

This kind of philosophy stands behind CPUs - The 2 registers and swapper upgrades into a register file, the datapath ops+mux grow into an ALU with many operators to support all types of computations, and the ROM table is now the Instruction Memory that stores assembled machine code.

That way, the hardware can be developed only once to run all types of logic, whose development is easier and simpler. Thus, a computer is born.


### Excecise
Let's make a complete GCD computer. The Control and Datapath blocks are already implemented for you.
Integrate both parts together and compose the machine code that runs Stein's Algorithm (use the pseudo-assembly appearing earlier in this document). Simulate the whole system to prove that it works.

(Tip: for working the machine code, try 'vim -S machine_code.vim').

Good luck :)
