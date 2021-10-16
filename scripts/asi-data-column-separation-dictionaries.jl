# Create dictionaries containing the column-separation format for each "format-group"

# ======================================================================== #
# Panel structure 2000-01 to 2007-08
# ======================================================================== #

panel_structure_2000_2007 = Dict(
    "A" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "scheme",
                      "nic4code",
                      "nic5code",
                      "rural_urban",
                      "sro",
                      "no_units",
                      "unit_status",
                      "mw_days",
                      "nw_days",
                      "wdays",
                      "production_cost",
                      "multiplier"],
        "separations" => [4, 12, 13,  14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 55, 64]
    ),

    "B" => Dict(
        "columns" => ["year",
                         "factory_id",
                         "block",
                         "type_organisation",
                         "type_ownership",
                         "no_of_units",
                         "no_units_in_same_state",
                         "initial_production",
                         "accounting_year_from",
                         "accounting_year_to",
                         "months_of_operation",
                         "ac_system",
                         "asi_floppy",
                         "multiplier"],
            "separations" => [4, 12, 13, 15, 16, 20, 24, 28, 37, 46, 48, 49, 50, 59]
        ),

    "C" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "opening_gross",
                      "addition_reval",
                      "addition_add",
                      "deduction_adj",
                      "closing_gross",
                      "deprec_begin_year",
                      "deprec_during_year",
                      "deprec_end_year",
                      "opening_net",
                      "closing_net",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 27, 39, 51, 63, 75, 87, 99, 111, 123, 135, 144]
    ),

    "D" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "w_cap_opening",
                      "w_cap_closing",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 27, 39, 48]
    ),

    "E" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "man_days",
                      "non_man_days",
                      "tot_days",
                      "avg_person_worked",
                      "days_paid",
                      "wages",
                      "bonus",
                      "contrib_provident_fund",
                      "staff_welfare_exp",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 23, 31, 41, 49, 59, 71, 83, 95, 107, 116]
    ),

    "F" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "exp_work_others",
                      "exp_building_repair",
                      "exp_plant_machinery",
                      "exp_pollution_control",
                      "exp_other_fixed_assets",
                      "exp_operating",
                      "exp_non_operating",
                      "insurance",
                      "rent_machinery",
                      "exp_total",
                      "rent_buildings",
                      "rent_land",
                      "interests_paid",
                      "purc_val_goods_resold",
                      "multiplier"],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 157, 169, 181, 190]
    ),

    "G" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "income_services",
                      "var_semi_fin",
                      "val_electricity_sold",
                      "val_own_construction",
                      "net_balance_goods_resold",
                      "rent_income_machinery",
                      "total_receipts",
                      "rent_income_building",
                      "rent_income_land",
                      "interest_income",
                      "sale_val_goods_resold",
                      "multiplier"],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 154]
    ),

    "H" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "item_code",
                      "qty_unit",
                      "qty_consumed",
                      "purchase_val",
                      "unit_rate",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 51, 66, 75]
    ),

    "I" => Dict(
        "columns" =>
            ["year",
             "factory_id",
             "block",
             "sno",
             "item_code",
             "qty_unit",
             "qty_consumed",
             "purchase_val",
             "unit_rate",
             "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 51, 66, 75]
    ),

    "J" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "item_code",
                      "qty_unit",
                      "qty_made",
                      "qty_sold",
                      "gross_sale_val",
                      "excise_duty",
                      "sales_tax",
                      "others",
                      "total",
                      "per_unit_sale_val",
                      "ex_factory_val",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 55, 67, 79, 91, 103, 115, 130, 142, 151]
    )
)


# ======================================================================== #
# Panel structure 2008-09
# ======================================================================== #

