using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow

"Remove non-speficic product codes (like totals) and other suspect observations (like sales but no revenue)."
function remove_non_products(j_df::DataFrame)
    # Remove all products that have no qty sold:
    j_df = @subset j_df :qty_sold .> 0

    # In 2010, the product classification scheme changes from ASICC to NPCMS.
    # To filter out non-products and non-specific products (and to convert to
    # HS96 in a later piece of code) I assign the classification scheme in a
    # variable.
    npcms_years = 2010:2015
    asicc_years = 2000:2009

    @rtransform! j_df begin
        :code_scheme = :april_year ∈ npcms_years ? "npcms" :
            :april_year ∈ asicc_years ? "asicc" :
            missing
    end

    # Remove one observation with "year"  == 0.
    j_df = @rsubset j_df :year != 0


    # Remove non-products and rows that tally totals and sub-totals (as opposed
    # to specic products):
    # NPCMS:
    # Other products/by-products: 9921100, Total: 9995000
    # Products: sno = 1-10 f

    # ASICC:
    # Other Products/ By-Products: 99211, Total: 99950
    # Products: sno = 1-10.
    # Remove non-specific products (totals)
    j_df = @rsubset(j_df, (:code_scheme == "npcms" && :item_code ∉ ["9921100", "9995000"] && :sno ∈ 1:10) ||
        (:code_scheme == "asicc" && :item_code ∉ ["99211", "99950"] && :sno ∈ 1:10))
    # Remove products that are sold, but doesn't have a value listed.
    j_df = @rsubset(j_df, :ex_factory_val > 0 && :gross_sale_val > 0)

    return j_df
end

# ---------------------------------------------------------------------------- #
# Apply functions to clean factory outputs:
block_j_df = Arrow.Table(datadir("temp", "formatted-blocks", "block-J-all-years.arrow")) |> DataFrame
factory_outputs_df = remove_non_products(block_j_df)
Arrow.write(
    datadir("processed", "ASI", "factory_outputs.arrow"),
    factory_outputs_df
)
