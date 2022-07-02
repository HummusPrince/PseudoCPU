#!python


def main():
    v=open("./testlist.csv","r+")
    a=open("./a.b","w+")
    b=open("./b.b","w+")
    g=open("./g.b","w+")

    for l in v.readlines():
        tmp = (l.strip()).split(',')
        writebin(a,tmp[0])
        writebin(b,tmp[1])
        writebin(g,tmp[2])

    v.close()
    a.close()
    b.close()
    g.close()


def writebin(fd, val, pad = 32):
    fd.write(bin(int(val))[2:].zfill(pad)+'\n')

if __name__ == "__main__":
    main()
