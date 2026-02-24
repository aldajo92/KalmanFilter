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
  count: none,
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
$ p(bold(X)) = frac(1, (2 pi)^(n slash 2) |bold(Sigma)|^(1 slash 2)) exp(-1/2 (bold(X) - bold(mu))^T bold(Sigma)^(-1) (bold(X) - bold(mu))) $

Notación compacta: $bold(X) tilde cal(N)(bold(mu), bold(Sigma))$, con $bold(mu) in RR^n$ y $bold(Sigma) in RR^(n times n)$.

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

Si $bold(X) tilde cal(N)(bold(mu), bold(Sigma))$ y se aplica $bold(Y) = bold(A) bold(X) + bold(b)$:

$ bold(Y) tilde cal(N)(bold(A) bold(mu) + bold(b), space bold(A) bold(Sigma) bold(A)^T) $

Con ruido aditivo independiente $bold(W) tilde cal(N)(bold(0), bold(Q))$:

$ bold(Y) = bold(A) bold(X) + bold(W) quad ==> quad bold(Y) tilde cal(N)(bold(A) bold(mu), space bold(A) bold(Sigma) bold(A)^T + bold(Q)) $

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

== Diagrama del Estimador

#align(center, canvas(length: 0.85cm, {
  import draw: *

  set-style(stroke: 0.8pt, mark: (fill: black))

  let y0 = 0
  let yt = 2.0
  let ybyp = -1.4
  let yfb = -2.8

  let xU = 0
  let xB = 2.4
  let xS1 = 4.6
  let xBr = 6.4
  let xH = 8.0
  let xS3 = 9.8
  let xK = 11.4
  let xS2 = 13.0
  let xOut = 15.0

  // Blocks
  rect((xB - 0.85, y0 - 0.45), (xB + 0.85, y0 + 0.45))
  content((xB, y0), $bold(B)_(k-1)$)

  rect((xH - 0.55, y0 - 0.45), (xH + 0.55, y0 + 0.45))
  content((xH, y0), $bold(H)_k$)

  rect((xK - 0.55, y0 - 0.45), (xK + 0.55, y0 + 0.45))
  content((xK, y0), $bold(K)_k$)

  // Feedback blocks
  rect((xH - 0.55, yfb - 0.45), (xH + 0.55, yfb + 0.45))
  content((xH, yfb), $z^(-1)$)

  rect((xS1 - 0.85, yfb - 0.45), (xS1 + 0.85, yfb + 0.45))
  content((xS1, yfb), $bold(A)_(k-1)$)

  // Sum junctions
  circle((xS1, y0), radius: 0.35)
  content((xS1, y0), $plus.o$)

  circle((xS3, y0), radius: 0.35)
  content((xS3, y0), $plus.o$)

  circle((xS2, y0), radius: 0.35)
  content((xS2, y0), $plus.o$)

  // Innovation signs on S3
  content((xS3 - 0.55, y0 + 0.2), text(size: 7pt)[$minus$])
  content((xS3 + 0.2, y0 + 0.55), text(size: 7pt)[$plus$])

  // Branch dots
  circle((xBr, y0), radius: 0.08, fill: black)
  let xFbBr = xS2 + 1.0
  circle((xFbBr, y0), radius: 0.08, fill: black)

  // Signal labels
  content((xU, y0), $bold(U)_(k-1)$)
  content((xOut, y0), $hat(bold(X))_(k|k)$)
  content((xBr + 0.05, y0 + 0.55), $hat(bold(X))_(k|k-1)$)
  content((xS3, yt), $bold(Z)_k$)

  // Main flow arrows
  line((xU + 0.8, y0), (xB - 0.85, y0), mark: (end: ">"))
  line((xB + 0.85, y0), (xS1 - 0.35, y0), mark: (end: ">"))
  line((xS1 + 0.35, y0), (xH - 0.55, y0), mark: (end: ">"))
  line((xH + 0.55, y0), (xS3 - 0.35, y0), mark: (end: ">"))
  line((xS3 + 0.35, y0), (xK - 0.55, y0), mark: (end: ">"))
  line((xK + 0.55, y0), (xS2 - 0.35, y0), mark: (end: ">"))
  line((xS2 + 0.35, y0), (xOut - 0.7, y0), mark: (end: ">"))

  // Z_k → S3
  line((xS3, yt - 0.4), (xS3, y0 + 0.35), mark: (end: ">"))

  // Bypass: X̂_{k|k-1} directly to S2
  line((xBr, y0 - 0.08), (xBr, ybyp))
  line((xBr, ybyp), (xS2, ybyp))
  line((xS2, ybyp), (xS2, y0 - 0.35), mark: (end: ">"))

  // Feedback: X̂_{k|k} → z⁻¹ → A → S1
  line((xFbBr, y0 - 0.08), (xFbBr, yfb))
  line((xFbBr, yfb), (xH + 0.55, yfb), mark: (end: ">"))
  line((xH - 0.55, yfb), (xS1 + 0.85, yfb), mark: (end: ">"))
  line((xS1, yfb + 0.45), (xS1, y0 - 0.35), mark: (end: ">"))
}))

