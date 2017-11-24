# Cambiar el directorio de trabajo
setwd("/home/edgar/Documentos/master/AE/Practicas/Lab2")

x <- seq(-10, 10, length = 30)
y <- x
f <- function(x, y) {0.5 * (x^2 + y^2)}
z <- outer(x, y, f)
?outer
dim(x)
# NULL
?outer
?dim
dim(x)
# NULL
?dim
?outer
persp(x, y, z, col = 4)
?persp
persp(x, y, z, col = 4, theta=10)
persp(x, y, z, col = 4, theta=10, phi=30)
contour(x, y, z)
?contour
contour(x, y, z, nlevels=100)

library(lattice)
?expand.grid
g <- expand.grid(x = -10:10, y = -10:10)
g$z <- 0.5 * (g$x^2 + g$y^2)
wireframe(z ~ x * y, data = g, drape = TRUE)
?wireframe
levelplot(z ~ x * y, g, contour = TRUE)
?levelplot
levelplot(z ~ x * y, g, contour = FALSE)
contourplot(z ~ x * y, g)

descent_method <- function(gamma, N, nu, t){
  f <- function(x, y) {0.5 * (x^2 + gamma*y^2)}
  g <- function(x) {return c()}
  x <- t(c(gamma, 1))
  count <- 0
  while(f(x) > nu & count <= N){
    incX <- -g(x)
    x <- x + t*incX
  }
  return(x)
}


descent_method <- function(gamma, t, N, eta){
  # Punto inicial
  x0 <- c(gamma, 1)

  # Funcion que calcula el gradiente
  grad <- function(x){c(x[1], gamma*x[2])}

  # Funcion que calcula el criterio de parada
  stop <- function(x, min = eta){sqrt(sum(grad(x)^2)) <= min}

  # Bucle
  x <- x0
  while(!stop(x)){
    incX <- grad(x)
    x <- x - t*incX
  }
  return (x)
}
