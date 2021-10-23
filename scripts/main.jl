
# Get raw ASI data into dataframes (one per block-year)
include(scriptsdir("read-asi-data.jl"))
ASI_2000_2009_paths = grab_asi_filepaths(datadir("external", "asi", "asi-2000-2009"));
ASI_2010_2015_paths = grab_asi_filepaths(datadir("external", "asi", "asi-2010-2015"));
ASI_paths = organize_filepaths(vcat(ASI_2000_2009_paths, ASI_2010_2015_paths))
parse_asi_files(ASI_paths)

#  Reformat ASI block-years into one dataframe per block:
include(scriptsdir("read-asi-data.jl"))
block_files = readdir(datadir("temp"))
block_paths = joinpath.(datadir("temp"), block_files)

BLOCKS = [:A, :B, :C, :D, :E, :H, :I, :J]
for letter in BLOCKS
    @info "Cleaning and formatting block $letter."
    # Read blocks from file and join into one dataframe:
    block_df = @chain letter begin
        readdir(datadir("temp", "raw-blocks", "$(_)"), join=true) # grab paths to files
        Arrow.Table.(_) # read files
        DataFrame.(_) # turn into list of dataframes
        reduce(vcat, _, cols=:union) # concat the list into one dataframe
    end

    block_df = clean_block(block_df, variables[letter])
    # Write the cleaned block to file:
    Arrow.write(
        datadir("temp", "formatted-blocks", "block-$(letter)-all-years.arrow"),
        block_df
    )
end

# Clean international population data:
include(scriptsdir("clean-pop-data.jl"))
pop_raw_path = datadir("external", "pop-international", "population_total.csv")
pop_raw = CSV.read(pop_raw_path, DataFrame, header = 5)
pop_df = clean_pop_data(pop_raw)
Arrow.write(
    datadir("processed", "international-population.arrow"),
    pop_df
)

# Clean international trade data:
include(scriptsdir("clean-trade-data.jl"))
raw_export_path = datadir("external", "international-trade", "year_origin_hs96_4.tsv")
exports_raw = CSV.read(raw_export_path, DataFrame, types = String)
pop_df = Arrow.Table(datadir("processed", "international-population.arrow")) |> DataFrame
exports_df = clean_export_data(exports_raw, pop_df)
Arrow.write(
    datadir("processed", "international-exports.arrow"),
    exports_df
)

# TODO Calculate country comparative advantage:
# - RCA:
# - RPCA:

# TODO Calculate PCI:
