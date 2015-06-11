# Mean squared error
## pseudo linear FH

This is the representation of the pseudo linear representation of the FH model. As it is introduced in @Cha11 and @Cha14.

Presenting the FH in pseudo linear form means to present the area means as a weighted sum of the response vector $y$. The FH model is given by

\begin{align}
\theta_i = \gamma_i y_i + (1 - \gamma_i) x_i^\top \beta 
\end{align}

where $\gamma_i = \frac{\sigma^2_u}{\sigma^2_u + \sigma^2_e}$, so it can be represented as

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

Note that if $\psi$ is the identity or equally a huber influence function with a large smoothing constant, \ie $\inf$:

$$
\mathbf{A} = \left(\mathbf{X} \mathbf{V}^{-1} \mathbf{X} \right)^{-1} \mathbf{X}^\top \mathbf{V}^{-1}
$$


