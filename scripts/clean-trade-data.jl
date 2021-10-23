using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow


function clean_export_data(
    exports_raw::DataFrame,
    pop_df::DataFrame;
    reference_year = 2005,
    min_pop = 1_000_000,
    min_total_export = 1_000_000_000,
    min_year = 2000,
    max_year = 2016,
    unreliable_countries = ["IRQ", "AFG", "TCD"],
    removed_products = [
        "9999", # unspecified products
        "XXXX", # unaccounted for
        "financial", # financial services
        "travel", # travel services
        "transport", # transport services
        "ict", # information technology services
        "2527", # falls to zero trade during the sample
        "1403", # same as above
        "9704" # same as above (postal stamps)
    ],
    only_services = ["BWA", "NAM", "SWZ"]
    )

    exports_df = @chain exports_raw begin
        @rtransform _ begin
            :countrycode = uppercase(:origin)
            :export_value = :export_val == "NULL" ? 0.0 : parse(Float64, :export_val)
            :year = parse(Int64, :year)
        end
        rename(_, :hs96 => :hs_product_code)
        @select(_, :year, :countrycode, :hs_product_code, :export_value)
    end

    # Apply filters:
    # I apply five filters on the export observations:
    # 1) The population in the country must be above 1 mio inhabitants in the
    # reference year.
    # 2) The total exports must be above 1 billion USD in the reference year.
    # 3) Afghanistan, Iraq, and Chad is removed due to bad reliability.
    # 4) Botswana, Swaziland, and Aamibia is removed because for most of the
    # years in the sample, they have only observations on services (which I exclude).
    # 5) Products must be A) not services, B) not go to 0 globally during the period.

    # Filter 1:
    pop_above = @chain pop_df begin
        @rsubset(_, :year == reference_year && :population >= min_pop)
        _.countrycode
        Set(_)
    end

    # Filter 2:
    export_above = @chain exports_df begin
        groupby(_, [:countrycode, :year])
        @combine(_, :total_exports = sum(:export_value))
        @rsubset(_, :year == reference_year && :total_exports >= min_total_export)
        _.countrycode
        Set(_)
    end

    # Apply filters:
    exports_df = @chain exports_df begin
        @rsubset :countrycode ∈ pop_above
        @rsubset :countrycode ∈ export_above
    @rsubset :countrycode ∉ unreliable_countries
        @rsubset :hs_product_code ∉ removed_products
        @rsubset :hs_product_code ∉ only_services
        @rsubset :year ∈ min_year:max_year
    end

    # Get countries present across all years:
    # (disqualifies Serbia - only 13 years)
    countries_in_all_years = @chain exports_df begin
        groupby(_, [:countrycode])
        @combine _ begin
            :n_years = collect(Set(:year)) |> length
        end
        @subset _ :n_years .== maximum(:n_years)
        _.countrycode
        Set(_)
    end

    # Get products present across all years:
    # (~4 products are not)
    products_in_all_years = @chain exports_df begin
        groupby(_, [:hs_product_code])
        @combine _ begin
            :n_years = collect(Set(:year)) |> length
        end
        @subset _ :n_years .== maximum(:n_years)
        _.hs_product_code
        Set(_)
    end

    # Keep only countries and products in all years:
    exports_df = @rsubset(exports_df,
    :countrycode ∈ countries_in_all_years,
                          :hs_product_code ∈ products_in_all_years)

    # Widening export_df forces missing values in the country-product combinations
    # not in the dataframe.
    exports_wide = unstack(exports_df,
    [:countrycode, :year], :hs_product_code, :export_value,
    allowmissing=true)

    exports_df = @chain exports_wide begin
        stack(_, Not([:countrycode, :year]),
              variable_name = :hs_product_code, value_name = :export_value)
        # Set those missing values I forced out (above) to 0
        @rtransform _ :export_value = ismissing(:export_value) ? 0 : :export_value
    end

    # Make sure that there is only one observation for each country-year-product row
    obs_counts = @chain exports_df begin
        groupby(_, [:year, :countrycode, :hs_product_code])
        combine(_, nrow => :count)
    end

    # Make sure that there is an observation for all possible country-year-product combinations
    n_combinations = (exports_df.year |> unique |> length) * (exports_df.hs_product_code |> unique |> length) * (exports_df.countrycode |> unique |> length)

    @assert all(obs_counts.count .== 1)
    @assert n_combinations == nrow(exports_df)

    return exports_df
end

# ---------------------------------------------------------------------------- #
# Apply functions to clean the exports data:
raw_export_path = datadir("external", "international-trade", "year_origin_hs96_4.tsv")
exports_raw = CSV.read(raw_export_path, DataFrame, types = String)
pop_df = Arrow.Table(datadir("processed", "international-population.arrow")) |> DataFrame
exports_df = clean_export_data(exports_raw, pop_df)
Arrow.write(
    datadir("processed", "ASI", "international-exports.arrow"),
    exports_df
    )
