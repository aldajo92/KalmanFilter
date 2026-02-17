// Import diatypst template from templates folder
#import "../../templates/diatypst/lib.typ": *
#import "@preview/cetz:0.3.2": canvas, draw

#show: slides.with(
  title: "Filtro de Kalman",
  subtitle: "Formulación Teórica",
  date: "Febrero 2026",
  authors: ("Alejandro Gómez"),
  ratio: 16/9,
  layout: "medium",
  toc: true,
  footer: true,
  title-color: rgb("#1f4788"),
)

= Modelo del Sistema

== Espacio de Estados

*Ecuación de estado:*
$ bold(X)_(k) = bold(A)_(k-1) bold(X)_(k-1) + bold(B)_(k-1) bold(U)_(k-1) + bold(W)_(k-1) $

*Ecuación de medición:*
$ bold(Z)_k = bold(H)_k bold(X)_k + bold(V)_k $

Donde:
- $bold(X)_k in RR^n$: vector de estado
- $bold(U)_k in RR^m$: entrada de control
- $bold(Z)_k in RR^p$: vector de medición
- $bold(W)_k tilde cal(N)(bold(0), bold(Q)_k)$: ruido del proceso
- $bold(V)_k tilde cal(N)(bold(0), bold(R)_k)$: ruido de medición
- $bold(W)_k$ y $bold(V)_k$ son mutuamente independientes

== Diagrama de Bloques

$z^(-1)$: operador de retardo unitario (transformada Z). #h(0.5em) $z^(-1) bold(X)_k = bold(X)_(k-1)$

#align(center, canvas(length: 1cm, {
  import draw: *

  set-style(stroke: 0.8pt, mark: (fill: black))

  let y0 = 0
  let yt = 2.0
  let yb = -2.0

  let xU = 0
  let xB = 2.8
  let xS1 = 5.4
  let xX = 7.4
  let xH = 9.4
  let xS2 = 11.6
  let xZ = 13.8

  // Blocks
  rect((xB - 0.85, y0 - 0.45), (xB + 0.85, y0 + 0.45))
  content((xB, y0), $bold(B)_(k-1)$)

  rect((xH - 0.6, y0 - 0.45), (xH + 0.6, y0 + 0.45))
  content((xH, y0), $bold(H)_k$)

  rect((xX - 0.55, yb - 0.45), (xX + 0.55, yb + 0.45))
  content((xX, yb), $z^(-1)$)

  rect((xS1 - 0.85, yb - 0.45), (xS1 + 0.85, yb + 0.45))
  content((xS1, yb), $bold(A)_(k-1)$)

  // Sum junctions
  circle((xS1, y0), radius: 0.35)
  content((xS1, y0), $plus.o$)

  circle((xS2, y0), radius: 0.35)
  content((xS2, y0), $plus.o$)

  // Branch dot at X_k
  circle((xX, y0), radius: 0.08, fill: black)

  // Signal labels
  content((xU, y0), $bold(U)_(k-1)$)
  content((xZ, y0), $bold(Z)_k$)
  content((xX + 0.05, y0 + 0.5), $bold(X)_k$)
  content((xS1, yt), $bold(W)_(k-1)$)
  content((xS2, yt), $bold(V)_k$)

  // Main flow arrows
  line((xU + 0.7, y0), (xB - 0.85, y0), mark: (end: ">"))
  line((xB + 0.85, y0), (xS1 - 0.35, y0), mark: (end: ">"))
  line((xS1 + 0.35, y0), (xH - 0.6, y0), mark: (end: ">"))
  line((xH + 0.6, y0), (xS2 - 0.35, y0), mark: (end: ">"))
  line((xS2 + 0.35, y0), (xZ - 0.45, y0), mark: (end: ">"))

  // Noise arrows (top to sum)
  line((xS1, yt - 0.4), (xS1, y0 + 0.35), mark: (end: ">"))
  line((xS2, yt - 0.4), (xS2, y0 + 0.35), mark: (end: ">"))

  // Feedback: X_k down to delay
  line((xX, y0 - 0.08), (xX, yb + 0.45), mark: (end: ">"))
  // Feedback: delay left to A
  line((xX - 0.55, yb), (xS1 + 0.85, yb), mark: (end: ">"))
  // Feedback: A up to sum1
  line((xS1, yb + 0.45), (xS1, y0 - 0.35), mark: (end: ">"))
}))

