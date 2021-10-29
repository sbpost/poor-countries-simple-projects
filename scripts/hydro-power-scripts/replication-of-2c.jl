using DrWatson
@quickactivate "poor-countries-simple-products"

using CSV
using DataFrames
using DataFramesMeta
using Chain
using ShiftedArrays
using Statistics

# Read
# insheet using "$data/Hydro Plants/HydroStationList_withStateAllocations.csv", comma names clear case
# change station to "R P SAGAR" if station == "R.P. SAGAR"
repdir = datadir("external", "112983-V1", "replication_archive_AER_september_2015", "01.-Data")

stations_w_stateallocation = CSV.read(joinpath(repdir,
                                               "Hydro-Plants",
                                               "HydroStationList_withStateAllocations.csv"),
                                      DataFrame)

@rtransform!(stations_w_stateallocation, :station = :station == "R.P. SAGAR" ? "R P SAGAR" : :station)

# insheet using "$data/Hydro Plants/Global Observatory/hydro_plant_types_new.csv", comma names clear double
# keep station state_final type_final  xcoord ycoord
# trim + lower names
hydro_plant_types_new = CSV.read(joinpath(repdir, "Hydro-Plants", "Global-Observatory", "hydro_plant_types_new.csv"),
                                 DataFrame)

@select!(hydro_plant_types_new, :Station, :State_final, :Type_final, :xcoord, :ycoord)
rename!(hydro_plant_types_new, :Station => :station, :State_final => :state_final, :Type_final => :type_final)

function fix_cols(val)
    val = strip(val)
    val = uppercase(val)
    return val
end
@rtransform!(hydro_plant_types_new,
             :station = passmissing(fix_cols)(:station),
             :state_final = passmissing(fix_cols)(:state_final),
             :type_final = passmissing(fix_cols)(:type_final))

rename!(hydro_plant_types_new, :state_final => :state, :type_final => :hydro_type)

hydro_plant_types_new = unique(hydro_plant_types_new)

@rtransform!(hydro_plant_types_new,
            :state = :state == "UP" ? "UTTAR PRADESH" :
                :state == "HP" ? "HIMACHAL PRADESH" :
                :state == "J&K" ? "JAMMU AND KASHMIR" :
                :state == "MP" ? "MADHYA PRADESH" :
                :state,
             :xcoord= round(:xcoord, digits = 3),
             :ycoord= round(:ycoord, digits = 3))


# Maybe drop the following:
# stations_0001 = CSV.read(joinpath(repdir, "Hydro-Plants", "Performance", "Generation-Performance-of-HE-Stations_2000_2001_cleaned.csv"),
#                          DataFrame)


# rename!(stations_0001,
#         "Actual Generation (MU)2000" => :actualgenerationmu,
#         "Generation Target (MU)2000" => :generationtargetmu,
#         "Station" => :station,
#         "Total (MW)" => :total_mw,
#         "% Over Target2000" => :overtarget)

# @select!(stations_0001, $(Not()))

# dropmissing!(stations_0001, :actualgenerationmu)



stat)ions_adj_df = CSV.read(joinpath(repdir, "Hydro-Plants", "Performance", "Performance-of-Hydro-Power-Stations_adjusted.csv"),
                           DataFrame)

@rsubset!(stations_adj_df, ismissing(:drop))
@select!(stations_adj_df, $(Not([:drop, :adjusted])))

rename!(stations_adj_df,
        "Year" => :year,
        "Station" => :station,
        "Generation Target (MU)" => :generationtargetmu,
        "Actual Generation (MU)" => :actualgenerationmu,
        "Total (MW)" => :totalmw,
        "% Over Target" => :overtarget)

@select!(stations_adj_df, $(Not([:generationtargetmu, :overtarget])))

@rtransform!(stations_adj_df,
            :station = uppercase(strip(:station)) |> string,
            :totalmw = :totalmw == "Koteshwar" ? "400" : :totalmw)

@rtransform!(stations_adj_df,
            :station = uppercase(strip(:station)) |> string,
             :totalmw = :totalmw == "Koteshwar" ? "400" : :totalmw)

@rsubset!(stations_adj_df, :actualgenerationmu != "N.A")

@rtransform!(stations_adj_df, :actualgenerationmu = parse(Float64, :actualgenerationmu))
@rtransform!(stations_adj_df, :HydroMW_micro = parse(Float64, :totalmw))
unique!(stations_adj_df)
stations_w_types = leftjoin(stations_adj_df, hydro_plant_types_new, on=:station)
@rsubset!(stations_w_types, !(:state ∈ ["DROP", "BHUTAN", "UNK"]))

@rtransform!(stations_w_types,
             :HydroMW_micro = :HydroMW_micro == -99999.0 || :HydroMW_micro == -9999 ? missing : :HydroMW_micro,
             :actualgenerationmu = :actualgenerationmu == -99999 || :actualgenerationmu == -9999 ? missing : :actualgenerationmu)

