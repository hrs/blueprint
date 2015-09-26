### Blueprint [![Build Status](https://secure.travis-ci.org/hrs/blueprint.png?branch=master&.png)](http://travis-ci.org/hrs/blueprint)

A simple little Scheme implemented in Ruby.

Blueprint is still very tiny, missing a ton of functionality, and has
absolutely atrocious performance. This is all just for fun.

To fire up a REPL:

```sh
$ bin/run_repl
> (+ 1 2 3)
6
>
```

(Consider using [rlwrap] for readline functionality---use `rlwrap
bin/run_repl`)

[rlwrap]: https://github.com/hanslub42/rlwrap

### Features

Blueprint supports a lot of the functionality you'd expect from a
Scheme (though some of its syntax is a bit different):

`read`ing and `eval`ing:

```lisp
(read \"(+ 1 2 3)\") # => '(+ 1 2 3)
(eval (read \"(+ 1 2 3)\")) # => 6
```

Recursion:

```lisp
(define (fact n)
  (if (== n 0)
    1
    (* n (fact (- n 1)))))

(fact 6) # => 72
```

Lexical closures:

```lisp
(define (make-counter)
  (let ((n 0))
    (lambda ()
      (set! n (+ 1 n)))))
(define a (make-counter))
(define b (make-counter))
(a) # => 1
(a) # => 2
(b) # => 1
```

Variadic binding:

```lisp
(define (drop-two (a b . rest)
  rest))

(drop-two 1 2 3 4 5 6) # => '(3 4 5 6)
```

Macros are non-hygienic (like in Common Lisp). Blueprint supports
quasiquoting with backticks, commas, and `,@` for splicing, which
makes writing macros fairly convenient:

```scheme
(defmacro (unless condition consequent alternative)
  `(if (not ,condition)
       ,consequent
       ,alternative))
```

### Tests

Blueprint's test coverage is pretty good. To run the tests:

```sh
$ rspec
```
