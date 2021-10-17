using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using CSV
using Arrow

# Also load in the dictionaries containing the strucutre of the panel data (.txt files)
include(scriptsdir("asi-data-column-separation-dictionaries.jl"))


# Get a list of ASI files covering data from 2000 to 2009 (inclusive)

# The directories supplied from the ASI is a bit messy. # TODO Describe what happens in script

"Recursively go into any folder in `parent_dir` and grab all files that end in '.TXT'."
function grab_asi_filepaths(parent_dir::String)
    asi_filepaths = []
    for (root, dirs, files) in walkdir(parent_dir)
        for file in files
            if occursin(".TXT", file)
                # joinpath(root...) adds the path to the file name
                push!(asi_filepaths, joinpath(root, file))
            end
        end
    end

    return asi_filepaths
end

"Organize ASI filepaths into a dictionaries and note the year and block that the data represents."
function organize_filepaths(filepaths)
    # Organize all filepaths into the correct block.
    block_dict = Dict()
    for path in filepaths
        # The block letter comes right before the year and the file ending.
        block_pattern = r"(\d+)|(\.TXT)"
        # Now last character is the block letter. I grab it.
        block = replace(path, block_pattern => "")[end] |> string

        if block ∈ keys(block_dict)
            push!(block_dict[block], path)
        else
            block_dict[block] = [path]
        end
    end

    filepaths_dict = Dict()
    for block in keys(block_dict)
        paths = block_dict[block] # get all filepaths for given block
        year_dict = Dict()
        for path in paths
            # Get year of observation (2000-01 = 2000):
            # the following pattern grabs fx "2009-10/" (to avoid 2000-2010 from earlier folder)
            year_pattern = r"[0-9]{4}-[0-9]{2}/"
            year = match(year_pattern, path).match[1:4]
            year_dict[year] = path # store the path as the name of the survey year
        end
        # Now year_dict has organized entries of a given block (e.g. "J"), with one
        # item per year (named after the year). So: "J" => dictionary with entries 2001, 2002, etc.
        filepaths_dict[block] = year_dict
    end

    return filepaths_dict
end

"""
Read and parse ASI files into dictionary of data frames of survey blocks.

The ASI data comes in .txt format. There are no delimiters. Instead, columns
are organized by the number of characters in each line. That is, the first X characters
belong to column 1, the next Y characters belong to column 2, etc. If a column-row value
does not fill out the supplied number of characters, spaces are added. This means that
the only way to organize the data from columns into a data frame is by denoting exactly
the number of characters in each column in each block in each year (yes, really) and
then parsing the data into the appropriate type afterwards.

This function handles the part of reading the .TXT data, and separating each row-string
into a series of tuples (one for each row) that are separated into the appropriate
columns. This list of "rows" is then gathered into a dataframe. Finally, all the
 dataframes from the same survey block is collected into a dataframe. These dataframes
 are saved to the 'temp' folder in the data directory.
"""
function parse_asi_files(ASI_paths::Dict)
    for block in keys(ASI_paths) # loop over all years
        parsed_blocks = DataFrame[]
        # `parsed_blocks` is a container for observations from a survey block.
        # Each element is observations (stored in a dataframe) from the given block
        # in a single year.

        # Get all paths for the current block:
        year_path_dict = ASI_paths[block]

        rows_in_input_data = 0 # counter to make sure I get all the data

        Threads.@threads for year in collect(eachindex(year_path_dict)) # loop over all blocks in the year
            # Note that the slightly strange iterator is because @threads does not handle
            # iterating over dictionary keys very well.
            @info "Reading and formatting rows for $year: block $block"
            # Read data:
            # Choose panel-structure based on year:
            # (note that while the data refers to 2000-01 as 2001,
            # I use 2000-01 = 2000)
            panel_structure_dict = select_panel_structure(parse(Int, year))
            path = year_path_dict[year]
            txt_data = readlines(path);
            rows_in_input_data += length(txt_data) # increment counter of observations in block-years

            # Select the proper dictionary with the column-separation structure:
            structure_dict = panel_structure_dict[block]

            # Parse the text (all the rows) with the column-separation from above:
            # This returns a list of named tuples, where each tuple is
            # a row in the dataset, and each key-value pair represents a column
            # and a value for the observation.
            column_separated_rows = parse_asi_row.(txt_data, Ref(structure_dict));

            # Get all of the tuples into one data frame.
            push!(parsed_blocks, DataFrame([row for row in column_separated_rows]))
        end

        block_df = reduce(vcat, parsed_blocks, cols=:union)
        check_output(block_df, rows_in_input_data)

        # Write to file to avoid memory constrains (on laptop).
        @info "Writing block $block to file."
        Arrow.write(datadir("temp", "block-$(block)-all-years-pre-cleaning.arrow"), block_df)
 #       CSV.write(datadir("temp", "block-$(block)-all-years-pre-cleaning.csv"), block_df)
        # bson(datadir("temp", "block-$(block)-all-years-pre-cleaning.bson"), parsed_row_dict)
    end