# *now fill in with last known or next known capacity before collapses--this saves a little data eventually
stations_w_types = @chain stations_w_types begin
    @orderby(_, :year)
    groupby(_, :station)
    @transform(_,
               :prev_HydroMW_micro =  lag(:HydroMW_micro),
               :next_HydroMW_micro =  lead(:HydroMW_micro))
    @rtransform(_,
                :HydroMW_micro = ismissing(:HydroMW_micro) || :HydroMW_micro == 0 ?
                    :prev_HydroMW_micro : :HydroMW_micro)
    @rtransform(_,
                :HydroMW_micro = ismissing(:HydroMW_micro) || :HydroMW_micro == 0 ?
                    :next_HydroMW_micro : :HydroMW_micro)
end

@assert all([ismissing(val) || val >= 0 for val in stations_w_types.HydroMW_micro])
@assert all([ismissing(val) || val >= 0 for val in stations_w_types.actualgenerationmu])

#**here we fix names
@chain stations_w_types groupby([:year, :station]) combine(nrow => :count) @subset(:count .> 1)

@chain stations_w_types @subset(:station .== "N.J. SAGAR RBC")

# collapse (sum) HydroMW_micro actual, by(state station year hydro_type xcoord ycoord) //this collapses entries of different units in sample plant in a couple places into single obs by plant-year  //
stations_w_types = @chain stations_w_types begin
    groupby(_, [:station, :state, :year, :hydro_type, :xcoord, :ycoord])
    @combine(_,
             :actualgenerationmu = passmissing(sum)(:actualgenerationmu),
             :HydroMW_micro = passmissing(sum)(:HydroMW_micro))
    @rsubset(_, :year >= 1999)
end

# import excel "$data/Hydro Plants/Global Observatory/clean_plant_names.xlsx", sheet("Sheet1") firstrow clear case(lower)
clean_plant_names = CSV.read(joinpath(repdir, "Hydro-Plants", "Global-Observatory", "clean_plant_names.csv"),
DataFrame)

@select!(clean_plant_names, :station, :state, :group, :group_type)
unique!(clean_plant_names)
@chain clean_plant_names begin
    groupby(_, [:state, :station])
    combine(_, nrow => :count)
    @assert all(_.count .== 1)
end

stations_df = leftjoin(stations_w_types, clean_plant_names, on = [:station, :state])

@rtransform!(stations_df, :station_orig = :station)
# if group is not missing, set station to group
@rtransform!(stations_df, :station = !ismissing(:group) ? :group : :station)
# if group type is not missing, set type to group_type
@rtransform!(stations_df, :hydro_type = !ismissing(:group_type) ? :group_type : :hydro_type)

# replace state = "WEST BENGAL" if station=="JALDHAKA, MASSANJORE AND RAMMAM COMPLEX"
@rtransform!(stations_df, :state = :station == "JALDHAKA, MASSANJORE AND RAMMAM COMPLEX" ? "WEST BENGAL" : :state)
# replace state = "UTTARAKHAND" if station=="MOHAMADPUR, PATHRARI AND NIRGAJANI COMPLEX"
@rtransform!(stations_df, :state = :station == "MOHAMADPUR, PATHRARI AND NIRGAJANI COMPLEX" ? "UTTARAKHAND" : :state)

# check uniqueness
@assert (@chain stations_df @select(:station, :state) unique(_) groupby(:station) combine(nrow => :count) unique(_.count) only(_)) == 1

# gsort station +year
stations_df = @chain stations_df begin
    @orderby(_, :year)
    groupby(_, :station)
    @transform _ :rank = length(:year)
    @rtransform _ :flag = (ismissing(:actualgenerationmu) || :actualgenerationmu === 0)  && :rank === 1 ? true : false
    @orderby(_, :year)
    groupby(_, :station)
    @transform(_, :lag_flag = lag(:flag))
    @transform(_, :lag_station = lag(:station))
    @rtransform _ :flag = (ismissing(:actualgenerationmu) || :actualgenerationmu === 0) && :lag_flag === 1 && :station == :lag_station ? :lag_flag : :flag
    @rsubset(_, :flag != true)
end

@select!(stations_df, $(Not([:flag, :lag_flag, :lag_station, :rank, :group, :group_type])))

# TODO?
# set up unique coordinates to be used within combined plant reportings based on location of largest sub-plant
# gsort state station -HydroMW_micro -year
# bys state station : g index=_n
# g xcoord_max = xcoord if index==1
# g ycoord_max = ycoord if index==1
# bys state station: egen xcoord_final = mean(xcoord_max)
# bys state station: egen ycoord_final = mean(ycoord_max)

# replace xcoord = xcoord_final
# replace ycoord = ycoord_final
# assert !mi(xcoord) & !mi(ycoord) //no plants are missing coordinates

