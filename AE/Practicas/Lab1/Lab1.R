# Cambiar el directorio de trabajo
setwd("/home/edgar/Documentos/master/AE/Practicas/Lab1")

# Leer el fichero titanic_es.csv
titanic <- read.csv2("titanic_es.csv")

# Numero de pasajeros registrados
npasajeros <- nrow(titanic)

# Numero de supervivientes
nsupervivientes <- sum(titanic$sobreviviente == 1)

# Porcentaje de supervivientes
# Numero de supervivientes / numero total de pasajeros * 100
psupervivientes <- nsupervivientes/npasajeros*100

# Numero de pasajeros que viajaban en primera
nprimera = sum(titanic$clase == "primera")

# Menores de 12 registrados
nmenores = sum(titanic$edad < 12)

# Frecuencias relativas para cada clase
fabsolutas <- table(titanic$clase)
frelativas <- fabs/sum(fabs)

# Grafico distribucion clases (valores discretos)
plot(titanic$clase)

# Grafico distribucion edades (valores continuos)
hist(titanic$edad)

# Media de las edades
mean(titanic$edad)

# Mediana de las edades
median(titanic$edad)

# Media precio
mean(titanic$tarifa)

## Porcentaje de mujeres supervivientes

# Numero total de mujeres
nmujeres <- sum(titanic$sexo == "mujer")
# Numero de mujeres supervivientes
nmujeressup <- sum(titanic$sexo == "mujer" & titanic$sobreviviente == 1)
# Porcentaje
pmujeressup <- nmujeressup/nmujeres*100

## Porcentaje de hombres supervivientes

# Numero total de hombres
nhombres <- sum(titanic$sexo == "hombre")
# Numero de hombres supervivientes
nhombressup <- sum(titanic$sexo == "hombre" & titanic$sobreviviente == 1)
# Porcentaje
phombressup <- nhombressup/nhombres*100

## Porcentaje de menores de 12 supervivientes

# Numero total de menores de 12 calculado anteriormente
# Numero de menores de 12 supervivientes
nmenoressup <- sum(titanic$edad < 12 & titanic$sobreviviente == 1)
# Porcentaje
pmenoressup <- nmenoressup/nmenores*100

# Tasas de supervivencia segun clase
tapply(titanic$sobreviviente == 1, titanic$clase, sum)/table(titanic$clase)*100

# Diagrama de cajas de edades agrupadas por clase
boxplot(titanic$edad ~ titanic$clase)

## Media y varianza de edades en cada clase
# Media
tapply(titanic$edad, titanic$clase, mean)
# Varianza
tapply(titanic$edad, titanic$clase, var)

# Edad asistencia especial
quantile(titanic$edad, seq(0, 1, by=0.05))[20]

# Pasajero mayor edad
edadmax <- max(titanic$edad)

# Histograma precios primera
hist(titanic$tarifa[titanic$clase == "primera"])

# Moda para el puerto de embarque
which(table(titanic$embarque) == max(table(titanic$embarque)))

# Precio maximo camarotes mas modestos
quantile(titanic$tarifa, seq(0, 1, by=0.05))[2]

# Tabla de contingencia para la distribucion de la clase de pasajero por sexo
table(titanic$clase, titanic$sexo)

# Grafico de la distribucion de la clase de pasajero por sexo
plot(titanic$clase, titanic$sexo)

# Cuartiles edad
quantile(titanic$edad)

# Billete menores 1 ano
titanic$tarifa[titanic$edad < 1]
