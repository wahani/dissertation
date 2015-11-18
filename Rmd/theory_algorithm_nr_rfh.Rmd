## Newton Raphson Algorithms

@Sin09 propose a Newton-Raphson algorithm to solve equations \ref{eq:rml_beta} and \ref{eq:rml_theta} iteratively. The iterative equation for $\beta$ is given by:
$$
\beta^{(m+1)} = \beta^{(m)} + \left(\mathbf{X}^\top \mathbf{V}^{-1}\mathbf{D}(\beta^{(m)})\mathbf{X}\right)^{-1}\mathbf{X}^\top\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}}\psi(\mathbf{r}(\beta^{(m)}))
$$
where $\mathbf{D}(\beta) = \frac{\partial \psi(\mathbf{r})}{\partial \mathbf{r}}$ is a diagonal matrix of the same order as $\mathbf{V}$ with elements
$$
D_{jj} =
\begin{cases}
1 \text{ for } |r_j|\leq b\\
0 \text{ else}
\end{cases}
\text{ , } j = 1, \dots, n
$$
The iterative equation for $\theta$ can be stated as:
$$
\theta^{(m+1)} = \theta^{(m)} - \left( \Phi'(\theta^{(m)}) \right)^{-1} \Phi(\theta^{(m)})
$$
where $\Phi'(\theta^m)$ is the derivative of $\Phi(\theta)$ evaluated at $\theta^{(m)}$. The derivative of $\Phi$ is given by \cite[p.53]{Sch12}:
\begin{align}
\label{eq:deriv_Phi_theta}
\frac{\partial\Phi}{\partial\theta_l} = 2\frac{\partial}{\partial\theta_l}\left(\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\right)\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}}\psi(\mathbf{r}) + \tr\left(\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} K\right)
\end{align}
where
$$
\frac{\partial}{\partial\theta_l}\left(\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\right) = \frac{\partial}{\partial\theta_l}(\psi(\mathbf{r})^\top)\mathbf{U}^\frac{1}{2}\mathbf{V}^{-1} + \psi(\mathbf{r})^\top\frac{\partial}{\partial\theta_l}(\mathbf{U}^\frac{1}{2})\mathbf{V}^{-1} - \psi(\mathbf{r})^\top\mathbf{U}^\frac{1}{2}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}.
$$
In @Sch12 adopted this procedure for the Spatial Robust EBLUP and essentially we will follow the same procedure @Sch12[p.74ff.]. Thus we will directly consider the algorithm for the Spatio Temporal model introduced earlier. Since the model considered by @Sin09 contained a block diagonal variance structure where all off-diagonals are zero, equation \ref{eq:deriv_Phi_theta} is valid with respect to the earlier specified variance parameters $\sigma_1^2$ and $\sigma_2^2$ from the spatio temporal Fay Herriot model. The derivative of $\Phi$ with respect to $\rho_1$ and $\rho_2$, however, is different. To adapt the notation, let $\theta = (\sigma_1^2, \sigma_2^2)$ for which equation \ref{eq:deriv_Phi_theta} holds. Let $\rho = (\rho_1, \rho_2)$ denote the vector of correlation parameters as they already have been defined above. Then the iterative equation for $\rho$ is can be stated as:
$$
\rho^{(m+1)} = \rho^{(m)} + \left(\Phi'(\rho^{(m)}\right)^{-1}\Phi(\rho^{(m)})
$$
where the derivative of $\Phi$ with respect to $\rho$ is given by @Sch12[p.76]:

\begin{align*}
\frac{\partial\Phi}{\partial\rho_l} =& 2\frac{\partial}{\partial\rho_l}\left(\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\right)\frac{\partial\mathbf{V}}{\partial\rho_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}}\psi(\mathbf{r})\\
&+ \psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1} \frac{\partial\mathbf{V}}{\partial\rho_l\partial\rho_l} \mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}}\psi(\mathbf{r}) \\
&+ \tr\left(\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\rho_l\partial\rho_l} K - \mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} K\right)
\end{align*}