panel_structure_2008 = Dict(
    "A" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "scheme",
                      "nic4code",
                      "nic5code",
                      "rural_urban",
                      "sro",
                      "no_units",
                      "unit_status",
                      "mw_days",
                      "nw_days",
                      "wdays",
                      "production_cost",
                      "export_share",
                      "multiplier"],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 55, 58, 67]
    ),

    "B" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "type_organisation",
                      "type_ownership",
                      "no_of_units",
                      "initial_production",
                      "accounting_year_from",
                      "accounting_year_to",
                      "months_of_operation",
                      "ac_system",
                      "asi_floppy",
                      "investment_in_p_m",
                      "iso",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 16, 20, 24, 33, 42, 44, 45, 46, 47, 48, 57]
    ),

    "C" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "opening_gross",
                      "addition_reval",
                      "addition_add",
                      "deduction_adj",
                      "closing_gross",
                      "deprec_begin_year",
                      "deprec_during_year",
                      "deprec_adj_during_year",
                      "deprec_end_year",
                      "opening_net",
                      "closing_net",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 27, 39, 51, 63, 75, 87, 99, 111, 123, 135, 147, 156]
    ),

    "D" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "w_cap_opening",
                      "w_cap_closing",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 27, 39, 48]
    ),

    "E" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "man_days",
                      "non_man_days",
                      "tot_days",
                      "avg_person_worked",
                      "days_paid",
                      "wages",
                      "bonus",
                      "contrib_provident_fund",
                      "staff_welfare_exp",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 23, 31, 41, 49, 59, 71, 83, 95, 107, 116]
    ),

    "F" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "exp_work_others",
                      "exp_building_repair",
                      "exp_other_fixed_assets",
                      "exp_operating",
                      "exp_non_operating",
                      "insurance",
                      "rent_machinery",
                      "exp_total",
                      "rent_buildings",
                      "rent_land",
                      "interests_paid",
                      "purc_val_goods_resold",
                      "multiplier"],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 157, 166]
    ),

    "G" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "income_services",
                      "var_semi_fin",
                      "val_electricity_sold",
                      "val_own_construction",
                      "net_balance_goods_resold",
                      "rent_income_machinery",
                      "total_receipts",
                      "rent_income_building",
                      "rent_income_land",
                      "interest_income",
                      "sale_val_goods_resold",
                      "total_subsidies",
                      "multiplier"],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 157, 166]
    ),

    "H" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "item_code",
                      "qty_unit",
                      "qty_consumed",
                      "purchase_val",
                      "unit_rate",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 51, 66, 75]
    ),

    "I" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "item_code",
                      "qty_unit",
                      "qty_consumed",
                      "purchase_val",
                      "unit_rate",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 51, 66, 75]
    ),

    "J" => Dict(
        "columns" => ["year",
                      "factory_id",
                      "block",
                      "sno",
                      "item_code",
                      "qty_unit",
                      "qty_made",
                      "qty_sold",
                      "gross_sale_val",
                      "excise_duty",
                      "sales_tax",
                      "others",
                      "total",
                      "per_unit_sale_val",
                      "ex_factory_val",
                      "multiplier"],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 55, 67, 79, 91, 103, 115, 130, 142, 151]
    )
)

# ======================================================================== #
# Panel structure 2009-10
# ======================================================================== #

