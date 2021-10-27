using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using DataFramesMeta
using Chain
using Arrow
using CSV
using Statistics

function get_asicc_to_npcms_table(asicc_to_npcms_raw::DataFrame)
    # This functions cleans the raw (digitally converted) concordance table
    # between ASICC product codes and NPCMS product codes. First some cleaning
    # is done, second the NPCMS-matches are converted from the 7-digit to the
    # 5-digit level. The codes will be changed to 5-digit at the CPC->HS step
    # either way, and it reduces the number of partial matches substantially (
    # to 177).

    # 1. Clean the raw concordance table: -------------------------- #
    # The raw concordance table has been electronically converted from a PDF supplied
    # by the official documentation. This means that there are some artifacts from
    # the conversion process. These are removed first:
    rename!(asicc_to_npcms_raw,
            "ASICC CODE" => :asicc,
            "ITEM DESCRIPTION" => :description,
            "NPCMS-2011" => :npcms)
    #
    # Remove all the rows introduced when the PDF pages change:
    asicc_to_npcms = @rsubset asicc_to_npcms_raw !(occursin("ASICC CODE", :asicc))

    # There are some ASICC categories that does not exist in NPCMS. They are
    # labelled "Invalid".
    asicc_to_npcms = @rsubset asicc_to_npcms !(occursin("Invalid", :npcms))


    # Add a dummy variable that indicates if a product is partly matched:
    # partly matched products have a "(p)" after the code:
    asicc_to_npcms =
        @transform asicc_to_npcms begin
            :partly_matched = occursin.("p", :npcms)
        end

    asicc_to_npcms = @chain asicc_to_npcms begin
        # Split at 'p' or 'P'
        @rtransform _ :npcms = split(:npcms, r"p|P")
        # Expand the split observations into mulitple rows:
        flatten(_, :npcms)
        # Remove the leading/trailing whitespace, + and parens
        @rtransform _ :npcms = replace(:npcms, r"[\(\)\)+\s+]" => "")
        # Since some the codes have (p) at the end, some rows have been expanded empty
        # remove them:
        @rsubset _ length(:npcms) != 0
        # Finally: during the digitalisation process, some of the 7-digit
        # codes that start with 0 have been turned into 6-digit codes.
        @rtransform _ :npcms = length(:npcms) == 6 ? "0" * :npcms : :npcms
    end

    # One NPCMS product is only party matched, but has no "p" in the code.
    # I split this code manually.
    transformer_codes = [Dict(:asicc => "77236",
                              :description => "TRANSFORMER" ,
                              :npcms => code,
                              :partly_matched => true) for code in ["4612101",
                                                                    "4612199"]]
    asicc_to_npcms = @chain asicc_to_npcms begin
        # remove old row
        @rsubset _ :description != "TRANSFORMER"
        # add two new rows
        vcat(_, DataFrame(transformer_codes))
    end

    # Finally, two products have one of their matched codes (in the
    # npcms column) that are too long. This is from the original data.
    # I remove them.
    asicc_to_npcms = @rsubset asicc_to_npcms length(:npcms) == 7

    # 2. Convert to five-digit NPCMS matches: ---------------------- #
    # The main purpose of the NPCMS conversion is to convert to CPC-2 -> HS07.
    # NPCMS matches perfectly to CPC-2 at the 5-digit level. It is also much
    # easier to convert between ASICC and NPCMS at the 5-digit (rather than 7)
    # level of NPCMS. I therefor remove the last two (India-specific) digits.
    asicc_to_npcms_5d = @chain asicc_to_npcms begin
        @rtransform :npcms_5d = :npcms[1:5]
        @select(_, :asicc, :description, :npcms_5d)
        unique(_)
    end

    # Return:
    return asicc_to_npcms_5d
end

function separate_full_and_partial_asicc_matches(asicc_to_npcms_5d::DataFrame)
    partly_matched = @chain asicc_to_npcms_5d begin
        # ID the ASICC codes that have more than one NPCMS code matching:
        # (the other way doesn't matter since we match ASICC -> NPCMS)
        groupby(_, :asicc)
        @combine(_, :n_matches = unique(:npcms_5d) |> length)
        @rtransform _ :partly_matched = :n_matches > 1
        @subset _ :partly_matched .== true
    end

    fully_matched = @chain asicc_to_npcms_5d begin
        antijoin(_, asicc_to_npcms_5d_partly_matched,
                 on = :asicc)
    end

    return (partly_matched, fully_matched)
end



# Convert ASICC years to NPCMS:
asicc_to_npcms_raw = CSV.read(
    datadir("external", "conversion-tables", "asicc-to-npcms11-raw.csv"),
    DataFrame)

