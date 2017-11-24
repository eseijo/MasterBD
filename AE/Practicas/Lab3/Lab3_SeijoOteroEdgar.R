# Valor n para la muestra
n <- 100
# x: n puntos aleatorios en el intervalo [min,max]
x <- runif(n, min=0, max=5)
# Parametro beta0 del modelo
beta0 <- 2
# Parametro beta1 del modelo
beta1 <- 5
# Error con desviacion tipica 1
epsilon <- rnorm(n, sd = 1)
# y
y <- beta0 + beta1*x + epsilon

# Calcular el valor de los parametros estimados con lm
z3 <- lm(y ~ x)

RSS <- function(b0, b1){sum((y-b0-b1*x)^2)}
RSE <- function(b0, b1){sqrt(RSS(b0, b1)/(n-2))}
J <- function(b0, b1){(1/2)*RSS(b0, b1)}

descent_method <- function(b0, b1, t=0.001, N=1000, eta=1e-10){
  # Comprobar que t > 0
  if(t > 0){
    iterations <- 0;
    d_b0 <- function(b0, b1){-sum(y-b0-b1*x)}
    d_b1 <- function(b0, b1){-sum(x*(y-b0-b1*x))}
    norma2 <- function(b0, b1){sqrt(abs(d_b0(b0, b1))^2+abs(d_b1(b0, b1))^2)}
    while(iterations < N & norma2(b0, b1) > eta){
      aux_b0 <- b0 - t*d_b0(b0, b1)
      aux_b1 <- b1 - t*d_b1(b0, b1)
      b0 <- aux_b0
      b1 <- aux_b1
      iterations <- iterations + 1
    }
    invisible(list(beta0 = b0, beta1 = b1, RSS = RSS(b0, b1), RSE = RSE(b0, b1), iteraciones = iterations, norma2fn = norma2(b0, b1)))
  }
}

result <- descent_method(0, 0, 0.001, 10000, 1e-5)
result
summary(z3)