== Sistema y Estimador

#align(center, canvas(length: 0.52cm, {
  import draw: *

  set-style(stroke: 0.8pt, mark: (fill: black))

  // --- Y coordinates ---
  let y0s = 8.5
  let yts = 10.2
  let ybs = 6.5

  let y0e = 0.5
  let ybyp = -0.8
  let yfb = -2.4

  // --- X coordinates (shared) ---
  let xB = 3.0
  let xS1 = 5.2
  let xBr = 6.8
  let xH = 8.4
  let xSm = 10.2
  let xK = 12.0
  let xS2 = 13.6
  let xOut = 15.4

  // ==================== SISTEMA (TOP) ====================

  rect((xB - 1.5, ybs - 1.0), (xSm + 1.5, yts + 0.6),
    stroke: (thickness: 1pt, dash: "dashed", paint: rgb("#1f4788")))
  content((xS1 + 1.5, yts + 1.1), text(size: 7pt, fill: rgb("#1f4788"), weight: "bold")[Sistema])

  rect((xB - 0.8, y0s - 0.4), (xB + 0.8, y0s + 0.4))
  content((xB, y0s), $bold(B)_(k-1)$)

  rect((xH - 0.5, y0s - 0.4), (xH + 0.5, y0s + 0.4))
  content((xH, y0s), $bold(H)_k$)

  rect((xBr - 0.5, ybs - 0.4), (xBr + 0.5, ybs + 0.4))
  content((xBr, ybs), $z^(-1)$)

  rect((xS1 - 0.8, ybs - 0.4), (xS1 + 0.8, ybs + 0.4))
  content((xS1, ybs), $bold(A)_(k-1)$)

  circle((xS1, y0s), radius: 0.32)
  content((xS1, y0s), $plus.o$)

  circle((xSm, y0s), radius: 0.32)
  content((xSm, y0s), $plus.o$)

  circle((xBr, y0s), radius: 0.07, fill: black)

  content((0.5, y0s), $bold(U)_(k-1)$)
  content((xBr + 0.05, y0s + 0.5), $bold(X)_k$)
  content((xS1, yts), $bold(W)_(k-1)$)
  content((xSm, yts), $bold(V)_k$)

  line((1.3, y0s), (xB - 0.8, y0s), mark: (end: ">"))
  line((xB + 0.8, y0s), (xS1 - 0.32, y0s), mark: (end: ">"))
  line((xS1 + 0.32, y0s), (xH - 0.5, y0s), mark: (end: ">"))
  line((xH + 0.5, y0s), (xSm - 0.32, y0s), mark: (end: ">"))
  line((xSm + 0.32, y0s), (xSm + 1.2, y0s), mark: (end: ">"))

  line((xS1, yts - 0.35), (xS1, y0s + 0.32), mark: (end: ">"))
  line((xSm, yts - 0.35), (xSm, y0s + 0.32), mark: (end: ">"))

  line((xBr, y0s - 0.07), (xBr, ybs + 0.4), mark: (end: ">"))
  line((xBr - 0.5, ybs), (xS1 + 0.8, ybs), mark: (end: ">"))
  line((xS1, ybs + 0.4), (xS1, y0s - 0.32), mark: (end: ">"))

  // Z_k label outside system box
  content((xSm + 2.2, y0s), $bold(Z)_k$)

  // Branch dot on Z_k output line
  circle((xSm + 1.5, y0s), radius: 0.07, fill: black)

  // ==================== ESTIMADOR (BOTTOM) ====================

  rect((xB - 1.5, yfb - 1.0), (xOut + 1.0, y0e + 1.0),
    stroke: (thickness: 1pt, dash: "dashed", paint: rgb("#1f4788")))
  content((xS1 + 4.0, yfb - 1.4), text(size: 7pt, fill: rgb("#1f4788"), weight: "bold")[Estimador (Filtro de Kalman)])

  rect((xB - 0.8, y0e - 0.4), (xB + 0.8, y0e + 0.4))
  content((xB, y0e), $bold(B)_(k-1)$)

  rect((xH - 0.5, y0e - 0.4), (xH + 0.5, y0e + 0.4))
  content((xH, y0e), $bold(H)_k$)

  rect((xK - 0.5, y0e - 0.4), (xK + 0.5, y0e + 0.4))
  content((xK, y0e), $bold(K)_k$)

  rect((xH - 0.5, yfb - 0.4), (xH + 0.5, yfb + 0.4))
  content((xH, yfb), $z^(-1)$)

  rect((xS1 - 0.8, yfb - 0.4), (xS1 + 0.8, yfb + 0.4))
  content((xS1, yfb), $bold(A)_(k-1)$)

  circle((xS1, y0e), radius: 0.32)
  content((xS1, y0e), $plus.o$)

  circle((xSm, y0e), radius: 0.32)
  content((xSm, y0e), $plus.o$)
  content((xSm - 0.5, y0e + 0.18), text(size: 6pt)[$minus$])
  content((xSm + 0.18, y0e + 0.5), text(size: 6pt)[$plus$])

  circle((xS2, y0e), radius: 0.32)
  content((xS2, y0e), $plus.o$)

  circle((xBr, y0e), radius: 0.07, fill: black)
  let xFbBr = xS2 + 0.9
  circle((xFbBr, y0e), radius: 0.07, fill: black)

  content((0.5, y0e), $bold(U)_(k-1)$)
  content((xOut + 0.6, y0e), $hat(bold(X))_(k|k)$)
  content((xBr + 0.05, y0e + 0.5), $hat(bold(X))_(k|k-1)$)

  line((1.3, y0e), (xB - 0.8, y0e), mark: (end: ">"))
  line((xB + 0.8, y0e), (xS1 - 0.32, y0e), mark: (end: ">"))
  line((xS1 + 0.32, y0e), (xH - 0.5, y0e), mark: (end: ">"))
  line((xH + 0.5, y0e), (xSm - 0.32, y0e), mark: (end: ">"))
  line((xSm + 0.32, y0e), (xK - 0.5, y0e), mark: (end: ">"))
  line((xK + 0.5, y0e), (xS2 - 0.32, y0e), mark: (end: ">"))
  line((xS2 + 0.32, y0e), (xOut - 0.2, y0e), mark: (end: ">"))

  line((xBr, y0e - 0.07), (xBr, ybyp))
  line((xBr, ybyp), (xS2, ybyp))
  line((xS2, ybyp), (xS2, y0e - 0.32), mark: (end: ">"))

  line((xFbBr, y0e - 0.07), (xFbBr, yfb))
  line((xFbBr, yfb), (xH + 0.5, yfb), mark: (end: ">"))
  line((xH - 0.5, yfb), (xS1 + 0.8, yfb), mark: (end: ">"))
  line((xS1, yfb + 0.4), (xS1, y0e - 0.32), mark: (end: ">"))

  // ==================== CONEXIONES ====================

  // U branching: vertical line connecting both U inputs
  line((0.5, y0s - 0.3), (0.5, y0e + 0.3), stroke: (thickness: 0.6pt, dash: "dotted"))

  // Z_k: from system output down to estimator innovation node
  let ymid = 3.8
  line((xSm + 1.5, y0s), (xSm + 1.5, ymid))
  line((xSm + 1.5, ymid), (xSm, ymid))
  line((xSm, ymid), (xSm, y0e + 0.32), mark: (end: ">"))
}))

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

