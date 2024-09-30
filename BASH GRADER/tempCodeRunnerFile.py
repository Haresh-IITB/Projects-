import numpy as np

rollNumber = np.char.lower(np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,0])

print(rollNumber)