end

"Helper function that selects the appropriate panel structure based on survey year."
function select_panel_structure(survey_year::Int)
    if survey_year ∈ 2000:2007
        return panel_structure_2000_2007
    elseif survey_year == 2008
        return panel_structure_2008
    elseif survey_year == 2009
        return panel_structure_2009
    elseif survey_year ∈ 2010:2011
        return panel_structure_2010_2011
    elseif survey_year == 2012
        return panel_structure_2012
    elseif survey_year == 2013
        return panel_structure_2013
    elseif survey_year == 2014
        return panel_structure_2014
    elseif survey_year == 2015
        return panel_structure_2015
    end
end

"""
Parse a string vector (a row) from the ASI data into a named tuple, where each
 key is the name of column in the block and each value is the value of the
observation for the column. These tuples can be collected into a data frame after.
"""
function parse_asi_row(row::String, structure_dict::Dict)
    columns = structure_dict["columns"]
    separations = structure_dict["separations"]

    col_dict = Dict{Symbol, String}()
    for (i, col) in enumerate(columns)
        # The first column start from the beginning of the string, other columns
        # start from the character after the previous column ended.
        if i == 1
            val = row[1:separations[i]]
        else
            val = row[separations[i-1]+1:separations[i]] # +1 because range is inclusive
        end
        # col_dict[col] = strip(val)
        col_dict[Symbol(col)] = val
    end

    # turn the dictionary into a named tuple
    tuple_out = NamedTuple{Tuple(keys(col_dict))}(values(col_dict))
    return tuple_out
end

# TODO: This should be fixed. Maybe
"Perform a few cursory checks on the data."
function check_output(block_df, rows_in_input_data)
    @assert size(block_df)[1] == rows_in_input_data "The number of observations in the raw data does match the number of observations in formatted data."
    mapcols!(col -> passmissing(lstrip).(col), block_df)

    # As mentioned earlier, the original data specifies columns according to
    # a certain number of characters. If the value in a row does not fill up
    # number of characters, whitespace (spaces) are added on the left side
    # of the value. This means that if I remove left-sided whitespace, there
    # should be no whitespace in any columns after. If there still is, something
    # has been misspecified in the panel-structure dictionaries.

    # TODO: This should be fixed. I'm not sure what the best way to check is.

    # # First, remove whitespace:
    # mapcols!(col -> passmissing(lstrip).(col), block_df)
    # # Second, check for any whitespace:
    # for col in names(block_df)
    #     # There are two columns that this method does not work for:
    #     # accounting_year_to and accounting_year_from.
    #     if col ∈ ["accounting_year_to", "accounting_year_from"]
    #         continue
    #     end
    #     # There are also ~80 observations that have a wrong factory-ID format. They will be dropped
    #     # later. If there are less than 100 factory_ids with
    #     whitespace_test = passmissing.(match).(r"\s+", block_df[!, col])

    #     @assert typeof(whitespace_test) ∈ [Vector{Nothing}, Vector{Union{Missing, Nothing}}] "Column $col in block $block has whitespace after stripping."
    # end
end

# APPLY
ASI_2000_2009_paths = grab_asi_filepaths(datadir("external", "asi", "asi-2000-2009"));
ASI_2010_2015_paths = grab_asi_filepaths(datadir("external", "asi", "asi-2010-2015"));
ASI_paths = organize_filepaths(vcat(ASI_2000_2009_paths, ASI_2010_2015_paths))
parse_asi_files(ASI_paths)
println("DONE")