= Filtro de Kalman Extendido (EKF)

== Modelo No Lineal

Cuando el sistema no es lineal, las funciones $bold(f)$ y $bold(h)$ reemplazan a las matrices $bold(A)$ y $bold(H)$:

*Ecuación de estado:*
$ bold(X)_(k) = bold(f)(bold(X)_(k-1), bold(U)_(k-1)) + bold(W)_(k-1) $

*Ecuación de medición:*
$ bold(Z)_k = bold(h)(bold(X)_k) + bold(V)_k $

La distribución del estado tras una transformación no lineal ya no es gaussiana en general $arrow.r$ no se puede aplicar el filtro de Kalman directamente.

== Linealización por Jacobianos

El EKF aproxima las funciones no lineales mediante expansión de Taylor de primer orden:

$ bold(f)(bold(X)) approx bold(f)(hat(bold(X))) + bold(F) (bold(X) - hat(bold(X))), quad bold(F)_(i j) = frac(partial f_i, partial X_j) bar_(bold(X) = hat(bold(X))) $

$ bold(h)(bold(X)) approx bold(h)(hat(bold(X))) + bold(H) (bold(X) - hat(bold(X))), quad bold(H)_(i j) = frac(partial h_i, partial X_j) bar_(bold(X) = hat(bold(X))) $

