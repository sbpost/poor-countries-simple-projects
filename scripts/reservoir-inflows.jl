using DrWatson
@quickactivate "poor-countries-simple-products"

using CSV
using Arrow
using DataFrames
using DataFramesMeta


cea_paths = readdir(
    datadir("external",
            "hydro-power",
            "reservoir-schemes-inflow-and-energy-generation",
            "from-cea",
            "csv",
            "tidy"),
    join = true
)

allcot_et_al_paths = readdir(
    datadir("external",
            "hydro-power",
            "reservoir-schemes-inflow-and-energy-generation",
            "from-allcott-et-al",
            "csv"),
    join = true
)


cea_df = @chain cea_paths begin
    CSV.read.(_, DataFrame)
    reduce(vcat, _, cols = :union)
    @select(_, $(Not(:region)))
end

allcott_et_al_df = @chain allcot_et_al_paths begin
    CSV.read.(_, DataFrame)
    reduce(vcat, _, cols = :union)
    rename!(_,
            "Year" => :year,
            "RESERVOIR SCHEME" => :reservoir_scheme,
            "INFLOWS (MCM)" => :inflows_mcm,
            "GENERATION (GWH)" => :generation_mu)
end

# Join data:
inflow_df = vcat(allcott_et_al_df, cea_df)

# Some reservoirs have uneven names across years. This dictionary fixes them:
reservoir_names_fix = Dict(
    "Ukai" => "UKAI",
    "N.J. Sagar" => "Nagarjuna Sagar",
    "RP Sagar" => "R.P.Sagar",
    "Sharavarhy & Jog" => "Sharavathy",
    "Sharavarhy, Jog & Gerusupa" => "Sharavathy",
    "Sabaragiri" => "Sabarigiri",
    "Rihand & Obra" => "Rihand",
    "Srisaliam RBPH+LBPH" => "Srisailam",
    "Kalinadi & Supa" => "Supa",
    "Madupetty" => "Madhupatty",
)

# Apply dictionary:
function fix_reservoir_names(val)
    val = strip(val)
    new_val = haskey(reservoir_names_fix, val) ? reservoir_names_fix[val] : val
    return String(new_val)
end

# Fix names:
inflow_df.new_reservoir_scheme = fix_reservoir_names.(inflow_df.reservoir_scheme)

# Check if all the reservoirs have uninterrupted series:
for name in inflow_df.new_reservoir_scheme |> unique
    years = @rsubset(inflow_df, :new_reservoir_scheme == name).year
    # get min, max year value:
    first_year = minimum(years)
    last_year = maximum(years)
    @assert setdiff(Set(first_year:last_year), Set(years)) |> length == 0
end


@chain inflow_df groupby(_, :new_reservoir_scheme) combine(_, nrow => :count) sort(_, :count)

Arrow.write(
    datadir("processed", "power-data", "reservoir-inflows-and-generation.arrow"),
    inflow_df
)
