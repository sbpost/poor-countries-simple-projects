# NOTE: This function has been scratched because I changed the function from organizing into years, then blocks to blocks, then years.
# This makes more sense when collapsing data into one dataframe per block (with all years obs insid inside).
function organize_filepaths(filepaths)
    # This function is a bit involved. First I organize each filepath into the correct
    # year (in a dictionary). I then use this dictionary to organize each filepath under
    # the correct block letter. Finally, the blocks are collected under the proper year
    # in the return dictionary, `filepath_dict`

    years_dict = Dict()
    #  Organize all filepaths into their correct year.
    for path in asi_filepaths
        # Get year of observation (2000-01 = 2000):
        # the following pattern grabs fx "2009-10/" (to avoid 2000-2010 from earlier folder)
        year_pattern = r"[0-9]{4}-[0-9]{2}/"
        # grabs first four digits of match (ie "2009" from "2009-10/")
        year = match(year_pattern, path).match[1:4]
        if year ∈ keys(years_dict)
            push!(years_dict[year], path)
        else
            years_dict[year] = [path]
        end
    end

    filepath_dict = Dict()
    for year in keys(years_dict)
        filepaths = years_dict[year]
        block_dict = Dict()
        for path in filepaths
            # Get block of observation:
            # We know which block a file belongs to by its name.
            # From 2000-01 to 2008-09 the files follow a pattern with OSAIBL, OASI, or OAS,
            # followed by a letter. After the letter comes a number (varying digits) denoting
            # the year. This letter gives the survey block that the data represents.

            # The block letter comes right before the year and the file ending.
            block_pattern = r"(\d+)|(\.TXT)"
            # Now last character is the block letter. I grab it.
            block = replace(path, block_pattern => "")[end]
            block_dict["$block"] = path
        end
        filepath_dict[year] = block_dict
    end

    return filepath_dict
end


# NOTE: This function was scratched because I reorded the organizing to have the outer structure be blocks, not years.# NOTE: This function was scratched because I reorded the organizing to have the outer structure be blocks, not years.
function parse_asi_files(ASI_paths::Dict)
    @showprogress for year in keys(ASI_paths) # loop over all years
        parsed_row_dict = Dict{String, DataFrame}()
        # `parse_row_dict` are observations for a given year. Elements in the
        # dictionary are dataframes for each block. Dataframes are kept separate
        # for now, because different years have different information. A later
        # function collapses the all years into a dataframe per block.

        block_path_dict = ASI_paths[year] # (note that while the data refers to 2000-01 as 2001,
        # I use 2000-01 = 2000)
        # Choose panel-structure based on year:
        panel_structure_dict = select_panel_structure(parse(Int, year))

        for block in keys(block_path_dict) # loop over all blocks in the year
            @info "Reading and formatting rows for $year: block $block"
            # Read data:
            path = block_path_dict[block]
            txt_data = readlines(path);

            # Select the proper dictionary with the column-separation structure:
            structure_dict = panel_structure_dict[block]
            # Parse the text (all the rows) with the column-separation from above:
            # This returns a list of dictionaries, where each dictionary is
            # a row in the dataset, and each key-value pair represents a column
            # and a value for the observation.
            column_separated_rows = parse_asi_row.(txt_data, Ref(structure_dict))

            # Get all of the row-dictionaries into one data frame.
            parsed_row_dict[block] = reduce(vcat, DataFrame.(column_separated_rows))

        end
        # Write to file to avoid memory constrains (on laptop).
        bson(datadir("temp", "$(year)-blocks-pre-cleaning.bson"), parsed_row_dict)
    end
    return "OK"
end

# NOTE This was scratched because I changed in to named tuples to hold variable types as well (after shingint to Arrow.jl)
variables = Dict(
    # :A => ["year",
    #        "factory_id",
    #        "block",
    #        "scheme",
    #        "nic5code",
    #        "rural_urban",
    #        "no_units",
    #        "unit_status",
    #        "production_cost",
    #        "multiplier"],
    :A => (year = Int64,
           factory_id = String,
           block = String,
           scheme = String,
           nic5code = String,
           rural_urban = Int64,
           no_units = Int64,
           unit_status = String,
           production_cost = Float64,
           multiplier = Float64),
    :B => ["year",
           "factory_id",
           "block",
           "type_organisation",
           "initial_production",
           "multiplier"],
    :C => ["year",
           "factory_id",
           "block",
           "sno",
           "opening_gross",
           "closing_gross",
           "opening_net",
           "closing_net",
           "multiplier"],
    :D => ["year",
           "factory_id",
           "block",
           "sno",
           "w_cap_opening",
           "w_cap_closing",
           "multiplier"],
    :E => ["year",
           "factory_id",
           "block",
           "sno",
           "avg_person_worked",
           "wages",
           "multiplier"],
    :H =>  ["year",
            "factory_id",
            "block",
            "sno",
            "qty_unit",
            "qty_consumed",
            "item_code",
            "purchase_val",
            "multiplier"],
    :I => ["year",
           "factory_id",
           "block",
           "sno",
           "qty_unit",
           "qty_consumed",
           "item_code",
           "purchase_val",
           "multiplier"],
    :J => ["year",
           "factory_id",
           "block",
           "sno",
           "item_code",
           "qty_unit",
           "qty_sold",
           "ex_factory_val",
           "gross_sale_val",
           "multiplier"]
)
