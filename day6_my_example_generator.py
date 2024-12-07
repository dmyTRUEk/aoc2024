from sys import argv as cli_args
from random import random

cli_args = cli_args[1:]

# density = 838 / 130**2 # .05
density = float(cli_args[0])
n = int(cli_args[1])

def random_symbol() -> str:
	return '#' if random() < density else '.'

m = []
for _ in range(n):
	line = []
	for _ in range(n):
		line.append(random_symbol())
	m.append(''.join(line))
m = '\n'.join(m)

print(m)