= Distribución de Probabilidad y Covarianza

== Distribución Gaussiana

*Univariada:*
$ p(x) = frac(1, sqrt(2 pi sigma^2)) exp(-frac((x - mu)^2, 2 sigma^2)) $

*Multivariada:*
$ p(bold(x)) = frac(1, (2 pi)^(n slash 2) |bold(Sigma)|^(1 slash 2)) exp(-1/2 (bold(x) - bold(mu))^T bold(Sigma)^(-1) (bold(x) - bold(mu))) $

Notación compacta: $bold(x) tilde cal(N)(bold(mu), bold(Sigma))$, con $bold(mu) in RR^n$ y $bold(Sigma) in RR^(n times n)$.

== Matriz de Covarianza

La matriz de covarianza cuantifica la incertidumbre del vector de estado:

$ bold(P) = bb("E")[(bold(X) - bold(mu))(bold(X) - bold(mu))^T] = mat(
  sigma_1^2, sigma_(1 2), dots, sigma_(1 n);
  sigma_(2 1), sigma_2^2, dots, sigma_(2 n);
  dots.v, dots.v, dots.down, dots.v;
  sigma_(n 1), sigma_(n 2), dots, sigma_n^2
) $

- Diagonal $sigma_i^2$: varianza de cada variable de estado
- Fuera de diagonal $sigma_(i j) = bb("E")[(X_i - mu_i)(X_j - mu_j)]$: covarianza cruzada
- Propiedades: $bold(P) = bold(P)^T$ y $bold(P) gt.eq 0$

En el filtro de Kalman, $bold(P)$ es la incertidumbre asociada a la estimación $hat(bold(X))$.

== Transformación Lineal de Gaussianas

Si $bold(x) tilde cal(N)(bold(mu), bold(Sigma))$ y se aplica $bold(y) = bold(A) bold(x) + bold(b)$:

$ bold(y) tilde cal(N)(bold(A) bold(mu) + bold(b), space bold(A) bold(Sigma) bold(A)^T) $

Con ruido aditivo independiente $bold(w) tilde cal(N)(bold(0), bold(Q))$:

$ bold(y) = bold(A) bold(x) + bold(w) quad ==> quad bold(y) tilde cal(N)(bold(A) bold(mu), space bold(A) bold(Sigma) bold(A)^T + bold(Q)) $

Esta propiedad da origen directo a la *etapa de predicción* del filtro.

= Estimación Bayesiana

== Teorema de Bayes Aplicado a Estimación

El estado $bold(X)_k$ se modela como variable aleatoria. Su distribución posterior dado las mediciones es:

$ p(bold(X)_k | bold(Z)_(1:k)) = frac(p(bold(Z)_k | bold(X)_k) dot p(bold(X)_k | bold(Z)_(1:k-1)), p(bold(Z)_k | bold(Z)_(1:k-1))) $

Para el modelo lineal con ruido gaussiano:
- *Prior:* $p(bold(X)_k | bold(Z)_(1:k-1)) = cal(N)(hat(bold(X))_(k|k-1), bold(P)_(k|k-1))$
- *Verosimilitud:* $p(bold(Z)_k | bold(X)_k) = cal(N)(bold(H)_k bold(X)_k, bold(R)_k)$
- *Posterior:* $p(bold(X)_k | bold(Z)_(1:k)) = cal(N)(hat(bold(X))_(k|k), bold(P)_(k|k))$

El producto de gaussianas es gaussiano $arrow.r.double$ la posterior tiene forma cerrada.

== Fusión de Gaussianas

La posterior se obtiene combinando los exponentes del prior y la verosimilitud:

$ -1/2 [(bold(X) - hat(bold(X))_(k|k-1))^T bold(P)_(k|k-1)^(-1) (bold(X) - hat(bold(X))_(k|k-1)) + (bold(Z)_k - bold(H) bold(X))^T bold(R)_k^(-1) (bold(Z)_k - bold(H) bold(X))] $

Agrupando términos cuadráticos en $bold(X)$:

*Precisión posterior:*
$ bold(P)_(k|k)^(-1) = bold(P)_(k|k-1)^(-1) + bold(H)_k^T bold(R)_k^(-1) bold(H)_k $

*Información posterior:*
$ bold(P)_(k|k)^(-1) hat(bold(X))_(k|k) = bold(P)_(k|k-1)^(-1) hat(bold(X))_(k|k-1) + bold(H)_k^T bold(R)_k^(-1) bold(Z)_k $

