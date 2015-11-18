## From Unit to Area Level Models

In later simulation studies we will consider data in which area level statistics
are computed from individual information. From a contextual point of view,
starting from individual information is advantageous in the sense that outlying
areas can be motivated more easily. Also the question for a good estimator for
the sampling variances can be motivated when knowing the underlying individual
model. Hence, I will derive the Fay-Herriot model starting from unit-level.
Consider the following model:
$$
y_{\indexDomain\indexUnit} = \xUnit^\top\beta + \randomEffectIndexed + \samplingErrorUnitIndexed \text{ ,}
$$
where $y_{\indexDomain\indexUnit}$ is the response in domain $\indexDomain$ of
unit $\indexUnit$ with $\indexUnit = 1, \dots, \nUnitIndexed$, where
$\nUnitIndexed$ is the number of units in domain $\indexDomain$.
$\randomEffectIndexed$ is an area specific random effect following (i.i.d.) a
normal distribution with zero mean and $\randomEffectVariance$ as variance
parameter. $\samplingErrorUnitIndexed$ is the remaining deviation from the
model, following (i.i.d.) a normal distribution with zero mean and
$\samplingVariance$ as variance parameter. This unit level model is defined
under strong assumptions, still, assumptions most practitioner are willing to
make which could simplify the identification of the sampling variances under the
area level model.

From this model consider the area statistics $\directStatIndexed = \frac{1}{\nUnitIndexed} \sum_{j = 1}^{\nUnitIndexed}y_{\indexDomain\indexUnit}$, for which an area level model can be derived as:
$$
\directStatIndexed = \xArea^\top\beta + \randomEffectIndexed + \samplingErrorIndexed
$$
Considering the mean in a linear model, it can be expressed as $\bar{y} =
\bar{x}\beta$; the random effect was defined for each area, hence it remains
unaltered for the area level model. The error term in this model can be
expressed as the sampling error and its standard deviation as the (conditional)
standard deviation of the aggregated area statistic, which in this case is a
mean. Hence, $\samplingErrorIndexed \sim N(0, \samplingVarianceIndexed =
\samplingVariance / \nUnitIndexed)$. Under this unit level model a sufficient
estimator for $\samplingVarianceIndexed$ can be derived from estimating
$\samplingVariance$, which can be done robust and non-robust in many ways.