asicc_to_npcms_5d = get_asicc_to_npcms_table(asicc_to_npcms_raw)
asicc_to_npcms_5d_partially_matched, asicc_to_npcms_5d_fully_matched = separate_full_and_partial_asicc_matches(asicc_to_npcms_5d)

outputs_df = Arrow.Table(datadir("processed", "ASI", "factory_outputs.arrow")) |> DataFrame

# Add 1-1 matched codes:
outputs_df = @chain outputs_df begin
    # Add 5-digit NPCMS to ASICC codes for 1-1 matches:
    leftjoin(_, @select(asicc_to_npcms_5d_fully_matched, $(Not(:description))), on = :item_code => :asicc)
    # Add 5-digit versions of the products in the NPCMS years:
    @rtransform(_, :npcms_5d = :code_scheme == "npcms" ? :item_code[1:5] : :npcms_5d)
end

@rsubset(outputs_df, ismissing(:npcms_5d)).item_code |> Set


# TODO NOTE ISSUE!!! The ASICC codes in the official conversion set does not
# contain all the ASICC codes in the ASI data. ALSO: the reference set does not
# contain all ASICC codes in some other references. HOWEVER: it might be due to
# services, and other non-products.

asi_asicc_codes = @rsubset(outputs_df, :code_scheme == "asicc").item_code |> Set
ref_asicc_codes = asicc_to_npcms_5d.asicc |> Set

ref2 = CSV.read("/home/sbp/sbp-related/academicsbaby/poor-countries-simple-products/poor-countries-simple-products/data/external/asi/asi-2000-2009/SUPPORTING_DOCUMENTS_0405/asicc05.csv",
         DataFrame).asicc |> Set |> collect


setdiff(strip.(ref2), asi_asicc_codes)
setdiff(
    strip.(ref2)
    ,
    ref_asicc_codes
)
setdiff(ref_asicc_codes, asi_asicc_codes)

# ================================================================== #
# THIS SECTION DEALS WITH MAPPING THE PARTIAL MATCHES BETWEEN ASICC AND
# NPCMS


leftjoin(outputs_df, asicc_to_npcms_5d_fully_matched, on = :item_code => :asicc)



partcodes = asicc_to_npcms_5d_partly_matched.asicc |> Set
boundary_matching_df = @chain outputs_df begin
    @select(_, :year, :factory_id, :item_code, :code_scheme)
    # reduce to partly matched asicc codes and npcms codes
    @rsubset(_, (:code_scheme == "asicc" && :item_code ∈ partcodes) || :code_scheme == "npcms")
    # reduce to partly matched asicc codes and the first two npcms years
    @rsubset(_, :code_scheme == "asicc" || (:code_scheme == "npcms" && :year ∈ 2011:2012))
    # how many of the factories making partly matched products are observed both before
    # and after the change in codes
    groupby(_, :factory_id)
    @transform _ begin
        :in_npcms_years = (2011 ∈ :year) || (2012 ∈ :year)
        :in_asicc_years = any(in.(collect(2000:2010), Ref(:year)))
    end
    # keep only observations that are in the first two npcms years and
    # has a partly matched item code.
    @rsubset(_, :in_npcms_years == true && :in_asicc_years == true)
end
# Now boundary_matching_df has observations of products that have partial
# matches in the ASICC years but from factories also observed in the first two NPCMS years.
# This means that if a factory produces a partial match in ASICC years, and also produces a
# product in NPCMS years that is within in the possible matches in the concordance table,
# we can assume that the ASICC-years code maps to the NPCMS code.

@rtransform!(boundary_matching_df, :npcms_5d = :code_scheme == "npcms" ? :item_code[1:5] : missing)

# For each observation in boundary_matching_df ASICC years, I need to check if the
# any of the products produced by the same factory in NPCMS years fall within the possible matches
# in the concordance tables:
match_dicts = []
for row in eachrow(boundary_matching_df)
    if row.code_scheme == "asicc"
        # get the products that the factory produces in the npcms years:
        npcms_products = @rsubset(boundary_matching_df,
                                 :factory_id == row.factory_id,
                                 :code_scheme == "npcms")

        # of those products, check how many are in the set of the
        # asicc products partial matches:
        possible_npcms_codes = (@rsubset(asicc_to_npcms_5d_partly_codes,
                                         :asicc == row.item_code)).npcms_5d |> Set

        potential_matches = [code for code in npcms_products.npcms_5d if code ∈ possible_npcms_codes]
                                 #in.(npcms_products.npcms_5d, Ref(possible_npcms_codes))
        push!(match_dicts, Dict(:factory_id => row.factory_id,
                                :year => row.year,
                                :asic_code => row.item_code,
                                :potential_match => potential_matches))
    end
