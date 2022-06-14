##Variables

FILE = sim

VC = iverilog
VCFLAGS = -g2001
VSRC = src/*.v sim/tb.v
BSRC = src/bin/eq_zero_optimized.b

SIM = vvp

VIEW = gtkwave


##Rules
%.vcd: %.vvp
	${SIM} $<


##Targets
sim.vvp:
	${VC} ${VCFLAGS} -o ${FILE}.vvp ${VSRC} 

.PHONY: sim
sim: ${FILE}.vvp

.PHONY: run
run: ${FILE}.vcd

.PHONY: view
view: run
	${VIEW} ${FILE}.vcd

.PHONY: clean
clean:
	rm *.vvp *.vcd