panel_structure_2009 = Dict(
    "A" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "scheme",
            "nic4code",
            "nic5code",
            "rural_urban",
            "sro",
            "no_units",
            "unit_status",
            "mw_days",
            "nw_days",
            "wdays",
            "production_cost",
            "export_share",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 55, 58, 67]
    ),

    "B" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "type_organisation",
            "type_ownership",
            "no_of_units",
            "initial_production",
            "accounting_year_from",
            "accounting_year_to",
            "months_of_operation",
            "ac_system",
            "asi_floppy",
            "investment_in_p_m",
            "iso",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 16, 20, 24, 33, 42, 44, 45, 46, 47, 48, 57]
    ),

    "C" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "opening_gross",
            "addition_reval",
            "addition_add",
            "deduction_adj",
            "closing_gross",
            "deprec_begin_year",
            "deprec_during_year",
            "deprec_adj_during_year",
            "deprec_end_year",
            "opening_net",
            "closing_net",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 27, 39, 51, 63, 75, 87, 99, 111, 123, 135, 147, 156]
    ),

    "D" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "w_cap_opening",
            "w_cap_closing",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 27, 39, 48]
    ),

    "E" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "man_days",
            "non_man_days",
            "tot_days",
            "avg_person_worked",
            "days_paid",
            "wages",
            "bonus",
            "contrib_provident_fund",
            "staff_welfare_exp",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 23, 31, 41, 49, 59, 71, 85, 99, 113, 122]
    ),

    "F" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "exp_work_others",
            "exp_building_repair",
            "exp_other_fixed_assets",
            "exp_operating",
            "exp_non_operating",
            "insurance",
            "rent_machinery",
            "exp_total",
            "rent_buildings",
            "rent_land",
            "interests_paid",
            "purc_val_goods_resold",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 157, 166]
    ),

    "G" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "income_services",
            "var_semi_fin",
            "val_electricity_sold",
            "val_own_construction",
            "net_balance_goods_resold",
            "rent_income_machinery",
            "total_receipts",
            "rent_income_building",
            "rent_income_land",
            "interest_income",
            "sale_val_goods_resold",
            "total_subsidies",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 25, 37, 49, 61, 73, 85, 97, 109, 121, 133, 145, 157, 166]
    ),

    "H" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_consumed",
            "purchase_val",
            "unit_rate",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 54, 69, 78]
    ),

    "I" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_consumed",
            "purchase_val",
            "unit_rate",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 54, 69, 78]
    ),

    "J" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_made",
            "qty_sold",
            "gross_sale_val",
            "excise_duty",
            "sales_tax",
            "others",
            "total",
            "per_unit_sale_val",
            "ex_factory_val",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 20, 23, 39, 55, 70, 85, 100, 115, 130, 145, 160, 169]
    )
)

# ======================================================================== #
# Panel structure 2010-11 to 2011-12
# ======================================================================== #
panel_structure_2010_2011 = Dict(
    "A" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "scheme",
            "nic4code",
            "nic5code",
            "rural_urban",
            "sro",
            "no_units",
            "unit_status",
            "mw_days",
            "nw_days",
            "wdays",
            "production_cost",
            "export_share",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 57, 60, 69]
    ),
    "B" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "type_organisation",
            "type_ownership",
            "initial_production",
            "accounting_year_from",
            "accounting_year_to",
            "months_of_operation",
            "ac_system",
            "asi_floppy",
            "iso",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 16, 20, 29, 38, 40, 41, 42, 43, 52],
    ),

    "C" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "opening_gross",
            "addition_reval",
            "addition_add",
            "deduction_adj",
            "closing_gross",
            "deprec_begin_year",
            "deprec_during_year",
            "deprec_adjustment",
            "deprec_end_year",
            "opening_net",
            "closing_net",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 29, 43, 57, 71, 85, 99, 113, 127, 141, 155, 169, 178]
    ),

    "D" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "w_cap_opening",
            "w_cap_closing",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 29, 43, 52]
    ),

    "E" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "man_days",
            "non_man_days",
            "tot_days",
            "avg_person_worked",
            "days_paid",
            "wages",
            "bonus",
            "contrib_provident_fund",
            "staff_welfare_exp",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 23, 31, 41, 49, 59, 73, 87, 101, 115, 124]
    ),

    "F" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "exp_work_others",
            "exp_building_repair",
            "exp_other_fixed_assets",
            "exp_operating",
            "exp_non_operating",
            "insurance",
            "rent_machinery",
            "exp_total",
            "rent_buildings",
            "rent_land",
            "interests_paid",
            "purc_val_goods_resold",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 27, 41, 55, 69, 83, 97, 111, 125, 139, 153, 167, 181, 190]
    ),

    "G" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "income_services",
            "var_semi_fin",
            "val_electricity_sold",
            "val_own_construction",
            "net_balance_goods_resold",
            "rent_income_machinery",
            "total_receipts",
            "rent_income_building",
            "rent_income_land",
            "interest_income",
            "sale_val_goods_resold",
            "total_subsidies",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 27, 41, 55, 69, 83, 97, 111, 125, 139, 153, 167, 181, 190]
    ),

    "H" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_consumed",
            "purchase_val",
            "unit_rate",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 22, 25, 39, 53, 67, 76]
    ),

    "I" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_consumed",
            "purchase_val",
            "unit_rate",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 22, 25, 39, 53, 67, 76]
    ),

    "J" => Dict(
        "columns" => [
            "year",
            "factory_id",
            "block",
            "sno",
            "item_code",
            "qty_unit",
            "qty_made",
            "qty_sold",
            "gross_sale_val",
            "excise_duty",
            "sales_tax",
            "others",
            "total",
            "per_unit_sale_val",
            "ex_factory_val",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 15, 22, 25, 39, 53, 67, 81, 95, 109, 123, 137, 151, 160]
    )
)

