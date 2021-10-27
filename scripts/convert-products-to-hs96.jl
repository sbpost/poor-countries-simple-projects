using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow

# There a few ways to ...

# 1. Exploit the fact that some factories are observed in years on either side of code-change.
# For instance, if changes from ASICC to NPCMS happens in 2010, we have factories that are observed in 2010 and in 2011.


# Convert ASICC years to
