using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow

"""
Get a dataframe with local inputs, including a variable indicating the share that a specific
input (a product) constitutes of the value of total inputs used by the factory in the given
year.
"""
function get_local_inputs(h_df::DataFrame)
    # ASICC YEARS:
    # 00-01, 01-02, 02-03: sno: 1:5,
    # 03-04, 04-05, 05-06, 06-07, 07-08, 08-09, 09-10: sno: 1:10

    # Not in:
    # 99201 (Other basic items)
    # 99901 (Total basic items)
    # 99203 (Non-basic Chemicals)
    # 99908 (Packing items)
    # 99904 (Electricity own generated)
    # 99905 (Electricity purchased and consumed)
    # 99906 (Petrol, Diesel, Oil, Lubricants Consumed)
    # 99907 (Coal consumed)
    # 99909 (Gas consumed) (only for 08-09 and forward)
    # 99204 (Other fuel consumed)
    # 99220 (Consumable store)
    # 99920 (Total non-basic items)
    # 99930 (Total inputs)

    asicc_non_products = [
        "99201", # (Other basic items)
        "99901", # (Total basic items)
        "99203", # (Non-basic Chemicals)
        "99908", # (Packing items)
        "99904", # (Electricity own generated)
        "99905", # (Electricity purchased and consumed)
        "99906", # (Petrol, Diesel, Oil, Lubricants Consumed)
        "99907", # (Coal consumed)
        "99909", # (Gas consumed) (only for 08-09 and forward)
        "99204", # (Other fuel consumed)
        "99220", # (Consumable store)
        "99920", # (Total non-basic items)
        "99930" # (Total inputs)
    ]

    # NPCMS YEARS
    # 10-11, 11-12, 12-13, 13-14, 14-15, 15-16: sno = 1-10
    # Not in:
    # 9920100 (Other basic items)
    # 9990100 (Total basic items)
    # 9920300 (Non-basic Chemicals)
    # 9990800 (Packing items)
    # 9990400 (Electricity own generated)
    # 9990500 (Electricity purchased and consumed)
    # 9990600 (Petrol, Diesel, Oil, Lubricants Consumed)
    # 9990700 (Coal consumed)
    # 9990900 (Gas consumed) (only for 08-09 and forward)
    # 9920400 (Other fuel consumed)
    # 9922000 (Consumable store)
    # 9992000 (Total non-basic items)
    # 9993000 (Total inputs)
    # 9999999 (Unmet electricity demand)

    npcms_non_products = [
        "9920100", # (Other basic items)
        "9990100", # (Total basic items)
        "9920300", # (Non-basic Chemicals)
        "9990800", # (Packing items)
        "9990400", # (Electricity own generated)
        "9990500", # (Electricity purchased and consumed)
        "9990600", # (Petrol, Diesel, Oil, Lubricants Consumed)
        "9990700", # (Coal consumed)
        "9990900", # (Gas consumed) (only for 08-09 and forward)
        "9920400", # (Other fuel consumed)
        "9922000", # (Consumable store)
        "9992000", # (Total non-basic items)
        "9993000", # (Total inputs)
        "9999999" # (Unmet electricity demand)
    ]

    # The local_inputs_df is used to measure how important each individual product
    # is to the production of the factory. I therefor exclude any non-specific products
    local_inputs_df = @rsubset h_df :april_year ∈ 2000:2002 && :sno ∈ 1:5 && :item_code ∉ asicc_non_products ||
        :april_year ∈ 2003:2009 && :sno ∈ 1:10 && :item_code ∉ asicc_non_products ||
        :april_year ∈ 2010:2015 && :sno ∉ 1:10 && :item_code ∉ npcms_non_products

    # The total_inputs_df is used to measure the total use of inputs each
    # factory uses. I therefor only want to keep observations of totals.
    total_inputs_df = @chain h_df begin
        @rsubset _ :april_year ∈ 2000:2002 && :sno == 17 && :item_code == "99930" ||
            :april_year ∈ 2003:2007 && :sno == 22 && :item_code == "99930" ||
            :april_year ∈ 2008:2009 && :sno == 23 && :item_code == "99930" ||
            :april_year ∈ 2010:2015 && :sno == 23 && :item_code == "9993000"
        select(_, :april_year, :march_year, :factory_id, :purchase_val => :total_inputs_val )
    end

    # Get all the factories that record more than one total inputs (~1 factories).
    inputs_recording_df = @chain total_inputs_df begin
        groupby(_, [:april_year, :factory_id])
        combine(_, nrow => :count)
        @subset :count .!= 1
    end

    # Remove those factories from the total_inputs dataframe:
    total_inputs_df = antijoin(total_inputs_df,
                               inputs_recording_df,
                               on = [:april_year, :factory_id])

    # I now get the the share of total inputs that each input in a year represents
    # for the given factory:
    local_inputs_df = @chain local_inputs_df begin
        leftjoin(_, total_inputs_df, on = [:april_year, :march_year, :factory_id])
        @transform _ :share_of_total_input_value = :purchase_val ./ :total_inputs_val
        @rtransform _ :code_scheme = :april_year ∈ 2000:2009 ? "asicc" :
            :april_year ∈ 2010:2015 ? "npcms" :
            missing
    end

    return local_inputs_df
end

# ---------------------------------------------------------------------------- #
# Apply functions to clean the local factory inputs:
block_h_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-H-all-years.arrow")) |> DataFrame
local_inputs_df = get_local_inputs(block_h_df)
Arrow.write(
    datadir("processed", "local-factory-inputs.arrow"),
    block_h_df
)
