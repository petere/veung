import csv
import sys

if len(sys.argv) > 1:
    min_nodes = int(sys.argv[1])
else:
    min_nodes = 0

logreader = csv.reader(sys.stdin)

i = 0
for row in logreader:
    msg = row[13]
    if '  plan' in msg:
        plan = (msg.partition('\n'))[2]
        if plan.count('Node Type') >= min_nodes:
            with open("%04d.json" % i, 'w') as f:
                f.write(plan)
        i += 1
