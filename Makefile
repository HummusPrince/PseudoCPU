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
sim: ${FILE}.vvp test_vec

.PHONY: run
run: ${FILE}.vcd

.PHONY: view
view: run
	${VIEW} ${FILE}.vcd sim/values.gtkw

.PHONY: test_vec
test_vec:
	(cd sim/vectors && python csv2vecs.py)

.PHONY: clean
clean:
	rm *.vvp *.vcd

.PHONY: cleanall
cleanall:
	rm *.vvp *.vcd sim/vectors/?.b
