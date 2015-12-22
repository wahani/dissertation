## Robust ML Score Functions

@Fel86 studied the robust estimation of linear mixed model parameters.
However, the proposed approach is based on given variance parameters $\theta$
which is why @Sin09 propose an estimation procedure in which robust estimators
for $\beta$ and $\theta$ are solved iteratively. With given robust estimates for
$\beta$ and $\theta$ the estimation of the random effects is straight forward,
the main concern, however, lies with the estimation of robust variance
parameters. Starting from a mixed model:
$$
\mat{y} = \mat{X} \beta + \mat{Z} \re + \mat{e}
$$
where $\mat{y}$ is the response vector with elements $y_i$, $\mat{X}$ the
design matrix, $\re$ the vector of random effects and $\mat{e}$ the
vector of sampling errors. Both error components are assumed to be normally
distributed with $\mat{\re} \sim \Distr{N}(0, \mat{G})$ and $\mat{e}
\sim \Distr{N}(0, \mat{R})$ where $\mat{G}$ and $\mat{R}$ typically
depend on some variance parameters $\theta$. Thus the variance of y is given by
$\mat{V}(\mat{y}) = \mat{V}(\theta) =
\mat{Z}\mat{G}\mat{Z}^\top + \mat{R}$. Maximizing the likelihood of
$\mat{y}$ with respect to $\beta$ and $\theta$ leads to the following
equations:
\begin{align*}
\mat{X}^\top\mat{V}^{-1}\left(\mat{y}-\mat{X}\beta\right) =& 0 \\
\left(\mat{y} - \mat{X}\beta\right)^\top\mat{V}^{-1}          %(y-Xb)'V^-1
\frac{\partial\mat{V}}{\partial\theta_l}                      % dV/dx
\mat{V}^{-1}\left(\mat{y} - \mat{X}\beta\right) -             %V^-1 (y-Xb)
\tr\left(\mat{V}^{-1}\frac{\partial\mat{V}}{\partial\theta_l}\right) =& 0
\end{align*}

where $q$ denotes the number of unknown variance parameters with $l = 1, \dots,
q$. Solving the above equations leads to the ML-estimates for $\beta$ and
$\theta$. To robustify against outliers in the response variable, the residuals 
$\left(\mat{y}-\mat{X}\beta\right)$ are standardized and restricted by some
influence function $\psi(\cdot)$. The standardized residuals are given by
$$
\mat{r} = \mat{U}^{-\frac{1}{2}}
\left(\mat{y}-\mat{X}\beta\right)
$$
where $\mat{U}$ is the matrix of diagonal elements of $\mat{V}$ and thus
also depends on the variance parameters $\theta$. A typical choice for
$\psi(\cdot)$ is Hubers influence function:
$$
\psi(u) = u \min\left(1, \frac{b}{|u|}\right).
$$
A typical choice for $b$ is 1.345. The vector of robustified residuals is
denoted by $\mat{\psi}(\mat{r}) = (\psi(r_1), \dots, \psi(r_{n}))$.
Solving the following robust ML-equations leads to robustified estimators for
$\beta$ and $\theta$:
\begin{align}
\label{eq:rml_beta}
\mat{X}^\top\mat{V}^{-1} \mat{U}^{\frac{1}{2}} \psi(\mat{r}) =& 0 \\
\label{eq:rml_theta}
\Phi_l(\theta) = \psi(\mat{r})^\top\mat{U}^{\frac{1}{2}}\mat{V}^{-1}
\frac{\partial\mat{V}}{\partial\theta_l}
\mat{V}^{-1}\mat{U}^{\frac{1}{2}} \psi(\mat{r}) - \tr\left(K\mat{V}^{-1}\frac{\partial\mat{V}}{\partial\theta_l}\right) =& 0 
\end{align}
where $K$ is a diagonal matrix of the same order as $\mat{V}$ with diagonal
elements $c = \Exp{E}[\psi^2(r)|b]$ where $r$ follows a standard normal
distribution.