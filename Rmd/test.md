# new section

- item
    - item 1.1
    - item 1.2
    - new item 

\begin{align}
x_i &= y_i \label{eq:tmp1}\\
x_i + y_i &= y_i
\end{align}

cite me: @Abb97

Reference math: \eqref{eq:tmp1}

Math without numbering:

\begin{align*}
x_i &= y_i \\
x_i + y_i &= y_i
\end{align*}



```r
x <- 1
```


```r
ggplot(data.frame(x = 1:10, y = 11:20)) + 
  geom_point(aes(x, y)) + 
  theme_thesis()
```

![plot of chunk unnamed-chunk-2](figs/test/unnamed-chunk-2-1.pdf) 

