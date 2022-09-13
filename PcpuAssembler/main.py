import argparse

parser = argparse.ArgumentParser(description='PcpuAsslembler is simple two pass assembler for PseudoCpu educational exerice')
parser.add_argument('input_file', metavar='input_file', type=str, help="input .asm path to assemble")
parser.add_argument('output_file', metavar='output_file', type=str, help="output .bin path ")


commands = [ 'JMP', 'JEQ', 'JGE', 'JBZ', 'SUB', 'SHF']
registers = ['A', 'B']

MEMSIZE    = 16
    
SO_EQ      = 0
SO_GE      = 1
SO_BZ      = 2

SO_SHF     = 0
SO_SUB     = 1

class InvalidCommand(Exception):
    def __init__(self, command):
        self.command = command
        self.message = "{} is not a Valid command. Valid commands: {}".format(self.command, commands)
        super().__init__(self.message)

class MemoryOverflow(Exception):
    def __init__(self, memory_used):
        self.memory_used = memory_used
        self.message = "Program used {} instructions while memroy support only {} instructions".format(self.memory_used, MEMSIZE)
        super().__init__(self.message)

def construct_command(so=0, sw=0, wb=0, wa=0, jc=0, ju=0, ad=0):
    line = "{}{}_{}{}{}_{}{}_{}{}{}{}".format((so>>1)&1, so&1, sw&1, wb&1, wa&1,jc&1, ju&1, (ad>>3)&1, (ad>>2)&1, (ad>>1)&1, ad&1)
    return line


def parse_command(line, labels):
    command = line[0:3]
    com_arg = [x.strip() for x in line[3:].split(",")]

    if command == 'JMP':
        label = com_arg[0]
        command_bin = construct_command(ju=1, ad=labels[label])

    elif command == 'JEQ':
        label = com_arg[-1]
        command_bin = construct_command(so=SO_EQ, jc=1, ad=labels[label])

    elif command == 'JGE':
        label = com_arg[-1]
        if com_arg[0] == 'A':
            command_bin = construct_command(so=SO_GE, jc=1, ad=labels[label])
        else:
            command_bin = construct_command(sw=1, so=SO_GE, jc=1, ad=labels[label])

    elif command == 'JBZ':
        label = com_arg[-1]
        if com_arg[0] == 'A':
            command_bin = construct_command(so=SO_BZ, jc=1, ad=labels[label])
        else:
            command_bin = construct_command(sw=1, so=SO_BZ, jc=1, ad=labels[label])

    elif command == 'SUB':
        if com_arg[0] == 'A':
            command_bin = construct_command(so=SO_SUB, wa=1)
        else:
            command_bin = construct_command(sw=1, so=SO_SUB, wb=1)
            
    elif command == 'SHF':
        if com_arg[0] == 'A':
            command_bin = construct_command(so=SO_SHF, wa=1)
        else:
            command_bin = construct_command(sw=1, so=SO_SHF, wb=1)

    else :
        print("Error! command {} is not valid".format(command))
        raise InvalidCommand(command)

    return command_bin


def secondpass(input_file, labels):
    with open(input_file,"r") as f:
        bin_lines = []
        for line in f.readlines():
            line = line.split(';')[0].strip()
            if (line == ""):        # empty line
                continue
            elif ( ':' in line):    # label line
                continue
            else :                  # command line
                bin_lines.append(parse_command(line, labels))

    return "\n".join(bin_lines)

        
def firstpass(input_file):
    with open(input_file,"r") as f:
        address = 0
        labels = {} 
        for line in f.readlines():
            line = line.split(';')[0].strip()       # ignore comments
            if (line == ""):    # empty line
                continue
            elif ':' in line:   # label line
                label = line.split(':')[0]
                labels[label] = address
            else :              # command line
                address += 1

    return labels, address
        

def PcpuAssmbler_main():
    args = parser.parse_args()
    print("Starting first pass")
    labels, inst_count = firstpass(args.input_file)
    print("Found {} labels".format(len(labels)))
    if inst_count > MEMSIZE:
        raise MemoryOverflow(inst_count)
    else:
        print("Using {} out of {} instruction space".format(inst_count, MEMSIZE))
    print("Starting second pass")
    binfile = secondpass(args.input_file, labels)
    print("Generated bin file:")
    print("----------------------------")
    print(binfile)
    print("----------------------------\n")
    print("writing bin file to {}".format(args.output_file))
    with open(args.output_file, "w") as f:
        f.write(binfile)
    print("Finished")


if __name__ == "__main__":
    PcpuAssmbler_main()
