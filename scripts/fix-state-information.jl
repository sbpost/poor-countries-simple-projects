using Arrow
using DataFramesMeta
using DataFrames
using CSV

A_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-A-all-years.arrow")) |> DataFrame

# Create state information ------------------------------------------------
# States change a bit during the period. A little bit of messy code is needed
# to fix it. Correct state names is supplied with the panel data. The 6th and
# 7th character in factory_id lists the state code. I use this code to assign
# state names.

# 140 factories from 2006 has a mistake in the format of their factory_id.
# They have too few digits. That is, their format is something like "99321F"
# wheres the proper format is "3319805F". I drop these observations.

state_df = @chain A_df begin
    @rtransform _ :factory_id = strip(:factory_id)
    @rsubset _ length(:factory_id) == 8
    @rtransform _ :state_code = :factory_id[6:7]
    @rtransform _ :state_code = parse(Int, :state_code)
    @select(_, :year, :april_year, :march_year, :factory_id, :state_code)
end

state_codes_9899_to_1112_path = datadir("external", "asi", "asi-2010-2015", "State Master 1998-99 to 2011-12.csv")
state_codes_1213_path = datadir("external", "asi", "asi-2010-2015", "State Master 2012-13 onwards.csv")

state_codes_9899_to_1112 = CSV.read(state_codes_9899_to_1112_path, DataFrame)
state_codes_1213 = CSV.read(state_codes_1213_path, DataFrame)

# Split data in order to assign state codes correctly:
state_99_12 = @rsubset state_df :year < 2013
state_13_on = @rsubset state_df :year > 2012

# Add names of states:
state_99_12 = leftjoin(state_99_12, state_codes_9899_to_1112, on=:state_code => :Codes)
state_13_on = leftjoin(state_13_on, state_codes_1213, on=:state_code => :Codes)

# Rejoin the data:
state_df = vcat(state_99_12, state_13_on)
rename!(state_df, "State Name" => :state)
state_df.state = String.(state_df.state)

# Now each observation has a state attached. However, names are not the same across the two
# periods. I fix this.
state_df.state = fix_state.(state_df.state)

# Write to file:
Arrow.write(
    datadir("processed", "ASI", "state-id.arrow"),
    state_df
)
