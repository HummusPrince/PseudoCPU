import argparse

parser = argparse.ArgumentParser(description='PcpuAsslembler is simple two pass assembler for PseudoCpu educational exerice')
parser.add_argument('input_file', metavar='input_file', type=str, help="input .asm file to assemble")
commands = [ 'JMP', 'JEQ', 'JGE', 'JBZ', 'SUB', 'SHF']
registers = ['A', 'B']
        
def firstpass(input_file):
    with open(input_file,"r") as f:
        address = 0
        labels = {} 
        for line in f.readlines():
            print(line)
            line = line.split(';')[0].strip()       # ignore comments
            print(line)
            if (line == ""):
                continue
            elif ':' in line:
                label = line.split(':')[0]
                labels[label] = address
            else :
                address += 1

    return labels
        
def PcpuAssmbler_main():
    args = parser.parse_args()
    labels = firstpass(args.input_file)
    print(labels)






if __name__ == "__main__":
    PcpuAssmbler_main()