end

# Dataframe with matches based on what the factories produces in the first NPCMS years
df = @chain DataFrame(match_dicts) begin
        @rtransform(_, :n_matches = length(:potential_match))
        @rtransform(_, :match = :n_matches == 1 ? only(:potential_match) : missing)
    end

# Another approach is to take a probability-based approach:


# ================================================================== #
# THIS SECTION DEALS WITH THE ISSUE OF SOME FACTORIES HAVING MULTIPLE ENTIRES IN YEAR-PRODUCT COMBINATIONS.
# The sale value is also very often different.

# This can happen in a legitimate way: if someone who fills out the survey differentiates
# between products on a lower level than ASICC, she might fill in two items with same code.
# There is no specific need to solve the issue, since products will be merged eventually
# after product concordances.
@chain outputs_df begin
    semijoin(_, multi_products_in_year, on = [:factory_id, :year, :item_code])
end

@rsubset(combine(groupby(outputs_df, [:factory_id, :year, :item_code]), nrow => :count), :count > 1)

multi_products_in_year = @chain outputs_df begin
    groupby(_, [:factory_id, :year, :item_code])
    combine(_, nrow => :count)
    @rsubset(_, :count > 1)
end

@chain outputs_df begin
    semijoin(_, multi_products_in_year, on = [:factory_id, :year, :item_code])
end


@chain outputs_df begin
    groupby(_, :year)
    combine(_, nrow => :count)
end

multi_products_in_year






@chain outputs_df begin
    @rsubset _ :code_scheme == "asicc"
    leftjoin(_, asicc_to_npcms_5d_fully_matched,
             on = :item_code => :asicc)
    @rsubset _ ismissing(:npcms_5d)
    groupby(_, :year)
    combine(_, nrow => :count)
end

@chain outputs_df begin
    @rsubset _ :code_scheme == "asicc"
    leftjoin(_, asicc_to_npcms_5d_fully_matched,
             on = :item_code => :asicc)
    @rsubset _ ismissing(:npcms_5d)
    groupby(_,  [:item_code, :year])
    combine(_, nrow => :count)
    sort(_, :count)
end


# Check whether the boundary observations change products:

@rsubset(asicc_to_npcms_5d, :asicc ∈ ["82189",
                                      "12968",
                                      "71202",
                                      "33689",
                                      "57104",
                                      "63428",
                                      "71112"])

last_asicc_year = 2010
first_npcms_year = 2011

factories_observed_in_boundary_years = @chain outputs_df begin
    groupby(_, :factory_id)
    @combine _ begin
        :in_asicc = any(:year .== last_asicc_year)
        :in_npcms = any(:year .== first_npcms_year)
    end
    @rsubset _ :in_asicc == true && :in_npcms == true
end

asicc_to_npcms_5d_partly_codes = @chain asicc_to_npcms_5d begin
    semijoin(_, asicc_to_npcms_5d_partly_matched, on=:asicc)
end

test_df = @chain outputs_df begin
    semijoin(_, factories_observed_in_boundary_years, on=:factory_id)
    @rtransform(_, :npcms_5d = :code_scheme == "npcms" ? :item_code[1:5] : missing)
    @select(_, :year, :factory_id, :item_code, :npcms_5d, :code_scheme)
    @rsubset(_, :year ∈ last_asicc_year:first_npcms_year)
    @rsubset(_, (:code_scheme == "asicc" && :item_code ∈ asicc_to_npcms_5d_partly_matched.asicc) || :code_scheme == "npcms")
end

# Two approaches: general:
# TODO: Get set of products that factories with one of the codes in the partly matched asicc codes have:
# That is, for each of the asicc codes that are partly matched, grab all the codes that factory produces in the first npcms year





matches = []
for row in eachrow(asicc_to_npcms_5d_partly_codes)
    asicc_code = row.asicc
    npcms_5d_codes = (@rsubset(test_df, :npcms_5d == row.npcms_5d)).npcms_5d |> unique
    push!(matches, (asicc = asicc_code, npcms = npcms_5d_codes))
end

# For each factory making a product in 2010 (last ASICC year) that is ambigously matched,
# find out what they are producing in 2011:


(@rsubset(test_df, :code_scheme == "asicc")).item_code |> unique

asicc_to_npcms_5d_partly_codes


df = reduce(vcat, rows)
@chain df begin
end
