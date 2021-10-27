# VISUALIZE:
using Gadfly
using Statistics
using ShiftedArrays

# How many products in each year:
output_summary = @chain outputs_df begin
    # Get the number of products produced by each factory each year:
    groupby(_, [:year, :factory_id, :code_scheme])
    @combine _ :n_products = length(unique(:item_code))
    # Get summary stats for each year:
    groupby(_, [:year, :code_scheme])
    @combine _ begin
        :mean_products = mean(:n_products)
        :median_products = median(:n_products)
        :sd_products = std(:n_products)
    end
end


# How many times are factories observed:
obs_per_factory = @chain outputs_df begin
    # Get the number of products produced by each factory each year:
    groupby(_, [:factory_id, :code_scheme])
    @combine _ :n_obs = length(unique(:year))
end
plot(obs_per_factory, x = :n_obs, Geom.histogram)

obs_summary = @chain obs_per_factory begin
    # Get summary stats for:
    groupby(_, :code_scheme)
    @combine _ begin
        :mean_obs = mean(:n_obs)
        :median_obs = median(:n_obs)
        :sd_obs = std(:n_obs)
    end
end

# How does products change?
# - discrete products (set-diff between years)
product_sets = @chain outputs_df begin
    # Get the number of products produced by each factory each year:
    groupby(_, [:year, :factory_id, :code_scheme])
    @combine _ :product_set = Set(:item_code)
    sort(_, :year)
    groupby(_, [:factory_id, :code_scheme])
    @combine _ begin
        :product_set = :product_set
        :lag_product_set = lag(:product_set)
        :year = :year
        :lag_year = lag(:year)
    end
    dropmissing(_, :lag_product_set)
    @rtransform _ :productdiff = setdiff(:product_set, :lag_product_set)
    @rtransform _ :n_productdiff = :productdiff |> length
end

# Amount of product-represented value (i.e. value-weighted setdiff )
# Approach: expand :productdiff to rows, multiply them by product output
# sum it, and divide it by total factory output.
# First, get the total product output values for each factory in each year:
total_outputs_df = @chain outputs_df begin
    # Get
    groupby(_, [:factory_id, :year])
    @combine _ begin
        :total_gross_sale_val = sum(:gross_sale_val)
        :total_ex_factory_val = sum(:ex_factory_val)
    end
end

# Second, get the output-weighted product diff:
product_diff_sums = @chain product_sets begin
    @select(_, :factory_id, :year, :lag_year, :productdiff, :n_productdiff)
    @rtransform _ :productdiff_vec = collect(:productdiff)
    flatten(_, :productdiff_vec)
    # The productdiffs are products that is produced in the previous observation
    # year by a factory, but not in the current one. I need to add sale values to
    # these observations. I join the output observations by the lagged year to get this:
    # Add product output values to the expanded rows:
    leftjoin(_, @select(outputs_df, :factory_id, :year, :item_code,
                        :gross_sale_val, :ex_factory_val),
             on = [:factory_id, :lag_year => :year, :productdiff_vec => :item_code])
    # Group the data by factory and year, and sum the values -> this gives
    # a value represent how much of value in products were produced last year
    # but is not on the books this year.
 #   groupby(_, [:factory_id, :year])
 #   @combine _ begin
 #        :productdiff_gross_sale_val = sum(:gross_sale_val)
 #        :productdiff_ex_factory_val = sum(:ex_factory_val)
 #   end
end


# Third: join the total_outputs_df with the product_diff_sum and get share of
# output not on the books anymore (remember to join by lag-year)
product_sets_flat = @chain product_sets begin
    @select(_, :factory_id, :year, :lag_year, :productdiff, :n_productdiff)
    @rtransform _ :productdiff_vec = collect(:productdiff)
    @rtransform _ :productdiff_vec = length(:productdiff_vec) == 0 ? ["None"] : :productdiff_vec
    flatten(_, :productdiff_vec)
end

outputs_df
    # NOTE: something is wrong

dropmissing(product_sets_flat, :lag_year)

temp_outputs_df = @select(outputs_df, :factory_id, :year, :item_code, :gross_sale_val, :ex_factory_val)

rename!(temp_outputs_df, :year => :lag_year, :item_code => :productdiff_vec)

temp_outputs_df.productdiff_vec = String.(temp_outputs_df.productdiff_vec)

df = leftjoin(product_sets_flat, @select(outputs_df, :factory_id, :year, :item_code,
                                         :gross_sale_val, :ex_factory_val))

@select(product_sets_flat,
