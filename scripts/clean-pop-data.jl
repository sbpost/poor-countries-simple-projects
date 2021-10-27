using DrWatson
@quickactivate "poor-countries-simple-products"

"Clean population data from WDI."
function clean_pop_data(pop_raw::DataFrame)
    # Remove columns that shouldn't get stacked. `Column65` is a column that gets added
    # because of the input format.
    select!(pop_raw,
            Not(["Indicator Name", "Indicator Code", "Column65"]))

    # Rename columns I care about:
    rename!(pop_raw,
            "Country Name" => :country,
            "Country Code" => :countrycode)

    # Get into a tidy format:
    pop_df = stack(pop_raw,
                   Not([:country, :countrycode]),
                   variable_name = :year,
                   value_name = :population)

    # Fix variable types and remove missing observations (no population values for latest year)
    pop_df = @chain pop_df begin
        dropmissing(:population)
        @transform _ begin
            :year = parse.(Int, :year)
        end
    end

    return pop_df
end

# ---------------------------------------------------------------------------- #
# Apply functions to clean the population data:
pop_raw_path = datadir("external", "pop-international", "population_total.csv")
pop_raw = CSV.read(pop_raw_path, DataFrame, header = 5)
pop_df = clean_pop_data(pop_raw)
Arrow.write(
    datadir("processed", "international-population", "international-population.arrow"),
    pop_df
)
