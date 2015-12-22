## Spatio-Temporal Fay Harriot model

The model stated in equation \ref{eq:FH} has been modified for including
historical information by modelling autocorrelated model errors and also by
allowing for spatial correlation (in the model error). See the discussion in
@Mar13 for more details. @Mar13 allow for both spatial and temporal correlation
in the model errors. Hence the sampling model is (simply) extended to include
historical information:
$$
y_{dt} = \mu_{dt} + e_{dt},
$$
with $d = 1, \dots, D$ and $t = 1, \dots, T$ where $D$ and $T$ are the total
number of areas and time periods respectively. Here $e_{dt} \sim \mathit{N}(0,
\sigma^2_{dt})$ are independent with known variances $\sigma_{dt}^2$. The model
error is composed of a spatial autoregressive process of order 1 (SAR(1)) and an
autoregressive process of order 1 (AR(1)):
$$
\mu_{dt} = x^\top_{dt}\beta + u_{1d} + u_{2dt},
$$
where $u_{1d}$ and $u_{2dt}$ follow a SAR(1) and AR(1) respectively:
$$
u_{1d} = \rho_1 \sum_{l\neq d}w_{d,l} u_{1l} + \epsilon_{1d},
$$
where $|\rho_1| < 1$ and $\epsilon_{1d} \sim \mathit{N}(0, \sigma_1^2)$ are
i.i.d. with $d = 1,\dots, D$. $w_{d, l}$ are the elements of $W$ which is the
row standardized proximity matrix $W^0$. The elements in $W^0$ are equal to 1 if
areas are neighboured and 0 otherwise (an area is not neighboured with itself) -
thus the dimension of $W^0$ is $D\times D$. As stated above $u_{2dt}$ follows an
AR(1):
$$
u_{2dt} = \rho_2 u_{2d, t-1} + \epsilon_{2dt},
$$
where $|\rho_2| < 1$ and $\epsilon_{2dt} \sim \mathit{N}(0, \sigma_2^2)$ are
i.i.d. with $d = 1, \dots, D$ and $t = 1, \dots, T$. Note that $u_{1d}$ and
$u_{2dt}$ and $e_{dt}$ are independent and the sampling error variance
parameters are assumed to be known. The model can then be stated as:
$$
\mathbf{y} = \mathbf{X}\beta + \mathbf{Z}\mathbf{u} + \mathbf{e},
$$
where $\mathbf{y}$ is the $DT\times 1$ vector containing $y_{dt}$ as elements,
$\mathbf{X}$ is the $DT \times p$ design matrix containing the vectors
$x^\top_{dt}$ as rows, $\mathbf{u}$ is the $(D + DT) \times 1$ vector of model
errors and $\mathbf{e}$ the $DT \times 1$ vector of sampling errors $e_{dt}$.
Note that $\mathbf{u} = (u_1^\top, u_2^\top)$ where the $D\times 1$ vector $u_1$
and $DT \times 1$ vector $u_2$ have $u_{1d}$ and $u_{2dt}$ as elements
respectively. Furthermore $\mathbf{Z} = (\mathbf{Z}_1, \mathbf{Z}_2)$ has
dimension $DT \times (D+DT)$, where $\mathbf{Z}_1 = \mathbf{I}_D \otimes
\mathbf{1}_T$ ($\mathbf{I}_D$ denotes a $D\times D$ identity matrix and
$\mathbf{1}_T$ a $1 \times T$ vector of ones) has dimension $DT \times D$ and
$\mathbf{Z}_2$ is a $DT \times DT$ identity matrix.

Concerning the variance of $\mathbf{y}$ first consider the distributions of all
error components. $\mathbf{e} \sim \mathit{N}(\mathbf{0}, \mathbf{V}_e)$ where
$\mathbf{V}_e$ is a diagonal matrix with the known $\sigma^2_{dt}$ on the main
diagonal. $\mathbf{u} \sim \mathit{N}(\mathbf{0}, \mathbf{V}_u(\theta))$ with
the block diagonal covariance matrix $\mathbf{V}_u(\theta) =
\text{diag}(\sigma_1^2\Omega_1(\rho_1), \sigma_2^2\Omega_2(\rho_2))$ where
$\theta = (\sigma_1^2, \rho_1, \sigma_2^2, \rho_2)$.

$$
\Omega_1(\rho_1) = \left((\mathbf{I}_D - \rho_1\mathbf{W})^\top (\mathbf{I}_D - \rho_1\mathbf{W})\right)^{-1}
$$
and follows from the SAR(1) process in the model errors. $\Omega_2(\rho_2)$ has
a block diagonal structure with $\Omega_{2d}(\rho_2)$ denoting the blocks where
the definition of $\Omega_{2d}(\rho_2)$ follows from the AR(1) process:
  $$
    \Omega_{2d}(\rho_2) = \frac{1}{1-\rho_2^2}
    \left(
      \begin{matrix}
      1 & \rho_2 & \cdots & \rho_2^{T-2}& \rho_2^{T-1}\\
      \rho_2 & 1 & & & \rho_2^{T-2} \\
      \vdots & & \ddots & & \vdots \\
      \rho_2^{T-2} &&& 1 & \rho_2 \\
      \rho_2^{T-1} & \rho_2^{T-2} & \cdots & \rho_2 & 1\\
      \end{matrix}
      \right)_{T\times T}
  $$
The variance of $\mathbf{y}$ can thus be stated as:
$$
\mathbb{V}(\mathbf{y}) = \mathbf{V}(\theta) = \mathbf{Z}\mathbf{V}_u(\theta)\mathbf{Z}^\top + \mathbf{V}_e
$$
The BLUE of $\beta$ and BLUP of $\theta$ can be stated as \citep[see][]{Hen75}:
$$
\tilde{\beta}(\theta) = \left(\mathbf{X}^\top \mathbf{V}^{-1}(\theta) \mathbf{X} \right)^{-1} \mathbf{X}^\top \mathbf{V}^{-1}(\theta) \mathbf{y}
$$
$$
\tilde{u}(\theta) = \mathbf{V}_u(\theta) \mathbf{Z}^\top \mathbf{V}^{-1}(\theta) \left(\mathbf{y} - \mathbf{X}\tilde{\beta}(\theta)\right)
$$
Hence the BLUP of $u_1$ and $u_2$ can be stated as:
$$
\tilde{u}_1(\theta) = \sigma_1^2 \Omega_1(\rho_1) \mathbf{Z}^\top \mathbf{V}^{-1}(\theta) \left(\mathbf{y} - \mathbf{X}\tilde{\beta}(\theta)\right)
$$
$$
\tilde{u}_2(\theta) = \sigma_2^2 \Omega_2(\rho_2) \mathbf{Z}^\top \mathbf{V}^{-1}(\theta) \left(\mathbf{y} - \mathbf{X}\tilde{\beta}(\theta)\right)
$$
Estimating $\theta$ leads to the EBLUE for $\beta$ and EBLUPs for $u_1$ and
$u_2$, hence an predictor for the area characteristic $\mu_{dt}$ is given by:
$$
\hat{\mu}_{dt} = x_{dt}^\top \hat{\beta} + \hat{u}_{1d} + \hat{u}_{2dt}
$$
@Mar13 use a restricted maximum likelihood method to estimate $\theta$
  independently of $\beta$. An open question is if this approach can be applied
  for the robust spatio-temporal model. Thus we will continue with the
  discussion of robust small area methods.