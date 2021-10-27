# Function that applies the state lookup dict.
function fix_state(s::AbstractString)
    # Dictionary with corrections:
    state_lookup = Dict(
        "Arunachal PR." => "Arunachal Pradesh",
        "Andaman & N. Island" => "Andaman & Nicobar",
        "W. Bengal + Sikkim" => "West Bengal + Sikkim",
        "W.Bengal + Sikkim" => "West Bengal + Sikkim",
        "Chhattisgarh" => "Chattisgarh",
        "Uttaranchal" => "Uttarakhand",
        "Lakshadweep#" => "Lakshadweep",
        "Dadar Nagar Haveli" => "Dadra & Nagar Haveli",
        "Andaman- Nicobar" => "Andaman & Nicobar",
        "DVC" => "Damodar Valley Corporation",
        "Pondicheny" => "Puducherry",
        "Pondicherry" => "Puducherry",
        "Chandigarh(U.T.)" => "Chandigarh",
        "Orissa" => "Odisha",
        "Telegana" => "Telangana"
    )


    if haskey(state_lookup, s)
        return state_lookup[s]
    else
        return s
    end
end

# TODO: Add state-change dummy (fx spinning out Telangana from Andhra Pradesh affects numbers in both
# Telangana AND Andhra Pradesh).

# States that changed names during the period:


# States that changed during the period:

# Madhya Pradesh were separated from Chattisgarh in 2000
# Chattisgarh was created in 2000

# Telangana State was formed in 2014.
# Andhra Pradesh were separated from Telangana State in 2014
