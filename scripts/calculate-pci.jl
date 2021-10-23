using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow
using LinearAlgebra
using Statistics

rca_df = Arrow.Table(datadir("processed", "rca.arrow")) |> DataFrame
rpca_df = Arrow.Table(datadir("processed", "rpca.arrow")) |> DataFrame

rca_df
rpca_df

rca15 = @subset rca_df :year .== 2015

rca15 = @rtransform rca15 :rca = :export_rca >= 1 ? 1 : 0
select!(rca15, :countrycode, :hs_product_code, :rca)

rca_wide = unstack(rca15, :countrycode, :hs_product_code, :rca, allowmissing=true)

countries = rca_wide.countrycode
select!(rca_wide, Not(:countrycode))
rca_wide
products = rca_wide |> names
Mcp = Matrix(rca_wide)

Kc0 = sum(Mcp, dims=2) # diversity, n-countries by 1 matrix
Kp0 = sum(Mcp, dims=1) # ubuiquity, 1 by n-products
Mcc = (Mcp ./ Kc0) * (Mcp ./ Kp0)'
# Grab the eigenvector associated with the next-largest
# eigen-value (largets is just ones)
K_vec = eigen(Mcc).vectors[:, end-1]

# Standardize to ECI:
ECI = (K_vec .- mean(K_vec)) ./ std(K_vec) # standardize (Z)
eci_df = DataFrame(eci = ECI, countrycodes = cc)
sort(eci_df, :eci)

# PCI -> TODO something is off: rankings seems to be reversed.
Mpp = (Mcp ./ Kp0)' * (Mcp ./ Kc0)
Q_vec = Real.(eigen(Mpp).vectors[:, end-1])
PCI = (Q_vec .- mean(Q_vec)) ./ std(Q_vec) # standardize (Z)
pci_df = DataFrame(pci = PCI, hs_product_codes = products)
sort(pci_df, :pci)

using CSV
pci_harvard = CSV.read(datadir("external", "complexity", "from-harvard", "Product Complexity Rankings 1995 - 2019.csv"), DataFrame)
select!(pci_harvard, ["HS4 Code", "PCI 2015", "Product"])
rename!(pci_harvard, "HS4 Code" => :hs_product_codes, "PCI 2015" => :harvard_pci)

joined = leftjoin(pci_df, pci_harvard, on = :hs_product_codes)


sort(joined, :harvard_pci)
sort(joined, :pci)

dropmissing!(joined)

cor(joined.harvard_pci, joined.pci)
