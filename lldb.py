curr_cost = frame.FindVariable("currSplitCost").GetValue()
curr_mid = frame.FindVariable("t").GetValue()
print("Cost: ", str(curr_cost), " Curr_mid: ", str(curr_mid))
return False
DONE