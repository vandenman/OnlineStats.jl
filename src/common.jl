#-----------------------------------------# generic: nobs, update!, copy, merge

nobs(o::OnlineStat) = o.n

update!{T<:Real}(o::OnlineStat, y::Vector{T}) = (for yi in y; update!(o, yi); end)

Base.copy(o::OnlineStat) = deepcopy(o)

function Base.merge(o1::OnlineStat, o2::OnlineStat)
    o1copy = copy(o1)
    merge!(o1copy, o2)
    o1copy
end


#------------------------------------------------------------------------# Show
# temporary fix for the "how to print" problem... lets come up with something nicer
mystring(f::Float64) = @sprintf("%f", f)
mystring(x) = string(x)

function Base.show(io::IO, o::OnlineStat)
    snames = statenames(o)
    svals = state(o)

    println(io, "Online ", string(typeof(o)))
    for (i, sname) in enumerate(snames)
        @printf(io, " * %8s:  %s\n", sname, mystring(svals[i]))
    end
end


#------------------------------------------------------------------------# DataFrame
function DataFrame(o::OnlineStat; addFirstRow::Bool = true)
    s = state(o)
    df = DataFrame(map(typeof, s), statenames(o), 0)
    if addFirstRow
        push!(df, s)
    end
    df
    # df = convert(DataFrame, state(o)')
    # names!(df, statenames(o))
end

Base.push!(df::DataFrame, o::OnlineStat) = push!(df, state(o))


# some nice helper functions to extract stuff from dataframes...
# this might exist already in dataframes... didn't look too hard

function getnice(df::DataFrame, s::Symbol)
    data = df[s]
    makenice(data)
end

makenice{T<:Vector}(da::DataArray{T}) = hcat(da...)'
makenice{T<:Number}(da::DataArray{T}) = DataArrays.array(da)



#------------------------------------------------------------# DistributionStat
statenames(o::DistributionStat) = [:dist, :nobs]
state(o::DistributionStat) = [o.d, o.n]

params(o::DistributionStat) = params(o.d)
succprob(o::DistributionStat) = succprob(o.d)
failprob(o::DistributionStat) = failprob(o.d)
scale(o::DistributionStat) = scale(o.d)
location(o::DistributionStat) = location(o.d)
shape(o::DistributionStat) = shape(o.d)
rate(o::DistributionStat) = rate(o.d)
ncategories(o::DistributionStat) = ncategories(o.d)
ntrials(o::DistributionStat) = ntrials(o.d)
dof(o::DistributionStat) = dof(o.d)

mean(o::DistributionStat) = mean(o.d)
var(o::DistributionStat) = var(o.d)
std(o::DistributionStat) = std(o.d)
median(o::DistributionStat) = median(o.d)
mode(o::DistributionStat) = mode(o.d)
modes(o::DistributionStat) = modes(o.d)
skewness(o::DistributionStat) = skewness(o.d)
kurtosis(o::DistributionStat) = kurtosis(o.d)
isplatykurtic(o::DistributionStat) = isplatykurtic(o.d)
ismesokurtic(o::DistributionStat) = ismesokurtic(o.d)
entropy(o::DistributionStat) = entropy(o.d)
mgf(o::DistributionStat) = mgf(o.d)
cf(o::DistributionStat) = cf(o.d)

insupport(o::DistributionStat) = insupport(o.d)
pdf(o::DistributionStat) = pdf(o.d)
logpdf(o::DistributionStat) = logpdf(o.d)
loglikelihood(o::DistributionStat) = loglikelihood(o.d)
cdf(o::DistributionStat) = cdf(o.d)
logcdf(o::DistributionStat) = logcdf(o.d)
ccdf(o::DistributionStat) = ccdf(o.d)
logccdf(o::DistributionStat) = logccdf(o.d)
quantile(o::DistributionStat) = quantile(o.d)
cquantile(o::DistributionStat) = cquantile(o.d)
invlogcdf(o::DistributionStat) = invlogcdf(o.d)
invlogccdf(o::DistributionStat) = invlogccdf(o.d)

rand(o::DistributionStat) = rand(o.d)
rand(o::DistributionStat, n_or_dims) = rand(o.d, n_or_dims)
rand!(o::DistributionStat, arr) = rand!(o.d, arr)
# whew!
