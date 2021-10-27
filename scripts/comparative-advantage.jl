using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow

# NOTE: all this could be done faster by matrix algebra.
function rca(exports_df::DataFrame)
    # Calculate RCA:
    # RCA = (country exports in product p / total country exports) / (world exports in product p / total world exports)

    # Get total world export for a product for each year:
    world_product_export_df = @chain exports_df begin
        groupby(_, [:year, :hs_product_code])
        @combine _ begin
            :global_product_export_value = sum(:export_value)
        end
    end

    # Get total world export for each year:
    world_total_export_df = @chain exports_df begin
        groupby(_, [:year])
        @combine _ begin
            :global_total_export_value = sum(:export_value)
        end
    end

    # Get total country exports:
    country_total_exports_df = @chain exports_df begin
        groupby(_, [:countrycode, :year])
        @combine _ begin
            :country_total_export_value = sum(:export_value)
        end
    end

    # Add the values to the country-product-year observations. The rest is simple division:
    rca_df = @chain exports_df begin
        leftjoin(_, country_total_exports_df, on=[:countrycode, :year])
        leftjoin(_, world_product_export_df, on=[:hs_product_code, :year])
        leftjoin(_, world_total_export_df, on=:year)
        @rtransform _ :export_rca = (:export_value / :country_total_export_value) / (:global_product_export_value / :global_total_export_value)
        @select(_, :countrycode, :year, :hs_product_code, :export_value, :export_rca)
    end

    return rca_df
end

"""
Calculate revealed per capita advantage (RPCA).
 RPCA for country c in product p is defined as:
(country exports in product p / country population) / (world exports in product p / global population)
"""
function rpca(exports_df::DataFrame, pop_df::DataFrame)
    # Get total world export for a product for each year:
    world_product_export_df = @chain exports_df begin
        groupby(_, [:year, :hs_product_code])
        @combine _ begin
            :global_product_export_value = sum(:export_value)
        end
    end

    # Get global population df:
    global_pop_df = @combine(groupby(pop_df, :year), :global_population = sum(:population))

    # Calculate RPCA:
    # RPCA = (country exports in product p / country population) / (world exports in product p / global population)
    rpca_df = @chain exports_df begin
        leftjoin(_, pop_df, on=[:countrycode, :year])
        leftjoin(_, global_pop_df, on=[:year])
        leftjoin(_, world_product_export_df, on=[:hs_product_code, :year])
        @rtransform _ :export_rpca = (:export_value / :population) / (:global_product_export_value / :global_population)
        @select(_, :countrycode, :year, :hs_product_code, :export_value, :export_rpca)
    end

    return rpca_df
end


# ---------------------------------------------------------------------------- #
# Calculate RCA and RPCA and write to file:
pop_df = Arrow.Table(datadir("processed", "international-population", "international-population.arrow")) |> DataFrame
exports_df = Arrow.Table(datadir("processed", "international-trade", "international-exports.arrow")) |> DataFrame
rca_df = rca(exports_df)
rpca_df = rpca(exports_df, pop_df)

Arrow.write(
    datadir("processed", "international-trade", "rca.arrow"),
    rca_df
)
Arrow.write(
    datadir("processed", "international-trade", "rpca.arrow"),
    rpca_df
)
