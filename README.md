# DocstringTranslationExoBackend.jl

<img width="862" alt="image" src="https://github.com/user-attachments/assets/2519cb7e-92ae-4cd1-9bcf-3e130bd72dd6">

## Description

This Julia package inserts Large Language Model (LLM) hooks into the API in the `Base.Docs module`, giving non-English speaking users the opportunity to help smooth API comprehension.

## Prerequisite

### Install Julia

Install Julia using juliaup.

```sh
$ curl -fsSL https://install.julialang.org | sh -s -- --yes
```

### `exo`

This package utilizes Python package [exo](https://github.com/exo-explore/exo).

> exo: Run your own AI cluster at home with everyday devices. Maintained by exo

By default, We use local LLM model as "gemma2-9b". The `exo` package will automatically install it once you start our Julia package.

We manage the Python dependencies in the `CondaPkg.toml` file.

## Usage

### Start Julia script

```
$ julia --project -e 'using Pkg; Pkg.instantiate()'
$ julia --project serveexo.jl
```

### Start Julia REPL

Open another terminal. Then run Julia REPL in the terminal:

```sh
$ cd path/to/directory
$ julia --project
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.11.1 (2024-10-16)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> using DocstringTranslationExoBackend
```

Call `@switchlang!` macro with your preferred language.

### Example: Japanese(日本語)

```julia
julia> @switchlang! :Japanese

julia> @doc sin
  sin(x)

  ラジアンで表された x の正弦を計算します。

  sind, sinpi, sincos, cis, asin も参照してください。

  例
  ≡≡

  julia> round.(sin.(range(0, 2pi, length=9)'), digits=3)
  1×9 Matrix{Float64}:
   0.0  0.707  1.0  0.707  0.0  -0.707  -1.0  -0.707  -0.0

  julia> sind(45)
  0.7071067811865476

  julia> sinpi(1/4)
  0.7071067811865475

  julia> round.(sincos(pi/6), digits=3)
  (0.5, 0.866)

  julia> round(cis(pi/6), digits=3)
  0.866 + 0.5im

  julia> round(exp(im*pi/6), digits=3)
  0.866 + 0.5im

  sin(A::AbstractMatrix)

  正方行列 A のマトリックスサインを計算します。

  A が対称行列またはエルミート行列の場合、固有値分解 (eigen)
  を使用してサインを計算します。それ以外の場合、サインは exp
  を呼び出すことで決定されます。

  例
  ≡≡

  julia> sin(fill(1.0, (2,2)))
  2×2 Matrix{Float64}:
   0.454649  0.454649
   0.454649  0.454649

julia>
```

### Example: German(ドイツ語)

```julia
julia> @doc sin

  sin(x)

  Berechnet die Sinusfunktion von x, wobei x in Radianen angegeben ist.

  Siehe auch sind, sinpi, sincos, cis, asin.

  Beispiele
  ≡≡≡≡≡≡≡≡≡

  julia> round.(sin.(range(0, 2pi, length=9)'), digits=3)
  1×9 Matrix{Float64}:
   0.0  0.707  1.0  0.707  0.0  -0.707  -1.0  -0.707  -0.0

  julia> sind(45)
  0.7071067811865476

  julia> sinpi(1/4)
  0.7071067811865475

  julia> round.(sincos(pi/6), digits=3)
  (0.5, 0.866)

  julia> round(cis(pi/6), digits=3)
  0.866 + 0.5im

  julia> round(exp(im*pi/6), digits=3)
  0.866 + 0.5im

  sin(A::AbstractMatrix)

  Berechnet die Matrix-Sinus von einer quadratischen Matrix A.

  Wenn A symmetrisch oder hermitesch ist, wird seine Eigenwertzerlegung
  (eigen) verwendet, um den Sinus zu berechnen. Andernfalls wird der Sinus
  durch einen Aufruf von exp bestimmt.

  Beispiele
  ≡≡≡≡≡≡≡≡≡

  julia> sin(fill(1.0, (2,2)))
  2×2 Matrix{Float64}:
   0.454649  0.454649
   0.454649  0.454649

julia>
```

### Back to English(英語)

You can revert the default `@doc` functionality anytime. Just call `@revertlang!` macro.

```julia
julia> @revertlang!

help?> sin
search: sin sinc sind sinh sign asin in min sinpi using isinf

  sin(x)

  Compute sine of x, where x is in radians.

  See also sind, sinpi, sincos, cis, asin.

  Examples
  ≡≡≡≡≡≡≡≡

  julia> round.(sin.(range(0, 2pi, length=9)'), digits=3)
  1×9 Matrix{Float64}:
   0.0  0.707  1.0  0.707  0.0  -0.707  -1.0  -0.707  -0.0

  julia> sind(45)
  0.7071067811865476

  julia> sinpi(1/4)
  0.7071067811865475

  julia> round.(sincos(pi/6), digits=3)
  (0.5, 0.866)

  julia> round(cis(pi/6), digits=3)
  0.866 + 0.5im

  julia> round(exp(im*pi/6), digits=3)
  0.866 + 0.5im

  ─────────────────────────────────────────────────────────────

  sin(A::AbstractMatrix)

  Compute the matrix sine of a square matrix A.

  If A is symmetric or Hermitian, its eigendecomposition
  (eigen) is used to compute the sine. Otherwise, the sine is
  determined by calling exp.

  Examples
  ≡≡≡≡≡≡≡≡

  julia> sin(fill(1.0, (2,2)))
  2×2 Matrix{Float64}:
   0.454649  0.454649
   0.454649  0.454649

julia>
```

## Switching to another LLM (untested)

You can switch to another lightweight model, such as ‘llama3.1-8b’.

```julia
julia> using Pkg; Pkg.activate(".")
julia> using DocstringTranslationExoBackend
julia> switchmodel!("llama3.1-8b")
julia> @doc sin
```
