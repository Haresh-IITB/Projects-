import math , copy 
import numpy as np
import matplotlib.pyplot as plt 
plt.style.use('./deeplearning.mplstyle')
np.set_printoptions(precision = 2) # Setting to print of 2 decima places 


x_train = np.array([[2104,5,1,45],[1416,3,2,40],[852,2,1,35]])
y_train=np.array([460,232,178])

b_init = 45
w_init = 10*np.random.random_sample(4) - 5 

#This function predicts the value based on w and b
def predict(x,w,b) :
    return np.dot(x,w) + b # since x is not a 1D vector it perform's matmul(x,w)

def compute_cost(x,y,w,b) :
    m = x.shape[0] 
    f_wb = predict(x,w,b) 
    cost_i = (f_wb-y)**2
    cost = np.sum(cost_i)
    cost/=(2*m)

    return cost 

#  Gradient descendant with multiple variable 

def compute_gradient(x,y,w,b) :

    #  df_dw = x*(f-y)/m
    # df_db = (f-y)/m
    m = x.shape[0]
    n = x.shape[1]

    f_wb = predict(x,w,b)
    err = (f_wb-y)/m
    err_mat = np.transpose(err)
    df_dw = np.transpose(np.matmul(err_mat,x))
    df_db = np.sum((f_wb-y)/m)

    return df_dw , df_db

tmp_dj_dw, tmp_dj_db = compute_gradient(x_train, y_train, w_init, b_init)
print(f'dj_db at initial w,b: {tmp_dj_db}')
print(f'dj_dw at initial w,b: \n {tmp_dj_dw}\n\n')

def gradient_descent(x,y,w_in,b_in,alpha,num_iters,compute_cost,commpute_gradient) :
    J_history=[]
    w = copy.deepcopy(w_in) # To avoid modifying the original set
    b = b_in

    for i in range(num_iters) :
        
        df_dw , df_db = compute_gradient(x,y,w,b)

        w  = w - (alpha*df_dw)
        b = b - (alpha*df_db)

        if i<100000 :
            J_history.append(compute_cost(x,y,w,b))

        if i%math.ceil(num_iters/10) == 0 :
             print(f"Iteration {i:4d}: Cost {J_history[-1]:8.2f}   ")

    return w,b,J_history


# some gradient descent settings
iterations = 10000000
alpha = 5.0e-7

# run gradient descent 
w_final, b_final, J_hist = gradient_descent(x_train, y_train, w_init, b_init,alpha, iterations,compute_cost, compute_gradient)
print(f"b,w found by gradient descent: {b_final:0.2f},{w_final} ")

m = x_train.shape[0]
for i in range(m):
    print(f"prediction: {np.dot(x_train[i], w_final) + b_final:0.2f}, target value: {y_train[i]}")


fig, (ax1, ax2) = plt.subplots(1, 2, constrained_layout=True, figsize=(12, 4))
ax1.plot(J_hist)
ax2.plot(100 + np.arange(len(J_hist[100:])), J_hist[100:])
ax1.set_title("Cost vs. iteration");  ax2.set_title("Cost vs. iteration (tail)")
ax1.set_ylabel('Cost')             ;  ax2.set_ylabel('Cost') 
ax1.set_xlabel('iteration step')   ;  ax2.set_xlabel('iteration step') 
plt.show()