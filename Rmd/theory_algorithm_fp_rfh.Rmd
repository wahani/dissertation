## Fixed Point Algorithms

Inspired by: Chatrchi Golshid (2012): Robust Estimation of Variance Components
in Small Area Estimation, Master-Thesis, Ottawa, Ontario, Canada: p. 16ff.:

\begin{quote}
The fixed-point iterative method relies on the fixed-point theorem:
"If g(x) is a continuous function for all $x \in [a; b]$, then $g$ has a fixed
point in $[a; b]$." This can be proven by assuming that $g(a)\geq a$ and
$g(b)\leq b$. Since $g$ is continuous the intermediate value theorem guarantees
that there exists a $c$ such that $g(c) = c$.
\end{quote}

Starting from equation \ref{eq:rml_theta} where $\theta = (\sigma_1^2,
\sigma_2^2)$ and $(\rho_1, \rho_2)$ are assumed to be known, we can rewrite the
equation such that:

\begin{align}
\label{eq:rml_theta_fp}
\Phi_l(\theta) = \psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) - \tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)\right) =& 0
\end{align}

Note that because the matrix $\mathbf{V}_e$ is assumed to be known for the FH
model, it can be omitted. Let $\mathbf{0}_{r\times c}$ define a matrix filled
with 0's of dimension $(r \times c)$ than:

\begin{align*}
\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top =& \mathbf{Z}\left(\begin{matrix}
\sigma_1^2\Omega_1 & \mathbf{0}_{D\times DT}\\
\mathbf{0}_{DT\times D} &  \sigma_2^2\Omega_2
\end{matrix}\right)\mathbf{Z}^\top \\
=& \mathbf{Z}
\left[
\sigma_1^2\left(\begin{matrix}
\Omega_1 & \mathbf{0}_{D\times DT} \\
\mathbf{0}_{DT\times D} &  \mathbf{0}_{DT\times DT}
\end{matrix}\right) + 
\sigma_2^2\left(\begin{matrix}
\mathbf{0}_{D\times D} & \mathbf{0}_{D\times DT} \\
\mathbf{0}_{DT\times D} & \Omega_2
\end{matrix}\right)
\right]\mathbf{Z}^\top \\
=& \left(\begin{matrix}\mathbf{Z}\bar{\Omega}_1\mathbf{Z}^\top & \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top\end{matrix}\right)
\left(\begin{matrix}
\sigma_1^2 \\
\sigma_2^2
\end{matrix}\right)
\end{align*}

Thus equation \ref{eq:rml_theta_fp} can be rewritten to:

\begin{align*}
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) = \tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \left(\begin{matrix}\mathbf{Z}\bar{\Omega}_1\mathbf{Z}^\top & \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top\end{matrix}\right)\left(\begin{matrix}
\sigma_1^2 \\
\sigma_2^2
\end{matrix}\right)\right)
\end{align*}

Let
$$
\left(\begin{matrix}
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_1^2}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) \\
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_2^2}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r})
\end{matrix}\right)
= a(\theta) \text{ ,}
$$
then
$$
\theta = \left(\begin{matrix}
\sigma_1^2 \\
\sigma_2^2
\end{matrix}\right) = A(\theta)^{-1} a(\theta) \text{ ,}
$$
where
\begin{align*}
A(\theta) = \left(\begin{matrix}
\tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_1^2} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \mathbf{Z}\bar{\Omega}_1\mathbf{Z}^\top \right) &
\tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_1^2} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top \right) \\
\tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_2^2} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \mathbf{Z}\bar{\Omega}_1\mathbf{Z}^\top \right) &
\tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_2^2} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top \right)
\end{matrix}\right) \text{.}
\end{align*}
So, the fixed point algorithm can be presented as follows:
$$
\theta^{m+1} = A(\theta^{(m)})^{-1} a(\theta^{(m)})
$$

At this time the fixed-point algorithm for $\theta = (\sigma_1^2, \sigma_2^2)$ will replace the corresponding step in Issue 1.

### N-S: Fixed-Point-Algorithm - Spatial Correlation

To extend the above algorithm to not only being used for the estimation of
$\theta = (\sigma_1^2, \sigma_2^2)$ but also for the spatial correlation
parameter $\rho_1$ reconsider:

\begin{eqnarray}
\label{eq:zVuZ_rho1_1}
\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top &=& \mathbf{Z}\left(\begin{matrix}
\sigma_1^2\Omega_1 & \mathbf{0}_{D\times DT}\\
\mathbf{0}_{DT\times D} &  \sigma_2^2\Omega_2
\end{matrix}\right)\mathbf{Z}^\top
\end{eqnarray}

and the specification of $\Omega_1(\rho_1) = \left((I-\rho_1\mathbf{W})^\top(I-\rho_1\mathbf{W})\right)^{-1}$:

\begin{align}
\sigma_1^2\Omega_1(\rho_1) &= \sigma_1^2\Omega_1\Omega_1(I-\rho_1\mathbf{W})^\top(I-\rho_1\mathbf{W}) \notag\\
&= \sigma_1^2\left(\Omega_1\Omega_1 -\rho_1\Omega_1\Omega_1\mathbf{W}^\top -\rho_1\Omega_1\Omega_1\mathbf{W} + \rho_1^2\Omega_1\Omega_1\mathbf{W}^\top\mathbf{W}\right) \notag\\
&= \sigma_1^2\left(\Omega_1\Omega_1 -\rho_1\Omega_1\Omega_1\mathbf{W}^\top\right) +\rho_1 \left(-\sigma_1^2\Omega_1\Omega_1\mathbf{W} + \sigma_1^2\rho_1\Omega_1\Omega_1\mathbf{W}^\top\mathbf{W}\right) \label{eq:zVuZ_rho1_2}
\end{align}

Thus equation \ref{eq:zVuZ_rho1_1} can be rewritten as:

\begin{align*}
\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top
&=\mathbf{Z}
\Biggr[
\sigma_1^2\left(\begin{matrix}
\Omega_1\Omega_1 -\rho_1\Omega_1\Omega_1\mathbf{W}^\top & \mathbf{0}_{D\times DT}\\
\mathbf{0}_{DT\times D} &  \mathbf{0}_{DT\times DT}
\end{matrix}\right)\\
&+\rho_1\left(\begin{matrix}
-\sigma_1^2\Omega_1\Omega_1\mathbf{W} + \sigma_1^2\rho_1\Omega_1\Omega_1\mathbf{W}^\top\mathbf{W} & \mathbf{0}_{D\times DT}\\
\mathbf{0}_{DT\times D} &  \mathbf{0}_{DT\times DT}
\end{matrix}\right)\\
&+\sigma_2^2\left(\begin{matrix}
\mathbf{0}_{D\times D} & \mathbf{0}_{D\times DT}\\
\mathbf{0}_{DT\times D} & \Omega_2
\end{matrix}\right)
\Biggr]
\mathbf{Z}^\top \\
&=\left(\begin{matrix}\mathbf{Z}\bar{\Omega}_{1, \sigma_1^2}\mathbf{Z}^\top & 
\mathbf{Z}\bar{\Omega}_{1, \rho_1}\mathbf{Z}^\top & \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top\end{matrix}\right)
\left(\begin{matrix}
\sigma_1^2 \\
\rho_1 \\
\sigma_2^2
\end{matrix}\right)
\end{align*}

Thus equation \ref{eq:rml_theta_fp} can be rewritten (analogously as above) to:

\begin{eqnarray*}
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) = \tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1} \left(\begin{matrix}\mathbf{Z}\bar{\Omega}_{1, \sigma_1^2}\mathbf{Z}^\top & 
\mathbf{Z}\bar{\Omega}_{1, \rho_1}\mathbf{Z}^\top & \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top\end{matrix}\right)
\left(\begin{matrix}
\sigma_1^2 \\
\rho_1 \\
\sigma_2^2
\end{matrix}\right)\right)
\end{eqnarray*}

Let

$$
\left(\begin{matrix}
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_1^2}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) \\
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\rho_1}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) \\
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\sigma_2^2}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r})
\end{matrix}\right)
= a(\theta) \text{ ,}
$$

then

