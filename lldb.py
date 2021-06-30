
# To print the cost and mid at each iteration in the for loop of optimalSegmentation.
curr_cost = frame.FindVariable("currSplitCost").GetValue()
curr_mid = frame.EvaluateExpression("this -> mid").GetValue()
i = frame.FindVariable("i").GetValue()
print("Iteration: ", i, " Cost: ", str(curr_cost), " Curr_mid: ", str(curr_mid))
if i == 18:
    return True
return False
DONE

curr_cost = frame.FindVariable("currSplitCost").GetValue()
i = frame.FindVariable("i").GetValue()
print("Iteration: ", i, " Cost: ", str(curr_cost))
return False
DONE

# To visualize the separate and sum costs
first = frame.FindVariable("first").GetValue()
second = frame.FindVariable("second").GetValue()
whole = frame.FindVariable("total").GetValue()
print("First: ", first, " Second: ", second, " Sum: ", whole, "\n")
return False
DONE
