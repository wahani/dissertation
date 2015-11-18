# Robust ML Score Functions

In @Fel86 studied the robust estimation of linear mixed model parameters.
However, the proposed approach is based on given variance parameters $\theta$
which is why @Sin09 propose an estimation procedure in which robust estimators
for $\beta$ and $\theta$ are solved iteratively. With given robust estimates for
$\beta$ and $\theta$ the estimation of the random effects is straight forward,
the main concern, however, lies with the estimation of robust variance
parameters. Starting from a mixed model:
$$
\mathbf{y} = \mathbf{X} \beta + \mathbf{Z} \RandomEffect + \mathbf{e}
$$
where $\mathbf{y}$ is the vector of response variables $y_i$, $\mathbf{X}$ the
design matrix, $\RandomEffect$ the vector of random effects and $\mathbf{e}$ the
vector of sampling errors. Both error components are assumed to be normally
distributed with $\mathbf{u} \sim \mathit{N}(0, \mathbf{G})$ and $\mathbf{e}
\sim \mathit{N}(0, \mathbf{R})$ where $\mathbf{G}$ and $\mathbf{R}$ typically
depend on some variance parameters $\theta$. Thus the variance of y is given by
$\mathbb{V}(\mathbf{y}) = \mathbf{V}(\theta) =
\mathbf{Z}\mathbf{G}\mathbf{Z}^\top + \mathbf{R}$. Maximizing the likelihood of
$\mathbf{y}$ with respect to $\beta$ and $\theta$ leads to the following
equations:
\begin{align*}
\mathbf{X}^\top\mathbf{V}^{-1}\left(\mathbf{y}-\mathbf{X}\beta\right) =& 0 \\
\left(\mathbf{y}-\mathbf{X}\beta\right)^\top\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\left(\mathbf{y}-\mathbf{X}\beta\right) - \tr\left(\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\right) =& 0 \text{ , } l = 1, \dots, q
\end{align*}

where $q$ denotes the number of unknown variance parameters. Solving the above
equations leads to the ML-estimates for $\beta$ and $\theta$. To robustify 
against outliers in the response variable, the residuals 
$\left(\mathbf{y}-\mathbf{X}\beta\right)$ are standardized and restricted by 
some influence function $\psi(\cdot)$. The standardized residuals are given by
$$
\mathbf{r} = \mathbf{U}^{-\frac{1}{2}}
\left(\mathbf{y}-\mathbf{X}\beta\right)
$$
where $\mathbf{U}$ is the matrix of diagonal elements of $\mathbf{V}$ and thus
also depends on the variance parameters $\theta$. A typical choice for
$\psi(\cdot)$ is Hubers influence function:
$$
\psi(u) = u \min\left(1, \frac{b}{|u|}\right).
$$
A typical choice for $b$ is 1.345. The vector of robustified residuals is
denoted by $\mathbf{\psi}(\mathbf{r}) = (\psi(r_1), \dots, \psi(r_{n}))$.
Solving the following robust ML-equations leads to robustified estimators for
$\beta$ and $\theta$:
\begin{align}
\label{eq:rml_beta}
\mathbf{X}^\top\mathbf{V}^{-1} \mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) =& 0 \\
\label{eq:rml_theta}
\Phi_l(\theta) = \psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) - \tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\right) =& 0 \text{ , } l = 1, \dots, q
\end{align}
where $K$ is a diagonal matrix of the same order as $\mathbf{V}$ with diagonal
elements $c = \mathbb{E}[\psi^2(r)|b]$ where $r$ follows a standard normal
distribution.