# ======================================================================== #
# Panel structure 2012-13
# ======================================================================== #

panel_structure_2012 = Dict(
    "A" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "scheme",
        "nic4code",
        "nic5code",
        "rural_urban",
        "sro",
        "no_units",
        "unit_status",
        "mw_days",
        "nw_days",
        "wdays",
        "production_cost",
        "export_share",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 57, 60, 73]
    ),

    "B" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "type_organisation",
        "type_ownership",
        "initial_production",
        "accounting_year_from",
        "accounting_year_to",
        "months_of_operation",
        "ac_system",
        "asi_floppy",
        "iso",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 21, 25, 34, 43, 45, 46, 47, 48, 61]
            ),

    "C" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "opening_gross",
        "addition_reval",
        "addition_add",
        "deduction_adj",
        "closing_gross",
        "deprec_begin_year",
        "deprec_during_year",
        "deprec_adjustment",
        "deprec_end_year",
        "opening_net",
        "closing_net",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 62, 76, 90, 104, 118, 132, 146, 160, 174, 187]
            ),

    "D" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "w_cap_opening",
        "w_cap_closing",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 61]
            ),

    "E" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "man_days",
        "non_man_days",
        "tot_days",
        "avg_person_worked",
        "days_paid",
        "wages",
        "bonus",
        "contrib_provident_fund",
        "staff_welfare_exp",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 28, 36, 46, 54, 64, 78, 92, 106, 120, 133]
            ),

    "F" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "exp_work_others",
        "exp_building_repair",
        "exp_other_fixed_assets",
        "exp_operating",
        "exp_non_operating",
        "insurance",
        "rent_machinery",
        "exp_total",
        "rent_buildings",
        "rent_land",
        "interests_paid",
        "purc_val_goods_resold",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
            ),

    "G" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "income_services",
        "var_semi_fin",
        "val_electricity_sold",
        "val_own_construction",
        "net_balance_goods_resold",
        "rent_income_machinery",
        "total_receipts",
        "rent_income_building",
        "rent_income_land",
        "interest_income",
        "sale_val_goods_resold",
        "total_subsidies",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),

    "H" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 85]
    ),
    "I" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 85]
    ),
    "J" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_made",
        "qty_sold",
        "gross_sale_val",
        "excise_duty",
        "sales_tax",
        "others",
        "total",
        "per_unit_sale_val",
        "ex_factory_val",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156, 169]
    )
)

# ======================================================================== #
# Panel structure 2013-14
# ======================================================================== #

