from fuzzywuzzy import fuzz
### importing fuzz from fuzzywuzzy which calculates the Levenshtein distance between the string to match the closet ###     
import sys
import csv
import numpy as np

### Loading all the names from main.csv
names = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,1].tolist()

maxRatioWord = names[0]
maxFuzzRatio = fuzz.ratio(names[0],sys.argv[1])
for name in names :
    if fuzz.ratio(name,sys.argv[1]) > maxFuzzRatio :
        maxFuzzRatio = fuzz.ratio(name,sys.argv[1])
        maxRatioWord = name
        
print(maxRatioWord)