# collapse (sum) HydroMW_micro actual, by(state station year hydro_type ycoord xcoord) //this collapses by complex after fixing names
stations_df = @chain stations_df begin
    groupby(_, [:station, :state, :year, :hydro_type])
    @combine(_,
             :HydroMW_micro = passmissing(sum)(:HydroMW_micro),
             :actualgenerationmu = passmissing(sum)(:actualgenerationmu))
end


# ***check into fluctutions within group
# preserve
# keep if year>=1992 & year<=2010
@chain stations_df begin
    groupby(_, :station)
    @combine(_,
             :mean_mw = passmissing(mean)(:HydroMW_micro),
             :sd_mw = passmissing(std)(:HydroMW_micro))
    @transform _ :check = :sd_mw ./ :mean_mw
    sort(_, :check)
 #   @rsubset(_, :check > 0.01 )
end

@rsubset(stations_df, ismissing(:actualgenerationmu))

# collapse (mean) mean=HydroMW_micro (sd) sd=HydroMW_micro, by(station)
# g check = sd/mean
# drop if check<0.01 | check==.
# gsort - check
# outsheet using "$work/within station variance check.csv", comma names replace
# restore
# *** end check

# ***fix MW availability for 1998 here
# gsort station year
# replace HydroMW_micro = HydroMW_micro[_n+1] if HydroMW_micro==. & year==1998 & station==station[_n+1]
# replace HydroMW_micro = HydroMW_micro[_n-1] if HydroMW_micro==. & year==1998 & station==station[_n-1]
# ***

# *** Get capacity factor
# gen CF = actualgenerationmu/8.760/HydroMW_micro // 8760 hours/year, 1000 MW/GW gives 8.760.



# *define
# 	* The below makes RunOfRiver missing if hydro_type == "unk"
# g RunOfRiver = hydro_type=="barrage with run-of-river generation" | hydro_type=="run-of-river" | hydro_type=="dam with run-of-river generation" if hydro_type!="unk"
# *g Dam = hydro_type=="dam on a canal" | hydro_type=="dam on a lake"| hydro_type=="dam on river with reservoir" | hydro_type=="dam"
# *g OtherHydroType = RunOfRiver==0 & Dam==0

# keep if year>=1992


# replace state ="UTTARANCHAL" if state=="UTTARAKHAND"

# **set up crossed dataset
# bys station state year: g rank=_N
# 	assert rank==1
# 	drop rank
# 	assert _N==2612

# *keep just the years for analysis
# keep if year>=1992 & year<=2010
# bys station state: egen firstyear = min(year)
# bys station state: egen lastyear = max(year)
# 	assert !mi(firstyear) & !mi(lastyear)
# 	tempfile stationsinfo
# 	save `stationsinfo'
# *stations base
# keep station state firstyear lastyear xcoord ycoord
# duplicates drop
# tempfile stationsbase
# save `stationsbase'
# *years base
# clear
# set obs 19
# g year=_n+1991
# assert year>=1992 & year<=2010
# cross using `stationsbase'
# bys station state firstyear lastyear: g rank=_N
# 	assert rank==19 //is square by year
# 	drop rank
# 	count //assert _N==
# drop if year>lastyear //pare off the years outside observed span that were introduced by crossing

# 	* 1992 is fully missing. Temporarily replace firstyear=1992 in order to get a 1992 year that duplicates 1993.
# 	replace firstyear = 1992 if firstyear==1993
# 	drop if year<firstyear //pare off the years outside observed span that were introduced by crossing
# 	replace firstyear = 1993 if firstyear==1992

# merge 1:1 station state year firstyear lastyear using `stationsinfo', assert(1 3) //1s will be the new obs input by the squaring; these are very few
# 	count if _m==1
# 	assert r(N)==156 //out of 2746 -- very few
# 	tab year _m //most in 1992 by construction, else 98 by nature of that year's data
# 	br if _m==1 & year!=1992 & year!=1998
# 	*gen imputed_plant_year = _m==1 //note that none of the capacity or production data has yet been imputed
# 	drop _m

# ** Drag back data for 1992
# gsort state station year
# foreach var in hydro_type HydroMW_micro RunOfRiver {
# 	replace `var' = `var'[_n+1] if year==1992 & year[_n+1]==1993 & station==station[_n+1] & state==state[_n+1]
# 	replace `var' = `var'[_n-1] if year==2008& year[_n-1]==2007& station==station[_n-1] & state==state[_n-1] & station=="SEWA 3"
# }

# repl_conf actualgenerationmu	= 0 if station=="SEWA 3" & year==2008
# repl_conf CF = 0 if station=="SEWA 3" & year==2008

# //output unique hydro station list with coordinates
# preserve
# keep state station xcoord ycoord
# duplicates drop
# bys state station: g rank=_N
# assert rank==1
# drop rank
# gsort state station
# g index=_n
# order index
# outsheet using "$work/hydro_stations_list_v2.csv", comma names replace
# restore

# save "$work/Hydro Plant Generation Microdata.dta", replace


# ********************************************************************************
# ********************************************************************************
