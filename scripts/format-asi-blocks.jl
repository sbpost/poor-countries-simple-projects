using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using CSV

# Grab all files in that were collected into blocks
block_files = readdir(datadir("temp"))
block_paths = joinpath.(datadir("temp"), block_files)

BLOCKS = [:A, :B, :C, :D, :E, :H, :I, :J]

# Select the variables we are keeping:
# NOTE: F and G is not listed, because they won't be used in the analysis
# (F = "Other expenses", G = "Other outputs/receipts")
variables = Dict(
    :A => (year = Int64,
           factory_id = String,
           block = String,
           scheme = Int64,
           nic5code = String,
           rural_urban = Int64,
           no_units = Int64,
           unit_status = Int64,
           production_cost = Float64,
           multiplier = Float64),
    :B => (year = Int64,
           factory_id = String,
           block = String,
           type_organisation = String,
           initial_production = Int64,
           multiplier= Float64),
    :C => (year = Int64,
           factory_id = String,
           block = String,
           sno = Int64,
           opening_gross = Float64,
           closing_gross = Float64,
           opening_net = Float64,
           closing_net = Float64,
           multiplier = Float64),
    :D => (year = Int64,
           factory_id = String,
           block = String,
           sno = Int64,
           w_cap_opening = Float64,
           w_cap_closing = Float64,
           multiplier = Float64),
    :E => (year = Int64,
           factory_id = String,
           block = String,
           sno = Int64,
           avg_person_worked = Float64,
           wages = Float64,
           multiplier = Float64),
    :H =>  (year = Int64,
            factory_id = String,
            block = String,
            sno = Int64,
            qty_unit = Float64,
            qty_consumed = Float64,
            item_code = Float64,
            purchase_val = Float64,
            multiplier = Float64),
    :I => (year = Int64,
           factory_id = String,
           block = String,
           sno = Int64,
           qty_unit = Float64,
           qty_consumed = Float64,
           item_code = Float64,
           purchase_val = Float64,
           multiplier = Float64),
    :J => (year = Int64,
           factory_id = String,
           block = String,
           sno = Int64,
           item_code = Float64,
           qty_unit = Float64,
           qty_sold = Float64,
           ex_factory_val = Float64,
           gross_sale_val = Float64,
           multiplier = Float64)
)

"Clean individual survey blocks (select variables and fix variable types)."
function clean_block(block_df::DataFrame, colmeta::NamedTuple)
    colnames = collect(keys(colmeta))
    # Grab the variables we want:
    block_data = @select block_df $colnames
    # Fix the variable types:
    for col in keys(colmeta)
        column_vector = block_data[:, col]
        if eltype(column_vector) != colmeta[col]
            block_data[!, col] = parse.(colmeta[col], column_vector)
        end
    end

    # Create a new year variable:
    # currently, year refers to the "March"-year of the financial
    # year from April to March. The new variable refers to the April
    # year.
    # @rtransform! block_data begin
    #     :april_year = :year-1
    #     :march_year = :year
    # end
    return block_data
end


# APPLY
for letter in BLOCKS
    index = occursin.("block-$(string(letter))", block_paths)
    block_df = Arrow.Table(block_paths[index][1]) |> DataFrame
    block_df = clean_block(block_df, variables[letter])
end
