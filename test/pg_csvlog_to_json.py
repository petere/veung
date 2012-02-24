import csv
import sys

logreader = csv.reader(sys.stdin)

i = 0
for row in logreader:
    msg = row[13]
    if '  plan' in msg:
        plan = (msg.partition('\n'))[2]
        with open("%04d.json" % i, 'w') as f:
            f.write(plan)
        i += 1
