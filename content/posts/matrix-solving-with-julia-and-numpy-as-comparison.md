---
title: "Matrix Solving with Julia (and Numpy as comparison)"
date: 2023-10-11T04:29:25+01:00
aliases:
    - /2023/10/11/matrix-solving-with-julia-and-numpy-as-comparison/
hideSummary: false
categories: ["Coding"]
description: In which I got curious, rekindled my past with Julia (the language), 
    and did some benchmark tests against NumPy.
ShowToc: true
---

A lot of things happened between my last post and now. Family stuff, work
problems, dealing with bureaucracy—the list keeps growing.

But there are some good things too. One of them being that I finally beat my
procrastination and finished Busuu's courses for B1 level, and I even got the
official certificate! You can check it out
[here](https://www.linkedin.com/feed/update/urn:li:activity:7114248182447894528/).
The kanji and listening parts were a bit tougher than I expected, lol.

Apart from that, I've been busy with a bunch of personal projects and
experiments. One of them involves Julia—a high-level, dynamic language made for
doing computation stuff. I first came across it during my PhD in France years
ago.

Back then, I was looking for a different language, framework, or platform to do
numerical simulations. I'm talking about stuff like finite element, finite
difference, and solving big matrices with tons and tons of elements over time
(unsteady state). I needed something fast, easy to use and code, and easy for
other people to use too.

Julia was one of the options I found. I was amazed at how easy it was to install
and set up. A couple of minutes and I was ready to go, writing my first
functions.

```julia
# hello.jl

function say_hello()
## It looked more or less like this
    println("Hello, world!")
end

say_hello() 
```

The language seemed promising and performed well in tests, but I ultimately
chose not to use it. Instead, I considered alternatives like
[MATLAB](https://www.mathworks.com/products/pde.html) and
[Cast3M](http://www-cast3m.cea.fr/), which my supervisors were already familiar
with.

However, things have changed now.

## From Academia to Industry

Lots of things happened, but basically I transitioned from academia to industry.
Over the course of (almost) four years, I’ve gained more skills and experiences
in software engineering than ever before. Building REST APIs, full-stack web
apps, scrapers, and many more tools that are used on a daily basis at my
company.

These days, though, when building a calculation tool, I came to realize a new
requirement: **speed**. This is especially important when calling remote
functions. Nobody wants to wait 10 seconds just to finish a single calculation
made by changing a single parameter. That’s why I've been contemplating
seriously building my own finite element solver instead of relying on my usual
tools.

It was here that Julia re-entered my radar. Originally thinking to just stay in
my comfort zone with Python and its critically acclaimed numerical package,
NumPy, I decided to test it out against Julia. Although that wasn’t the main
reason for me to see Julia again—it was actually Julia’s threading and
distributed computing capability—but we’ll talk about that in another post.

After all, NumPy is already well-known amongst the scientific computation
community as having one of the easiest to use, and fastest matrix solver out
there. Why not benchmark it against Julia, who’s been claimed to be [as fast
Fortran, with ease of use as
Python](https://www.matecdev.com/posts/numpy-julia-fortran.html)?

## Diving to the Code

### Matrix Generation

The first thing I did was preparing the structure. I was thinking that the
project needs at least three files: one code file to generate the matrices, one
file to benchmark NumPy’s matrix solver, and one file to benchmark Julia’s
matrix solver.

Thus, I prepared a simple project structure like this:

```bash
├── julia_side.jl
├── matrix_generation.py
└── numpy_side.py
```

I decided to use NumPy’s own matrix generation capability because, why not?

So firstly, the inside of the `matrix_generation.py` is as follows:

```python
import numpy as np

# Define matrix sizes
matrix_sizes = [10, 100, 500, 1000, 1500, 2000]

# Set the seed for reproducibility
np.random.seed(0)

# Define the range for matrix elements
low_value = -10
high_value = 10

for matrix_size in matrix_sizes:
    # Generate matrices
    A = np.random.uniform(low_value, high_value, (matrix_size, matrix_size))
    x = np.random.uniform(low_value, high_value, matrix_size)

    # Calculate B such that Ax = B
    B = np.dot(A, x)

    # Save matrices with size info
    np.savetxt(f"matrix_A_{matrix_size}.txt", A)
    np.savetxt(f"vector_B_{matrix_size}.txt", B)
```

As you can see, I created six A matrices and six B matrices with varying
dimensions. To make sure that a matrix **x** solution exists, I generated **x**
first and then generated matrices B through the dot operation of A and _x_.
Then, I saved each of those matrices in simple text files.

Oh, also, I set the seed in NumPy, to make sure that the whole thing is
reproducible.

### Benchmark NumPy

Next is writing a code to do benchmark of NumPy’s matrix solver. To do this, I
simply use two modules: `memory_profiler` and `timeit` to measure both the
execution time and memory usage.

```python
from memory_profiler import memory_usage
import numpy as np
import timeit
import gc

matrix_sizes = [10, 100, 500, 1000, 1500, 2000]

def solve_equation(A, B):
    return np.linalg.solve(A, B)

results = []

for matrix_size in matrix_sizes:
    # Load matrices
    matrix_A = np.loadtxt(f"matrix_A_{matrix_size}.txt")
    vector_B = np.loadtxt(f"vector_B_{matrix_size}.txt")

    # Time the function using timeit
    elapsed_time = timeit.timeit(
        "solve_equation(matrix_A, vector_B)",
        setup=f"from __main__ import solve_equation, matrix_A, vector_B",
        number=1,  # Number of executions
    )

    # Measure memory
    mem_usage_before = memory_usage(max_usage=True)
    mem_usage, vector_x = memory_usage(
        (solve_equation, (matrix_A, vector_B)), max_usage=True, retval=True
    )
    mem_usage_increment = mem_usage - mem_usage_before

    # Append results
    results.append((matrix_size, elapsed_time, mem_usage_increment))

    # Cleanup
    del matrix_A, vector_B, vector_x
    gc.collect()

# Save results to CSV
np.savetxt(
    "numpy_results.csv",
    results,
    delimiter=",",
    header="MatrixSize,Time,Memory",
    comments="",
    fmt=["%d", "%.6f", "%.6f"],
)
```

The results are then saved as a CSV file.This is important because I want to be
able to compare the data easily later.

### Benchmark Julia

Next step is writing a Julia code to benchmark its solver. In Julia language,
there’s a package called `BenchmarkTools` which is very practical for measuring
the memory and time processing at the same time.

```julia
using BenchmarkTools, CSV, DataFrames, DelimitedFiles

matrix_sizes = [10, 100, 500, 1000, 1500, 2000]

results = []

function solve_equation(A, B)
	x = A \\ B
end

for matrix_size in matrix_sizes
	# Use let block to limit the scope of variables and help with memory management
	let matrix_A = Matrix(CSV.File("matrix_A_$(matrix_size).txt"; header = false) |> DataFrame),
		df_B = CSV.File("vector_B_$(matrix_size).txt"; header = false) |> DataFrame,
		vector_B = df_B[!, 1]  # Extract the first column without copying

		# Run the function and benchmark
		bm = @benchmark solve_equation($matrix_A, $vector_B)

		push!(results, (matrix_size, mean(bm).time / 1e9, mean(bm).memory / 1e6))

		# Explicitly call the garbage collector
		GC.gc()
	end
end

# Save results to CSV
open("julia_results.csv", "w") do io println(io, "MatrixSize,Time,Memory")  #
	Adding a header line writedlm(io, results, ',')  # Writing data below the header 
end
```

Additionally, I also use `DataFrame` and `CSV` packages for help in reading the
matrices which are saved as text files.

Then, just like the benchmark code using NumPy, I also export the result as CSV
files.

## Results

I ran the tests using my own machine, whose specs can be summed as:

- Fedora Linux 38 64-bit
- 16 GiB System Memory
- 11th Gen Intel® Core™ i5-11400H × 12 Processors

And below is the table with the results:

| MatrixSize | NumPyTime | NumPyMemory | JuliaTime | JuliaMemory |
| --- | --- | --- | --- | --- |
| 10 | 7.60e-4 | 0.250 | 1.12e-6 | 0.001 |
| 100 | 3.95e-4 | 0.125 | 1.52e-4 | 0.082 |
| 500 | 4.05e-3 | 1.500 | 2.17e-3 | 2.008 |
| 1000 | 2.51e-2 | 4.625 | 7.79e-3 | 8.016 |
| 1500 | 2.61e-2 | 9.500 | 1.90e-2 | 18.024 |
| 2000 | 9.78e-2 | 13.375 | 3.86e-2 | 32.032 |

From the data, it can be observed that Julia generally performs faster than
NumPy for solving matrices. In smaller matrices, the difference can be between
two or three times higher; however, with the increase of matrix dimensions, the
time difference became lower and lower. This makes me curious if the time
difference will at some point disappear. I’m going to study this part later.

Curiously, though, NumPy tends to use less memory compared to Julia. The
performance difference becomes more prominent as the size of the matrices
increases. We’re seeing about two to almost three times differences at the end.
This could also be a big consideration point.

## Next Steps

The benchmark tests above have shown that Julia consistently performs faster
than NumPy for solving matrices. The next steps of the tests or decisions to
make, in my opinion, would be:

- Test for even bigger matrices (to-do next: 3000, 4000, 5000,…. the list goes
  on).
- Try other ways to input the data, such as REST API calls, instead of reading
  from a text file.
- Test in real-time use, such as setting them up as serverless functions to be
  called or using REST API calls with workers and queue management.

The whole code used for the benchmark test above has been uploaded to a [GitHub
repository.](https://github.com/ahmad-alkadri/curious-julia-numpy-matrix-solver)
You're free to test it out, adjust, and modify. I'll probably also add more test
cases (especially for bigger matrices) in the near future, so stay in touch!

Also, don't hesitate to raise any questions or comments below!
