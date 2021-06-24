
# To print the cost and mid at each iteration in the for loop of optimalSegmentation.
curr_cost = frame.FindVariable("currSplitCost").GetValue()
curr_mid = frame.EvaluateExpression("this -> mid").GetValue()
print("Cost: ", str(curr_cost), " Curr_mid: ", str(curr_mid))
return False
DONE

# To visualize the separate and sum costs
first = frame.FindVariable("first").GetValue()
second = frame.FindVariable("second").GetValue()
whole = first + second
print("First: ", first, " Second: ", second, " Sum: ", whole)
return False
DONE