= Filtro de Kalman

== Predicción

Dado $bold(X)_(k-1) | bold(Z)_(1:k-1) tilde cal(N)(hat(bold(X))_(k-1|k-1), bold(P)_(k-1|k-1))$ y el modelo lineal, por la propiedad de transformación de gaussianas:

*Media predicha:*
$ hat(bold(X))_(k|k-1) = bold(A)_(k-1) hat(bold(X))_(k-1|k-1) + bold(B)_(k-1) bold(U)_(k-1) $

*Covarianza predicha:*
$ bold(P)_(k|k-1) = bold(A)_(k-1) bold(P)_(k-1|k-1) bold(A)_(k-1)^T + bold(Q)_(k-1) $

Resultado: $bold(X)_k | bold(Z)_(1:k-1) tilde cal(N)(hat(bold(X))_(k|k-1), bold(P)_(k|k-1))$

== Actualización

Aplicando el *lema de inversión matricial (Woodbury)* a la forma de información:

$ (bold(P)_(k|k-1)^(-1) + bold(H)^T bold(R)^(-1) bold(H))^(-1) = bold(P)_(k|k-1) - bold(P)_(k|k-1) bold(H)^T (bold(H) bold(P)_(k|k-1) bold(H)^T + bold(R))^(-1) bold(H) bold(P)_(k|k-1) $

Se define la *ganancia de Kalman*:
$ bold(K)_k = bold(P)_(k|k-1) bold(H)_k^T (bold(H)_k bold(P)_(k|k-1) bold(H)_k^T + bold(R)_k)^(-1) $

Las ecuaciones de actualización resultan:

$ hat(bold(X))_(k|k) = hat(bold(X))_(k|k-1) + bold(K)_k (bold(Z)_k - bold(H)_k hat(bold(X))_(k|k-1)) $
$ bold(P)_(k|k) = (bold(I) - bold(K)_k bold(H)_k) bold(P)_(k|k-1) $

== Ganancia de Kalman

$ bold(K)_k = bold(P)_(k|k-1) bold(H)_k^T (bold(H)_k bold(P)_(k|k-1) bold(H)_k^T + bold(R)_k)^(-1) $

$bold(K)_k$ balancea la incertidumbre de la predicción ($bold(P)_(k|k-1)$) contra la incertidumbre de la medición ($bold(R)_k$):

- $bold(R)_k arrow infinity$ (medición ruidosa): $bold(K)_k arrow bold(0)$ $arrow.r$ se conserva la predicción
- $bold(P)_(k|k-1) arrow infinity$ (predicción incierta): $bold(K)_k arrow bold(H)^(-1)$ $arrow.r$ se sigue la medición

La ganancia $bold(K)_k$ minimiza la traza de $bold(P)_(k|k)$, es decir, minimiza la varianza total del error de estimación.

== Algoritmo Completo

*Inicialización:* $hat(bold(X))_(0|0) = bb("E")[bold(X)_0]$, #h(1em) $bold(P)_(0|0) = bb("E")[(bold(X)_0 - hat(bold(X))_(0|0))(bold(X)_0 - hat(bold(X))_(0|0))^T]$

*Para cada paso $k = 1, 2, 3, dots$:*

#line(length: 100%, stroke: 0.5pt)

*Predicción (propagación de la distribución):*
$ hat(bold(X))_(k|k-1) &= bold(A)_(k-1) hat(bold(X))_(k-1|k-1) + bold(B)_(k-1) bold(U)_(k-1) \
bold(P)_(k|k-1) &= bold(A)_(k-1) bold(P)_(k-1|k-1) bold(A)_(k-1)^T + bold(Q)_(k-1) $

#line(length: 100%, stroke: 0.5pt)

*Actualización (fusión bayesiana):*
$ bold(K)_k &= bold(P)_(k|k-1) bold(H)_k^T (bold(H)_k bold(P)_(k|k-1) bold(H)_k^T + bold(R)_k)^(-1) \
hat(bold(X))_(k|k) &= hat(bold(X))_(k|k-1) + bold(K)_k (bold(Z)_k - bold(H)_k hat(bold(X))_(k|k-1)) \
bold(P)_(k|k) &= (bold(I) - bold(K)_k bold(H)_k) bold(P)_(k|k-1) $
