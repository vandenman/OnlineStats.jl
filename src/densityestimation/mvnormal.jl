# Author: Josh Day <emailjoshday@gmail.com>

export OnlineFitMvNormal

#------------------------------------------------------------------------------#
#------------------------------------------------------# OnlineFitMvNormal Type
type OnlineFitMvNormal <: ContinuousUnivariateOnlineStat
    d::Distributions.MvNormal
    stats::Distributions.MvNormalStats

    C::CovarianceMatrix

    n::Int64
    nb::Int64
end

function onlinefit{T<:Real}(::Type{MvNormal}, y::Matrix{T})
    n::Int64 = size(y, 2)
    ss = suffstats(MvNormal, y)
    OnlineFitMvNormal(fit(MvNormal, y), ss, CovarianceMatrix(y'), n, 1)
end


#------------------------------------------------------------------------------#
#---------------------------------------------------------------------# update!
function update!(obj::OnlineFitMvNormal, newdata::Matrix)
    newstats = suffstats(MvNormal, newdata)
    n1 = obj.stats.tw
    n2 = newstats.tw
    n = n1 + n2

    s = obj.stats.s + newstats.s
    m = obj.stats.m + n2 / n * (newstats.m - obj.stats.m)

    update!(obj.C, newdata')
    s2 = state(obj.C) * ((n-1) / n)
    tw = n

    obj.d = MvNormal(m, s2)
    obj.stats = Distributions.MvNormalStats(s, m, s2, tw)
    obj.n = n
    obj.nb = obj.nb + 1
end


#------------------------------------------------------------------------------#
#-----------------------------------------------------------------------# state
function state(obj::OnlineFitMvNormal)
    names = [[symbol("μ$i") for i=1:length(obj.d.μ)];
             [symbol("σ$i") for i=1:length(obj.d.μ)];
             :n; :nb]
    estimates = [obj.d.μ; sqrt(diag(obj.d.Σ)); obj.n; obj.nb]
    return([names estimates])
end

vcov(obj::OnlineFitMvNormal) = obj.d.Σ.mat


#------------------------------------------------------------------------------#
#---------------------------------------------------------# Interactive testing
# x1 = randn(3, 100)
# obj = OnlineStats.onlinefit(MvNormal, x1)
# OnlineStats.state(obj)

# x2 = randn(3, 100)
# OnlineStats.update!(obj, x2)
# OnlineStats.state(obj)
# OnlineStats.vcov(obj)
# OnlineStats.state(obj.C) * ((obj.n-1) / obj.n)

# obj = OnlineStats.onlinefit(MvNormal, [x1 x2])
# OnlineStats.state(obj)

# cov([x1 x2]') * (199) / 200

# fit(MvNormal, [x1 x2])

