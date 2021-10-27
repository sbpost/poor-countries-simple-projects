using DrWatson
@quickactivate "poor-countries-simple-products"

# Activate packages:
using Planner
using DataFrames
using DataFramesMeta
using Chain
using Arrow
using CSV

# Initialize plan
plan = startplanning()

# ========================================================================= #
# Get raw ASI data into dataframes (one per block-year):
# ---------------------------------------------------- #
# Create paths to temporary blocks that should be tracked:
temp_block_paths = String[]
for block in "ABCDEFGHIJ"
    block_folder = datadir("temp", "raw-blocks", "$block")
    for year in 2000:2015
        push!(
            temp_block_paths,
            joinpath(block_folder, "block-$(block)-year-$(year).arrow")
        )
    end
end

addtarget!(
    plan,
    temp_block_paths,
    [scriptsdir("read-asi-data.jl"), scriptsdir("asi-data-column-separation-dictionaries.jl")]
)
# ========================================================================= #
#  Reformat ASI block-years into one dataframe per block:
# ------------------------------------------------------ #
# Create paths to formatted blocks that should be tracked:
formatted_block_paths = [datadir("temp", "formatted-blocks", "block-$(letter)-all-years.arrow") for letter in "ABCDEHIJ"]

addtarget!(
    plan,
    formatted_block_paths,
    vcat(temp_block_paths, scriptsdir("format-asi-blocks.jl"))
)
# ========================================================================= #
# Clean international population data:
# ---------------------------------- #
addtarget!(
    plan,
    [datadir("processed", "international-population", "international-population.arrow")],
    [datadir("external", "pop-international", "population_total.csv"),
     scriptsdir("clean-pop-data.jl")]
)
# ========================================================================= #
# Clean international trade data:
# ----------------------------- #
addtarget!(
    plan,
    [datadir("processed", "international-trade", "international-exports.arrow")],
    [datadir("external", "international-trade", "year_origin_hs96_4.tsv"),
     scriptsdir("clean-trade-data.jl")]
)
# ========================================================================= #
# Calculate country comparative advantage:
# ---------------------------------------- #
# RPCA
addtarget!(
    plan,
    [datadir("processed", "international-exports", "rpca.arrow")],
    [datadir("processed", "international-exports", "international-exports.arrow"),
     datadir("processed", "international-population", "international-population.arrow"),
     scriptsdir("comparative-advantage.jl")]
)

# RCA
addtarget!(
    plan,
    [datadir("processed", "international-exports", "rca.arrow")],
    [datadir("processed", "international-exports", "international-exports.arrow"),
     scriptsdir("comparative-advantage.jl")]
)

# ========================================================================= #
# TODO Calculate Product Complexity Index:
# --------------------------------------- #
#
# ========================================================================= #
# Clean factory inputs:
# --------------------- #
addtarget!(
    plan,
    [datadir("processed", "ASI", "local-factory-inputs.arrow")],
    [datadir("temp", "formatted-blocks", "block-H-all-years.arrow"),
     scriptsdir("get-factory-inputs.jl")]
)

# ========================================================================= #
# Clean factory outputs:
# ---------------------------- #
addtarget!(
    plan,
    [datadir("processed", "ASI", "factory_outputs.arrow")],
    [datadir("temp", "formatted-blocks", "block-J-all-years.arrow"),
     scriptsdir("get-factory-outputs.jl")]
)

# ========================================================================= #
# TODO: Get factory complexity:
# ----------------------------- #
# ========================================================================= #
# TODO: Clean electricity shortage data:
# -------------------------------------- #
# ========================================================================= #
# TODO: Clean hydropower data:
# ---------------------------- #
# ========================================================================= #
# TODO: Clean WPI data:
# ---------------------------- #
# ========================================================================= #
# TODO: Create product concordance tables:
# ---------------------------------------- #
# ========================================================================= #
# TODO: Convert products to HS96 codes:
# ------------------------------------- #
# ========================================================================= #
# TODO: Clean RBI data:
# ---------------------------- #
# ========================================================================= #
# TODO:
# ---------------------------- #
# ========================================================================= #


runplan(plan)

plan.graph_data
edges(plan.G) |> collect
