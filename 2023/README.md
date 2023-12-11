# Advent of Code 2023

These are my solutions to [Advent of Code](https://adventofcode.com/) for 2023. The plan this year is to do them in Ruby, and focus on practicing TDD, object-oriented design, and refactoring.

## Setup

Probably requires Ruby >=3.2. I sometimes use [`paco`](https://github.com/ruby-next/paco) for parsing, which can be installed with [Bundler](https://bundler.io/):

    $ bundle

I'm also using [`just`](https://github.com/casey/just#packages) as a command runner.

## Usage

Solve all puzzles:

    $ just solve

Solve one puzzle:

    $ just solve 14

Run all tests:

    $ just test

Rerun tests on file change (requires binary from `gem install rerun`):

    $ just watch
