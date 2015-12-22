# Area Level Models

Area Level Models in Small Area Estimation play an important role in the
production of reliable domain estimates.

- They can be used even if unit level observations are not accessible. 
- In a model based estimation it is largely unsolved to incorporate design
weights. Area level models can be used to start from a direct design based
estimator.
- Unit level models often have problems with heterogeneity. An assumption, for
example, for unit level data is that the error terms of a model are
homescedastic given the random effects. This assumption is often not plausible
and may call for more complex assumptions on the variance structure of the data.
However such structures may or may not be known and cannot be modelled easily.
This can also lead to computationally demanding procedures.

Given these considerations the most important factor to choose cadidate models
is the availability of data. Very often there is not much of a choice but rather
a decission given the available information. And given the availability of unit
level data, the obvious choice is to consider a model which can use such
information. Only if that fails for one of the above reasons can an area level
model be of interest.


## The Fay Herriot Model

A frequently used model in Small Area Estimation is a model introduced by
@Fay79. It starts on the area level and is used in small area estimation for
research on area-level. It is build on a sampling model:
$$
\si{\tilde{y}} = \si{\theta} + \si{e},
$$
where $\si{\tilde{y}}$ is a direct estimator of a statistic of
interest $\si{\theta}$ for an area $i$ with
$i = 1, \dots, D$ and $D$ being the number of areas. The sampling error $\si{e}$ 
is assumed to be independent and normally distributed with known variances $\sige$, i.e.
$\si{e}|\si{\theta} \sim \Distr{N}(0, \sige)$. The model is modified with the linking model by
assuming a linear relationship between the true area statistic
$\si{\theta}$ and some diterministic auxiliary variables $\si{x}$:
$$
\si{\theta} = \si{x}^\top \beta + \si{\re}
$$
Note that $\si{x}$ is a vector containing area-level (aggregated) information
for $P$ variables and $\beta$ is a vector ($1\times P$) of
regression coefficients describing the (linear) relationship. The model errors
$\re$ are assumed to be independent and normally distributed,
i.e. $\re_i \sim \Distr{N}(0, \sigre)$
furthermore $e_i$ and $\re_i$ are assumed to be
independent. Combining the sampling and linking model leads to:
\begin{align}
\label{eq:FH}
\tilde{y}_i = x_i^\top \beta + \re_i + e_i.
\end{align}