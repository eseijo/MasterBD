# Cambiar el directorio de trabajo
setwd("/home/edgar/Documentos/master/AE/Practicas/Lab3")

# Leer el fichero titanic_es.csv
advertising <- read.csv("Advertising.csv")

# Representacion grafica
plot(advertising)

# Ajuste lineal
z <- lm(Sales ~ TV + Radio + Newspaper, data=advertising)

# lm devuelve un objeto de tipo lm
class(z)

# Componentes de z
names(z)

# Resumen de los datos
summary(z)

# Obtener los coeficientes estimados del modelo
coef(z)

## Obtener los coeficientes ajustados por minimos cuadrados
# Generar X como matriz con columna identidad y quitandole las columnas del numero de elemento y ventas
X <- as.matrix(cbind(1, advertising[,-c(1, 5)]))
# Generar y como vector formado por la columna ventas
y <- advertising[,5
# Obtener vector beta
beta <- solve(t(X)%*%X)%*%t(X)%*%y

# Obtener los valores ajustados por el modelo de regresion lineal
fitted(z)

## Calcular RSE a partir de los residuos
# Calcular RSS
RSS <- sum(residuals(z)^2)

# Calcular RSE como raiz cuadrada de RSS partido por n=200 - p=3 - 1
RSE <- sqrt(RSS/(200 - 3 - 1))

# Obtener intervalos de confianza, level para especificar nivel de confianza
confint(z) #level=0.95
confint(z, level=0.9)

# Ajuste lineal que explique Sales como funcion de TV y Radio
z2 <- lm(Sales ~ TV + Radio, data = advertising)

# Resumen de los datos
summary(z2)

# Predecir las ventas en un comercio que invierte 20000 en radio y 100000 en TV
newdata = data.frame(TV = 100, Radio = 20)
predict(z2, newdata)

# Intervalo de confianza para la venta media
predict(z2, newdata, interval = "confidence")

# Intervalo de prediccion para una venta
predict(z2, newdata, interval = "predict")

### --------------------------------------------------------------

# Valor n para la muestra
n <- 100
# x: n puntos aleatorios en el itervalo [min,max]
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

result <- descent_method(0, 0, 0.0001, 10000, 1e-10)

### --------------------------------------------------------------

stochastic_descent_method <- function(b0, b1, t=0.001, N=1000, eta=1e-10){
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
