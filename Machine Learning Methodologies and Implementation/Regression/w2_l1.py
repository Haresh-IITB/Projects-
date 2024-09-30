import numpy as np
import time

# Vector Creation 
a = np.zeros(4) 
print(f"np.zeros(4) :  a = {a} , a.shape = {a.shape} , a data type = {a.dtype} ")
a = np.zeros((4,))
print(f"np.zeros(4,) :  a = {a} , a.shape = {a.shape} , a data type = {a.dtype} ")
a = np.random.random_sample(4) #From [0,1) draw 4 random number and make an arr of it 
print(f"np.random.random_sample(4) :  a = {a} , a.shape = {a.shape} , a data type = {a.dtype} ")

# They dont take shape parameter as a tuple
a = np.arange(4.) # Make a array of equal space(by deafult 1) from [0,4) , use when stepsize is determined
print(f" np.arange(4.) : a= {a} , a shape = {a.shape} , a data type =  {a.dtype}")
a = np.linspace(2,3,5) # Make a array of equal space in interval [a,b] , use when no of elem are fixed 
print(f" np.linspace(2,3,5) : a= {a} , a shape = {a.shape} , a data type =  {a.dtype}")
a = np.random.rand(4) # same as randome_sample
print(f" np.random.rand(4) : a= {a} , a shape = {a.shape} , a data type =  {a.dtype}")

# Manually specified values
a = np.array([5,4,3,2])
print(f" np.array([5,4,3,2]) : a= {a} , a shape = {a.shape} , a data type =  {a.dtype}")
a = np.array([5.,4,3,2])
print(f" np.array([5.,4,3,2]) : a= {a} , a shape = {a.shape} , a data type =  {a.dtype}")


a = np.arange(10) 
print(f" a = {a}")

print(f"a[2] = {a[2]} , a[2] shape = {a[2].shape} , a[2] d type = {a[2].dtype}")

# Error handling that index should be within the range 
try : 
    c = a[10]
except Exception as e :
    print("The error message you'll see is : ")
    print(e)

c = a[2:7:1] #From [2,7) with step size 1
print(f"a[2:7:1] = " , c)

c = a[2:7:2]
print(f"a[2:7:2] = ",c)

c = a[3:] # #rd to last elem
print(f"a[3:] = ",c)

c = a[:3] # From [0,3)
print(f"a[:3] = ", c)

c = a[:] # Access all the elements
print(f"a[:] = ",c)


# Single Vector Operation
a = np.array([2,3,4,5])
print(f"a^2 = {a**2}")
print(f"mean of a = {np.mean(a)}")
print(f"sum of a = {np.sum(a)}")


# Vector vector element wise operations , vector should be of same size
a = np.array([1,2,3,4])
b = np.array([-1,-2,3,4])
print(f"Binary operators work element wise : {a+b}")

#try a mismatched vector operation
c = np.array([1, 2])
try:
    d = a + c
except Exception as e:
    print("The error message you'll see is:")
    print(e)



# Checking the time difference
def my_dot(a,b) :
    res = 0 
    for i in range(a.shape[0]):
        res += a[i]*b[i]
    return res 


# Changing the seed so that random elements are different
np.random.seed(2) 
a = np.random.rand(10000000)
np.random.seed(1)
b = np.random.rand(10000000)


tic = time.time() #Captureing the start time
c = np.dot(a,b) 
toc = time.time() #Capturing the end time

print(f"np.dot(a,b) = {c}")
print(f"TIme taken = {toc-tic:0.4e}")

tic = time.time() #Captureing the start time
c = my_dot(a,b) 
toc = time.time() #Capturing the end time

print(f"my_dot(a,b) = {c}")
print(f"TIme taken = {toc-tic:0.4e}")


del(a) ; del(b) #remove big array from mem to not slow down the system

# show common Course 1 example
X = np.array([[1],[2],[3],[4]])
w = np.array([2])
c = np.dot(X[1], w)

print(f"X[1] has shape {X[1].shape}")
print(f"w has shape {w.shape}")
print(f"c has shape {c.shape}") # Scalar not an array so no shape



a = np.zeros((1, 5))                                       
print(f"a shape = {a.shape}, a = {a}")                     

a = np.zeros((2, 1))                                                                   
print(f"a shape = {a.shape}, a = {a}") 

a = np.random.random_sample((1, 1))  
print(f"a shape = {a.shape}, a = {a}") 



# Operation on matrix
# We can't specify shpae in arange that's why using reshape , -1 means it find the shape by itslef so that no. of m*n = no. of elem
a = np.arange(6).reshape(-1, 2)   #reshape is a convenient way to create matrices
print(f"a.shape: {a.shape}, \na= {a}")

#access an element
print(f"\na[2,0].shape:   {a[2, 0].shape}, a[2,0] = {a[2, 0]},     type(a[2,0]) = {type(a[2, 0])} Accessing an element returns a scalar\n")

#access a row
print(f"a[2].shape:   {a[2].shape}, a[2]   = {a[2]}, type(a[2])   = {type(a[2])}")
# It is worth drawing attention to the last example. Accessing a matrix by just specifying the row will return a 1-D vector


a = np.arange(20).reshape(-1,10)
print(a)
#access 5 consecutive elements (start:stop:step)
print("a[0, 2:7:1] = ", a[0, 2:7:1], ",  a[0, 2:7:1].shape =", a[0, 2:7:1].shape, "a 1-D array")

#access 5 consecutive elements (start:stop:step) in two rows
print("a[:, 2:7:1] = \n", a[:, 2:7:1], ",  a[:, 2:7:1].shape =", a[:, 2:7:1].shape, "a 2-D array")

# access all elements
print("a[:,:] = \n", a[:,:], ",  a[:,:].shape =", a[:,:].shape)

# access all elements in one row (very common usage)
print("a[1,:] = ", a[1,:], ",  a[1,:].shape =", a[1,:].shape, "a 1-D array")
# same as
print("a[1]   = ", a[1],   ",  a[1].shape   =", a[1].shape, "a 1-D array")




