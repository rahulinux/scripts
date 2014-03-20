#!/usr/bin/evn python
import sys
import csv
import subprocess

if len(sys.argv) != 3:
        print "\nUsage:\n\t %s <file1> <file2>\n" % sys.argv[0]
        raise SystemExit(1)
else:
        file1,file2 = sys.argv[1:3]

of = open("output.csv","wb")
reader = csv.reader(open(file1))
output = csv.writer(of,quoting=csv.QUOTE_MINIMAL)
for row in reader:
        if row[6]:
                cmd = [ "/bin/awk -F,  '$2 ~ /%s/' %s" % (row[6],file2) ]
        else:
                continue
        #print cmd # tshoot awk
        proc = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
        match = proc.stdout.read()
        #match = proc.stderr.read()
        #print match
        #sys.exit(0)
        if match:
                #print ','.join(row)
                print row
                output.writerow(row)
                for l in match.split("\n"):
                        output.writerow(l.split(','))
                #output.writerow(row)
                #output.writerow(match)
                #sys.exit(0)

of.close()