panel_structure_2013 = Dict(
    "A" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "scheme",
        "nic4code",
        "nic5code",
        "rural_urban",
        "sro",
        "no_units",
        "unit_status",
        "mw_days",
        "nw_days",
        "wdays",
        "production_cost",
        "export_share",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 57, 60, 73]
    ),

    "B" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "type_organisation",
        "type_ownership",
        "initial_production",
        "accounting_year_from",
        "accounting_year_to",
        "months_of_operation",
        "ac_system",
        "asi_floppy",
        "iso",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 21, 25, 34, 43, 45, 46, 47, 48, 61]
            ),

    "C" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "opening_gross",
        "addition_reval",
        "addition_add",
        "deduction_adj",
        "closing_gross",
        "deprec_begin_year",
        "deprec_during_year",
        "deprec_adjustment",
        "deprec_end_year",
        "opening_net",
        "closing_net",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 62, 76, 90, 104, 118, 132, 146, 160, 174, 187]
            ),

    "D" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "w_cap_opening",
        "w_cap_closing",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 61]
            ),

    "E" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "man_days",
        "non_man_days",
        "tot_days",
        "avg_person_worked",
        "days_paid",
        "wages",
        "bonus",
        "contrib_provident_fund",
        "staff_welfare_exp",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 28, 36, 46, 54, 64, 78, 92, 106, 120, 133]
            ),

    "F" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "exp_work_others",
        "exp_building_repair",
        "exp_other_fixed_assets",
        "exp_operating",
        "exp_non_operating",
        "insurance",
        "rent_machinery",
        "exp_total",
        "rent_buildings",
        "rent_land",
        "interests_paid",
        "purc_val_goods_resold",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
            ),

    "G" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "income_services",
        "var_semi_fin",
        "val_electricity_sold",
        "val_own_construction",
        "net_balance_goods_resold",
        "rent_income_machinery",
        "total_receipts",
        "rent_income_building",
        "rent_income_land",
        "interest_income",
        "sale_val_goods_resold",
        "total_subsidies",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),

    "H" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 21, 28, 31, 45, 59, 73, 86]
            ),

    "I" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 85]
    ),
    "J" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_made",
        "qty_sold",
        "gross_sale_val",
        "excise_duty",
        "sales_tax",
        "others",
        "total",
        "per_unit_sale_val",
        "ex_factory_val",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156, 169]
    )
)

# ======================================================================== #
# Panel structure 2014-15
# ======================================================================== #
panel_structure_2014 = Dict(
    "A" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "scheme",
        "nic4code",
        "nic5code",
        "rural_urban",
        "sro",
        "no_units",
        "unit_status",
        "mw_days",
        "nw_days",
        "wdays",
        "production_cost",
        "export_share",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 57, 60, 73]
    ),
    "B" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "type_organisation",
        "type_ownership",
        "initial_production",
        "accounting_year_from",
        "accounting_year_to",
        "months_of_operation",
        "ac_system",
        "asi_floppy",
        "iso",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 21, 25, 34, 43, 45, 46, 47, 48, 61]
    ),
    "C" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "opening_gross",
        "addition_reval",
        "addition_add",
        "deduction_adj",
        "closing_gross",
        "deprec_begin_year",
        "deprec_during_year",
        "deprec_adjustment",
        "deprec_end_year",
        "opening_net",
        "closing_net",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 62, 76, 90, 104, 118, 132, 146, 160, 174, 187]
    ),
    "D" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "w_cap_opening",
        "w_cap_closing",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 61]
    ),
    "E" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "man_days",
        "non_man_days",
        "tot_days",
        "avg_person_worked",
        "days_paid",
        "wages",
        "bonus",
        "contrib_provident_fund",
        "staff_welfare_exp",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 28, 36, 46, 54, 64, 78, 92, 106, 120, 133]
    ),
    "F" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "exp_work_others",
        "exp_building_repair",
        "exp_other_fixed_assets",
        "exp_operating",
        "exp_non_operating",
        "insurance",
        "rent_machinery",
        "exp_total",
        "rent_buildings",
        "rent_land",
        "interests_paid",
        "purc_val_goods_resold",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),
    "G" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "income_services",
        "var_semi_fin",
        "val_electricity_sold",
        "val_own_construction",
        "net_balance_goods_resold",
        "rent_income_machinery",
        "total_receipts",
        "rent_income_building",
        "rent_income_land",
        "interest_income",
        "sale_val_goods_resold",
        "total_subsidies",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),
    "H" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 21, 28, 31, 45, 59, 73, 86]
    ),
    "I" => Dict(
        "columns" => [
         "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
            "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 85]
    ),
    "J" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_made",
        "qty_sold",
        "gross_sale_val",
        "excise_duty",
        "sales_tax",
        "others",
        "total",
        "per_unit_sale_val",
        "ex_factory_val",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 21, 28, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156, 169]
    )
)

