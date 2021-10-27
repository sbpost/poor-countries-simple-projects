using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow
using CSV
using Statistics


# This script creates a "master list" of factory-year observations to include in
# the final sample. The final sample might still be reduced further in some
# analyses, but will not exceed the master list.

A_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-A-all-years.arrow")) |> DataFrame

# Remove factories that are not listed as "open"
open_factories = @subset(A_df, :unit_status .== 1)




# TODO Remove factories that are not manufacturing:
# NOTE requires industry-concordance.
B_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-B-all-years.arrow")) |> DataFrame

B_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-B-all-years.arrow")) |> DataFrame
b = Arrow.Table(datadir("temp", "raw-blocks", "B", "block-B-year-2005.arrow")) |> DataFrame
