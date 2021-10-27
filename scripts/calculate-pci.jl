using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow
using LinearAlgebra
using Statistics


function get_complexity(Mcp::Matrix)
    Kc0 = sum(Mcp, dims=2) # diversity, n-countries by 1 matrix
    Kp0 = sum(Mcp, dims=1) # ubuiquity, 1 by n-products

    # Grab the eigenvector associated with the next-largest
    # eigen-value:
    Mpp = (Mcp ./ Kp0)' * (Mcp ./ Kc0)
    Q_vec = Real.(eigen(Mpp).vectors[:, end-1])


    # Now we can insert Q_vec (Kp) into the equation for K_vec (Kc)
    K_vec = (1 ./ Kc0) .* (Mcp * Q_vec)

    # Standardize to PCI and ECI
    PCI = (Q_vec .- mean(Q_vec)) ./ std(Q_vec)
    ECI = (K_vec .- mean(K_vec)) ./ std(K_vec)
    return ECI, PCI
end


function complexity_helper(comparative_advantage::DataFrame)
    # Make sure we only have columns we need:
    select!(comparative_advantage, :countrycode, :hs_product_code, :rca)
    # Make dataframe wide --products in column names:
    rca_wide = unstack(rca15, :countrycode, :hs_product_code, :rca, allowmissing=true)
    # Save countries for later:
    countries = rca_wide.countrycode
    # Remove countrycode column:
    select!(rca_wide, Not(:countrycode))
    # Save product names for later:
    products = rca_wide |> names
    # Get Mcp matrix to calculate complexity from:
    Mcp = Matrix(rca_wide)

    # Calculate ECI and PCI:
    ECI, PCI = get_complexity(Mcp)

    # Turn into dataframes and add country- and product names.
    pci_df = DataFrame(PCI = PCI, hs_product_codes = products)
    eci_df = DataFrame(ECI = ECI[:, 1], countrycodes = countries)

    # Get sign and adjust based on very complex country:
    jpn_eci = @rsubset(eci_df, :countrycodes == "JPN").ECI |> only
    eigensign = jpn_eci < 0 ? -1 : 1
    eci_df.PCI = eci_df.ECI .* sign
    pci_df.PCI = pci_df.PCI .* sign

    return eci_df, pci_df
end

# ================================================================== #
# Apply functions and calculate PCI, ECI based on RCA and RPCA:
# ----------------------------------------------------------- #

rca_df = Arrow.Table(datadir("processed", "international-trade", "rca.arrow")) |> DataFrame
rpca_df = Arrow.Table(datadir("processed", "international-trade", "rpca.arrow")) |> DataFrame

# Binarize:
@rtransform!(rca_df, :rca = :export_rca >= 1 ? 1 : 0)
@rtransform!(rpca_df, :rca = :export_rpca >= 1 ? 1 : 0)

# Get complexity for each year:
rca_complexity = [complexity_helper(@subset(rca_df, :year .== year)) for year in rca_df.year |> unique]
rpca_complexity = [complexity_helper(@subset(rpca_df, :year .== year)) for year in rpca_df.year |> unique]

# Write files
rca_ecis = [e[1] for e in rca_complexity]
rca_pcis = [p[2] for p in rca_complexity]
rpca_ecis = [e[1] for e in rpca_complexity]
rpca_pcis = [p[2] for p in rpca_complexity]

Arrow.write(
    datadir("processed", "complexity", "rca_eci.arrow"),
    reduce(vcat, rca_ecis)
)

Arrow.write(
    datadir("processed", "complexity", "rca_pci.arrow"),
    reduce(vcat, rca_pcis)
)

Arrow.write(
    datadir("processed", "complexity", "rpca_eci.arrow"),
    reduce(vcat, rpca_ecis)
)

Arrow.write(
    datadir("processed", "complexity", "rpca_pci.arrow"),
    reduce(vcat, rpca_pcis)
)