# ======================================================================== #
# Panel structure 2015-16
# ======================================================================== #
panel_structure_2015 = Dict(
    "A" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "scheme",
        "nic4code",
        "nic5code",
        "rural_urban",
        "sro",
        "no_units",
        "unit_status",
        "mw_days",
        "nw_days",
        "wdays",
        "production_cost",
        "export_share",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 14, 18, 23, 24, 29, 32, 34, 37, 40, 43, 57, 60, 73]
    ),
    "B" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "type_organisation",
        "corporate_id",
        "initial_production",
        "accounting_year_from",
        "accounting_year_to",
        "months_of_operation",
        "capital_share_foreign",
        "contain_r_and_d",
        "iso",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 41, 45, 51, 57, 59, 60, 61, 62, 75]
    ),
    "C" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "opening_gross",
        "addition_reval",
        "addition_add",
        "deduction_adj",
        "closing_gross",
        "deprec_begin_year",
        "deprec_during_year",
        "deprec_adjustment",
        "deprec_end_year",
        "opening_net",
        "closing_net",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 62, 76, 90, 104, 118, 132, 146, 160, 174, 187]
    ),
    "D" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "w_cap_opening",
        "w_cap_closing",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 34, 48, 61]
    ),
    "E" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "man_days",
        "non_man_days",
        "tot_days",
        "avg_person_worked",
        "days_paid",
        "wages",
        "bonus",
        "contrib_provident_fund",
        "staff_welfare_exp",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 28, 36, 46, 54, 64, 78, 92, 106, 120, 133]
    ),
    "F" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "exp_work_others",
        "exp_building_repair",
        "exp_other_fixed_assets",
        "exp_operating",
        "exp_construction_materials",
        "insurance",
        "rent_machinery",
        "exp_r_and_d",
        "rent_buildings",
        "rent_land",
        "interests_paid",
        "purc_val_goods_resold",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),
    "G" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "receipts_man_services",
        "receipts_non_man_services",
        "val_electricity_sold",
        "val_own_construction",
        "net_balance_goods_resold",
        "rent_income_machinery",
        "var_semi_fin",
        "rent_income_building",
        "rent_income_land",
        "interest_income",
        "sale_val_goods_resold",
        "other_production_subsidies",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 32, 46, 60, 74, 88, 102, 116, 130, 144, 158, 172, 186, 199]
    ),
    "H" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5code",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 21, 28, 31, 45, 59, 73, 86]
    ),
    "I" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_consumed",
        "purchase_val",
        "unit_rate",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 20, 27, 30, 44, 58, 72, 85]
    ),
    "J" => Dict(
        "columns" => [
        "year",
        "factory_id",
        "block",
        "nic5digit",
        "sno",
        "item_code",
        "qty_unit",
        "qty_made",
        "qty_sold",
        "gross_sale_val",
        "excise_duty",
        "sales_tax",
        "others",
        "subsidy",
        "per_unit_sale_val",
        "ex_factory_val",
        "multiplier"
        ],
        "separations" => [4, 12, 13, 18, 21, 28, 30, 44, 58, 72, 86, 100, 114, 128, 142, 156, 169]
    )
)
