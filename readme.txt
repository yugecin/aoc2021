my solutions for the 2021 Advent of Code: https://adventofcode.com/2021

I used:
nasm: NASM version 2.15.05 compiled on Aug 28 2020
link: Microsoft (R) Incremental Linker Version 8.00.50727.42 (from VC2005)
(VCS2015 to compile aoc2021.cs)
debugger: IDA freeware and/or CheatEngine

run "build.bat" and it compiles and spouts all solutions

run "build.bat /DEBUG" to make aoc2021.exe wait before running each solution,
this is useful to attach a debugger to the waiting process to debug the dll.

run "build.bat /BENCH" to make aoc2021.exe run the solutions multiple times,
to get an average timing over 500 iterations.

every solution makes a dll with exported function "aoc"
aoc2021.exe just calls that while having a Stopwatch running
