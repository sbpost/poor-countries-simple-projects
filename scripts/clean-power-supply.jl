using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using Statistics
using DataFramesMeta
using Chain
using Arrow
using CSV

function clean_powersupply(allcott_et_al_supply_path::String, allcott_et_al_supply_2003_path::String, cea_paths::Vector{String})
    # This function reads, cleans, and formats the power-supply data from
    # India's Central Electricity Authority.
    #
    # Outline:
    # 1. Read the paths supplied in the function arguments. Join the two sources.
    # 2. Do some basic cleaning: format column types, harmonize state names, etc.
    # 3. Calculate supply shortages and return the data.

    # ============================================================== #
    # 1. Read and join the data:
    # ---------------------------

    # Read the files supplied by Allcott et al
    powersupply_df = CSV.read(
        allcott_et_al_supply_path,
        DataFrame
    )

    powersupply03_df = CSV.read(
        allcott_et_al_supply_2003_path,
        DataFrame
    )

    powersupply_df = vcat(powersupply_df, powersupply03_df)
    rename!(powersupply_df,
            "Year" => :year, "State" => :state,
            "Requirement (MU)" => :requirement_mu, "Availability (MU)" => :availability_mu)

    # The data from Allcot et al and the data from CEA overlaps by 2 years (2009, 2010).
    # I use the data pulled from the CEA in those two years (because it
    # has been digitized by software and not transcribed by hand).
    powersupply_df = @rsubset(powersupply_df, :year < 2009)

    # Read the files from the CEA:
    # Separate out tables with peak supply from tables with average power supply
    file_matches = match.(r".*/lgbr-.*-power-supply-position.csv", cea_paths)
    file_paths = [m.match for m in file_matches if m != nothing]
    peak_paths = [string(f) for f in file_paths if occursin("peak", f)]
    supply_paths = [string(f) for f in file_paths if f ∉ peak_paths]

    cea_supply_dfs = CSV.read.(supply_paths, DataFrame)
    cea_powersupply_df = reduce(vcat, cea_supply_dfs)

    # Join the two sources:
    powersupply_df = vcat(powersupply_df, cea_powersupply_df)

    # ============================================================== #
    # 2. Do some basic cleaning:
    # ---------------------------

    # Include only the relevant years and format the state variable:
    powersupply_df = @chain powersupply_df begin
        @rsubset(_, :year > 1997 && :year < 2016) # earliest year of interest is 1997, latest year in ASI is 2015-16.
        @rtransform _ :state = String(:state) # force type
        @rtransform _ :state = strip(:state) # fix spaces on either side
    end

    # Names are sloppily recorded in both the original sources (not the same across years)
    # and in the transcription of the PDFs. In addition some states changes names across
    # years. I first fix this (see the fix-states code in the src folder) and remove
    # regional groupings.
    powersupply_df = @chain powersupply_df begin
        @rtransform _ :state = fix_state(:state)
        # Remove "region" units:
        @rsubset _ :state ∉ ["All India", "Western Region", "Eastern Region", "Southern Region",
                             "Northern Region", "North-Eastern Region"]
    end

    # Some of the values in the original data has three ',' to denote large number.
    # They are used unusually, however: the CEA uses "40,000" to denote
    # fourty-thousands but also "1,40,000" to denote one hundred and forty thousands.
    # This screws up the column typing.
    function fix_numeric_types(val)
        val = replace(val, "," => "")
        return parse(Float64, val)
    end

    powersupply_df = @chain powersupply_df begin
        @rtransform :requirement_mu = string(:requirement_mu) # force everything to be a string
        @rtransform :availability_mu = string(:availability_mu)
        @rtransform :requirement_mu = fix_numeric_types(:requirement_mu) # parse the string into a number
        @rtransform :availability_mu = fix_numeric_types(:availability_mu)
    end

    # ============================================================== #
    # 3. Calculate supply shortages and finish up:
    # ---------------------------------------------

    # Shortages are measured as the percentage of demand that is unmet:
    # That is: (Requirements - Availability) / Requirement. This means
    # that the number is positve when there is a lack of energy and is
    # negative when there is plenty energy.

    @rtransform!(powersupply_df, :supply_shortage = (:requirement_mu - :availability_mu) / :requirement_mu)

    return powersupply_df
end

# ============================================================== #
# Apply functions and save cleaned data:
# ---------------------------------------

allcott_et_al_supply_path = datadir("external", "power-supply-position", "from-allcott-et-al", "EnergyRequirement.csv")
allcott_et_al_supply_2003_path = datadir("external", "power-supply-position", "from-allcott-et-al", "EnergyRequirement.csv")
cea_paths = readdir(datadir("external", "power-supply-position", "from-cea", "csv"), join=true)

powersupply_df = clean_powersupply(allcott_et_al_supply_path, allcott_et_al_supply_2003_path, cea_paths)
Arrow.write(
    datadir("processed", "power-data", "indian-power-supply.arrow"),
    powersupply_df
)


    # Check for outlier valuies:
    # mean_supply_df = @chain powersupply_df begin
    #     groupby(_, :state)
    #     @combine _ begin
    #         :mean_requirement = mean(:requirement_mu)
    #         :sd_requirement = std(:requirement_mu)
    #         :mean_availability = mean(:availability_mu)
    #         :sd_availability = std(:availability_mu)
    #     end
    # end

    # # Add
    # outlier_df = @chain powersupply_df begin
    #     leftjoin(_, mean_supply_df, on=:state)
    #     @rtransform _ :z_req = abs((:requirement_mu - :mean_requirement) / :sd_requirement)
    #     @rtransform _ :z_avail = abs((:availability_mu - :mean_availability) / :sd_availability)
    #     sort(_, :z_req)
    #     @select(_, $(Not([:sd_requirement, :mean_requirement, :sd_availability, :mean_availability])))
    # end
