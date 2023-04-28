remap(x, from, to) = remap(x, from[1], from[2], to[1], to[2])
remap(x, low1, high1, low2, high2) = (x - low1) * (high2 - low2) / ifelse(high1 == low1, one(high1), high1 - low1) + low2