The partial derivatives of $\mathbf{V}$ with respect to $\theta$ and $\rho$ are given by:

\begin{align*}
\frac{\partial\mathbf{V}}{\partial\sigma_1^2} =& \mathbf{Z}_1\Omega_1(\rho_1)\mathbf{Z}_1^\top \\
\frac{\partial\mathbf{V}}{\partial\sigma_2^2} =& \Omega_2(\rho_2) \\
\frac{\partial\mathbf{V}}{\partial\rho_1} =& -\sigma_1^2\mathbf{Z}_1\Omega_1(\rho_1)\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1}\Omega_1(\rho_1)\mathbf{Z}^\top_1 \\
\frac{\partial\mathbf{V}}{\partial\rho_2} =& \sigma_2^2 \diag\left(\frac{\partial\Omega_{2d}(\rho_2)}{\partial\rho_2}\right) \\
\frac{\partial\mathbf{V}}{\partial\rho_1\partial\rho_1} =& -\sigma_1^2\mathbf{Z}_1\frac{\partial\Omega_1(\rho_1)}{\partial\rho_1}\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1}\Omega_1(\rho_1)\mathbf{Z}^\top_1 \\
&-\sigma_1^2\mathbf{Z}_1\Omega_1(\rho_1)\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1\partial\rho_1}\Omega_1(\rho_1)\mathbf{Z}^\top_1 \\
&-\sigma_1^2\mathbf{Z}_1\Omega_1(\rho_1)\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1}\frac{\partial\Omega_1(\rho_1)}{\partial\rho_1}\mathbf{Z}^\top_1 \\
\frac{\partial\mathbf{V}}{\partial\rho_2\partial\rho_2} =& \text{Needs to be TEXed}
\end{align*}

where

\begin{align*}
\frac{\Omega_1(\rho_1)}{\partial\rho_1} =& -\Omega_1(\rho_1)\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1}\Omega_1(\rho_1) \text{ , }\\
\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1} =& -\mathbf{W} - \mathbf{W}^\top + 2\rho_1\mathbf{W}^\top\mathbf{W} \text{ , } \\
\frac{\partial\Omega_1^{-1}(\rho_1)}{\partial\rho_1\partial\rho_1} =& 2\mathbf{W}^\top\mathbf{W}\\
\frac{\partial\Omega_{2d}(\rho_2)}{\partial\rho_2} =& \frac{1}{1-\rho_2^2}
\left(
\begin{matrix}
0 & 1 & \cdots & \cdots & (T-1)\rho_2^{T-2}\\
1 & 0 & & & (T-2)\rho_2^{T-3} \\
\vdots & & \ddots & & \vdots \\
(T-2)\rho_2^{T-3} &&& 0 & 1 \\
(T-1)\rho_2^{T-2} & \cdots & \cdots & 1 & 0\\
\end{matrix}
\right) + \frac{2\rho_2\Omega_{2d}(\rho_2)}{1-\rho_2^2}
\end{align*}

Having identified all iterative equations the adapted algorithm from @Sch12 is as follows:

- Choose initial values for $\beta^0$, $\theta^0$ and $\rho^0$.
  - Compute $\beta^{(m+1)}$, with given variance parameters and correlation parameters
	- Compute $\theta^{(m+1)}$, with given regression and correlation parameters
	- Compute $\rho^{(m+1)}$, with given variance and regression parameters
	
- Continue step 2 until the following stopping rule holds:

\begin{align*}
	||\beta^{(m+1)}- \beta^{(m)}||^2 <& \text{const} \\
	(\sigma_1^{2(m+1)} - \sigma_1^{2(m)})^2 + (\sigma_2^{2(m+1)} - \sigma_2^{2(m)})^2 + (\rho_1^{(m+1)} - \rho_1^{(m)})^2 + (\rho_2^{(m+1)} - \rho_2^{(m)})^2 <& \text{const}
\end{align*}

