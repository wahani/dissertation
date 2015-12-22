### Pseudo Linearization

This is the representation of the pseudo linear representation of the FH model.
As it is introduced in @Cha11 and @Cha14.

Presenting the FH in pseudo linear form means to present the area means as a
weighted sum of the response vector $y$. The FH model is given by

\begin{align}
\theta_i = \gamma_i y_i + (1 - \gamma_i) x_i^\top \beta 
\end{align}

where $\gamma_i = \frac{\sigma^2_u}{\sigma^2_u + \sigma^2_e}$, so it can be
represented as

$$
\theta_i = w_i^\top y
$$

where 

$$
w_i^\top = \gamma_i \mathbf{I}^\top_i + (1 - \gamma_i) x_i^\top \mathbf{A}
$$

and 

$$
\mathbf{A} = \left(\mathbf{X} \mathbf{V}^{-1} \mathbf{U}^\frac{1}{2} \mathbf{W} \mathbf{U}^{-\frac{1}{2}} \mathbf{X} \right)^{-1} \mathbf{X}^\top \mathbf{V}^{-1} \mathbf{U}^\frac{1}{2} \mathbf{W} \mathbf{U}^{-\frac{1}{2}}
$$

with 

$$
\mathbf{W} = Diag(w_j)\text{, with } j = 1, \dots, n
$$

and

$$
w_j = \frac{\psi\left( u_j^{-\frac{1}{2}} ( y_j - x_j^\top\beta ) \right)}{ u_j^{-\frac{1}{2}} ( y_j - x_j^\top\beta }
$$

Note that if $\psi$ is the identity or equally a huber influence function with a
large smoothing constant, \ie $\inf$:

$$
\mathbf{A} = \left(\mathbf{X} \mathbf{V}^{-1} \mathbf{X} \right)^{-1} \mathbf{X}^\top \mathbf{V}^{-1}
$$

The fixed point function derived from these formulas are the following:

$$
\beta = \mathbf{A}(\beta) y
$$


This whole thing can also be addapted to define the random effects. If we define
the model in an alternative way:

\begin{align}
\theta_i = x_i^\top \beta + u_i
\end{align}

we can restate it similarly to the above as:

$$
\theta_i = w_{s, i}^\top \mat{y}
$$

$$
\theta = \mat{W}\mat{y}
$$

where $\mat{W}$ is the matrix containing the weights, i.e. 

$$
\mat{W} = \Paran{
  \begin{matrix}
  w_{s, 1}^\top\\
  \vdots \\
  w_{s, D}^\top\\
  \end{matrix}
} = \mat{X}\mat{A} + \mat{B} \Paran{\mat{I} - \mat{X} \mat{A}}
$$

with 

$$
w_{s, i}^\top = x_i^\top \mathbf{A} + 
  z_i^\top \mathbf{B} \Paran{\mat{I} - x_i^\top \mathbf{A}}
$$

where $\mathbf{A}$ is defined as above and 

$$
\mathbf{B} = 
\left(
  \mathbf{V}_e^{-\frac{1}{2}} \mathbf{W}_2 \mathbf{V}_e^{-\frac{1}{2}} +
  \mathbf{V}_u^{-\frac{1}{2}} \mathbf{W}_3 \mathbf{V}_u^{-\frac{1}{2}}
\right)^{-1} 
\mathbf{V}_e^{-\frac{1}{2}} \mathbf{W}_2 \mathbf{V}_e^{-\frac{1}{2}}
$$

with $\mathbf{W}_2$ as diagonal matrix with ith component:

$$
w_{2i} = 
\frac{
  \psi\{\sigma^{-1}_{e, i} (y_i - x_i^\top \beta - u_i)\}
}{
  \sigma^{-1}_{e, i} (y_i - x_i^\top \beta - u_i)
}
$$

and with $\mathbf{W}_3$ as diagonal matrix with ith component:

$$
w_{3i} = \frac{
  \psi\{\sigma_u^{-1} u_i\}
}{
  \sigma_u^{-1} u_i
}
$$

The fixed point function derived from these formulas are the following:

\begin{align*}
u &= \mathbf{B}(u)\left(\mathbf{I} - \mathbf{X}\mathbf{A}\right)y \\
  &= \mathbf{B}(u)\left(y - \mathbf{X}\beta\right)
\end{align*}

Given the weights we have a weighted mean, for which we need the MSE:

$$
\Exp{MSE}\Paran{\hat{\theta}|\mat{X}, \beta, \mat{\re}} 
  = \Exp{E}\Paran{\Paran{\hat{\theta} - \theta}^2}
  = \Exp{V}\Paran{\hat{\theta}} + \Exp{E}\Paran{\hat{\theta} - \theta}^2
$$

$$
\Exp{V}\Paran{\hat{\theta}} 
  = \Exp{V}\Paran{\mat{Wy}}
  = \mat{W}^2 \Exp{V}\Paran{\mat{y}}
  = \mat{W}^2 \Paran{\sigma_{e, 1}^2, \dots, \sigma_{e, D}^2}^\top
$$

$$
\Exp{E}\Paran{\hat{\theta} - \theta}
  = \Exp{E}\Paran{\mat{Wy}} - \Exp{E}\Paran{\theta}
  = \mat{W} \Exp{E}\Paran{\mat{y}} - \Exp{E}\Paran{\theta}
  = \mat{W} \theta - \theta
$$