$$
\theta = \left(\begin{matrix}
\sigma_1^2 \\
\rho_1 \\
\sigma_2^2
\end{matrix}\right) = A(\theta)^{-1} a(\theta) \text{ ,}
$$
where
\begin{align*}
A(\theta) = \left(\begin{matrix}
\tr\left(\gamma(\sigma_1^2) \mathbf{Z}\bar{\Omega}_{1,\sigma_1^2} \mathbf{Z}^\top \right) & \tr\left(\gamma(\sigma_1^2) \mathbf{Z}\bar{\Omega}_{1,\rho_1} \mathbf{Z}^\top \right) &
\tr\left(\gamma(\sigma_1^2) \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top \right) \\
\tr\left(\gamma(\rho_1) \mathbf{Z}\bar{\Omega}_{1,\sigma_1^2} \mathbf{Z}^\top \right) & \tr\left(\gamma(\rho_1) \mathbf{Z}\bar{\Omega}_{1,\rho_1} \mathbf{Z}^\top \right) &
\tr\left(\gamma(\rho_1) \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top \right) \\
\tr\left(\gamma(\sigma_2^2) \mathbf{Z}\bar{\Omega}_{1,\sigma_1^2} \mathbf{Z}^\top \right) & \tr\left(\gamma(\sigma_2^2) \mathbf{Z}\bar{\Omega}_{1,\rho_1} \mathbf{Z}^\top \right) &
\tr\left(\gamma(\sigma_2^2) \mathbf{Z}\bar{\Omega}_2\mathbf{Z}^\top \right)
\end{matrix}\right)
\end{align*}

and $\gamma(\theta_l) = K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta_l} (\mathbf{Z}\mathbf{V}_u\mathbf{Z}^\top)^{-1}$

### More on the Fixed Point

Inspired by: Chatrchi Golshid (2012): Robust Estimation of Variance Components
in Small Area Estimation, Master-Thesis, Ottawa, Ontario, Canada: p. 16ff.:

\begin{quote}
The fixed-point iterative method relies on the fixed-point theorem: "If g(x) is
a continuous function for all $x \in [a; b]$, then $g$ has a fixed point in $[a;
b]$." This can be proven by assuming that $g(a)\geq a$ and $g(b)\leq b$. Since
$g$ is continuous the intermediate value theorem guarantees that there exists a
$c$ such that $g(c) = c$.
\end{quote}

Starting from equation \ref{eq:rml_theta} where $\theta = \randomEffectVariance$
we can rewrite the equation such that:

\begin{align}
\label{eq:rml_theta_fp}
\Phi(\theta) = \aFH - \tr\left(K\mathbf{V}^{-1}\frac{\partial\mathbf{V}}{\partial\theta} (\mathbf{Z}\mathbf{G}\mathbf{Z}^\top)^{-1} (\mathbf{Z}\mathbf{G}\mathbf{Z}^\top)\right) =& 0
\end{align}

Note that because the matrix $\mathbf{R}$ is assumed to be known for the FH model, it can be omitted. Note that under the simple Fay-Herriot Model $\mathbf{Z}\mathbf{G}\mathbf{Z}^\top = \randomEffectVariance\IdentityMatrix$, where $\IdentityMatrix$ is a $(\nDomains \times \nDomains)$ identity matrix. Furthermore $\frac{\partial\mathbf{V}}{\partial\theta} = \IdentityMatrix$. Thus equation \ref{eq:rml_theta_fp} can be rewritten to:

\begin{align*}
\psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r}) = \tr\left(K\mathbf{V}^{-1}\mathbf{G}^{-1} \randomEffectVariance \right)
\end{align*}

This can be solved for the fixed Point and is directly presented in algorithmic
notation, such that:
$$
\theta^{m+1} = A(\theta^{(m)})^{-1} a(\theta^{(m)}) \text{ ,}
$$
where 
$$
A(\theta) = \tr\left(K\mathbf{V}^{-1}\mathbf{G}^{-1} \right)
$$
and
$$a(\theta) = \psi(\mathbf{r})^\top\mathbf{U}^{\frac{1}{2}}\mathbf{V}^{-1}\mathbf{V}^{-1}\mathbf{U}^{\frac{1}{2}} \psi(\mathbf{r})
$$

