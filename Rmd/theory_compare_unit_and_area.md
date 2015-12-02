## From Unit to Area Level Models

In later simulation studies we will consider data in which area level statistics
are computed from individual information. From a contextual point of view, 
starting from individual information is advantageous in the sense that outlying 
areas can be motivated more easily. Also the question for a good estimator for 
the sampling variances can be motivated when knowing the underlying individual 
model. Hence, I will derive the Fay-Herriot model starting from unit-level. 
Consider the following model:
$$
\sij{y} = x_i^\top\beta + \re + e_i \text{ ,}
$$
where $\sij{y}$ is the response in domain $i$ of unit $j$ with $i = 1, \dots,
\si{n}$, where $\si{n}$ is the number of units in domain $i$. $\re$ is an area
specific random effect following (i.i.d.) a normal distribution with zero mean
and $\sigre$ as variance parameter. $\sij{e}$ is the remaining deviation from
the model, following (i.i.d.) a normal distribution with zero mean and $\sige$
as variance parameter. This unit level model is defined under strong
assumptions, still, assumptions most practitioner are willing to make which
could simplify the identification of the sampling variances under the area level
model.

From this model consider the area statistics $\tilde{y}_i = \frac{1}{n_j}
\sum_{j = 1}^{\si{n}}\sij{y}$, for which an area level model can be derived as:
$$
\tilde{y}_i = \si{x}^\top\beta + \si{\re} + \si{e}
$$
Considering the mean in a linear model, it can be expressed as $\bar{y} = 
\bar{x}\beta$; the random effect was defined for each area, hence it remains 
unaltered for the area level model. The error term in this model can be 
expressed as the sampling error and its standard deviation as the (conditional) 
standard deviation of the aggregated area statistic, which in this case is a 
mean. Hence, $\si{e} \sim \Distr{N}(0, \sige = \sigma^2_e / \si{n})$. Under this
unit level model a sufficient estimator for $\sige$ can be derived from
estimating $\sige$, which can be done robust and non-robust in many ways.
