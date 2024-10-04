acc = 0
for i in range(1, 30*12+1):
    acc += 200
    acc *= 1.15**(1/12)
print(acc)


# (1+m)^12 = 1.15 => m = (1.15)^(-12)-1