Los jacobianos $bold(F)$ y $bold(H)$ se recalculan en cada paso $k$ alrededor de la estimación actual.

== EKF: Predicción

$ hat(bold(X))_(k|k-1) &= bold(f)(hat(bold(X))_(k-1|k-1), bold(U)_(k-1)) $

$ bold(F)_(k-1) &= frac(partial bold(f), partial bold(X)) bar_(bold(X) = hat(bold(X))_(k-1|k-1)) $

$ bold(P)_(k|k-1) &= bold(F)_(k-1) bold(P)_(k-1|k-1) bold(F)_(k-1)^T + bold(Q)_(k-1) $

La predicción usa la función no lineal $bold(f)$ para propagar el estado, pero el jacobiano $bold(F)$ para propagar la covarianza.

== EKF: Actualización

$ bold(H)_k &= frac(partial bold(h), partial bold(X)) bar_(bold(X) = hat(bold(X))_(k|k-1)) $

$ bold(K)_k &= bold(P)_(k|k-1) bold(H)_k^T (bold(H)_k bold(P)_(k|k-1) bold(H)_k^T + bold(R)_k)^(-1) $

$ hat(bold(X))_(k|k) &= hat(bold(X))_(k|k-1) + bold(K)_k (bold(Z)_k - bold(h)(hat(bold(X))_(k|k-1))) $

$ bold(P)_(k|k) &= (bold(I) - bold(K)_k bold(H)_k) bold(P)_(k|k-1) $

La innovación usa $bold(h)$ no lineal, pero la ganancia y la covarianza usan el jacobiano $bold(H)$.
