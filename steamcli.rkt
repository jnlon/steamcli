#!/usr/bin/env racket

#lang racket/base

(require (only-in racket/string 
                  string-split 
                  string-normalize-spaces 
                  string-suffix?)
         (only-in racket/system 
                  system)
         (only-in racket/pretty 
                  pretty-print)
         (only-in racket/cmdline
                  command-line))

(define (print-help-exit)
  (displayln "Usage: ./steamcli [list]")
  (displayln "       ./steamcli [launch <appid>]")
  (displayln "       ./steamcli [dump]")
  (displayln "'list' prints every app and the corresponding appid")
  (displayln "'launch <appid>' tells Steam to run app with <appid>")
  (displayln "'dump' prints metadata for every app")
  (exit 1))

; Make str take up at least minspace spaces
(define (pad-string str minspace)
  (if (>= (string-length str) minspace)
    str
    (let ([newstr (make-string minspace #\space)])
      (string-copy! newstr 0 str)
      newstr)))

; Turn a path into a list of strings
(define (path->lines path)
  (define (read-lines p) (if (eof-object? (peek-byte p)) '() (cons (read-line p) (read-lines p))))
  (call-with-input-file path read-lines))

; Steams installation directory
(define *steam-path*
  (build-path (find-system-path 'home-dir) ".local" "share" "Steam"))

; Path to .acf files, which contain app metadata
(define *acf-path*
  (build-path *steam-path* "steamapps"))

; Turn a line containing two quoted strings into a pair
(define (line->pair line) 
  (define (string-not-whitespace? x) 
    (regexp-match? #px"\\S" x))
  (filter string-not-whitespace? 
          (string-split (string-normalize-spaces line) "\"")))

; Turn a list of lines into a list of string pairs
(define (lines->assoclst lines)
  (define (pair-len-2? p) (= 2 (length p)))
  (filter pair-len-2? (map line->pair lines)))

(define (path->alst path)
  (lines->assoclst (path->lines path)))

; Does the filename end with .acf?
(define (acf-file? path)
  (string-suffix? (path->string path) ".acf"))

; For sorting output apps by name in (query)
(define (sort-app-by-name a b)
  (string-ci<=? (cadr (assoc "name" a))
                (cadr (assoc "name" b))))

; A list of assoc lists containing details of each game
(define *steam-game-data*
  (let* ([files (directory-list *acf-path* #:build? #t)]
        [acf-files (filter acf-file? files)])
  (sort (map path->alst acf-files) sort-app-by-name)))

(define (print-name-appid assoclst)
  (printf "~a ~a ~%"  
          (pad-string (cadr (assoc "appid" assoclst)) 8)
          (cadr (assoc "name" assoclst))))

;; Returns the assoc list of the app which matches the given appid
;; Used to lookup the game's name from its appid
(define (app-from-id appid)
  (define (same-appid? alst) (equal? appid (cadr (assoc "appid" alst))))
  (findf same-appid? *steam-game-data*))

(define (yes-no-prompt? cmd appname)
  (printf "Found game '~a'~%" appname)
  (printf "Execute '~a' [y/n]? " cmd)
  (eqv? #\y (string-ref (read-line) 0)))

;; Dump command
(define (dump)
  (pretty-print *steam-game-data*))

;; List command
(define (query)
  (for-each print-name-appid *steam-game-data*))

;; Launch command
(define (launch appid)
  (let ([cmd (format "steam -applaunch ~a" appid)]
         [app (app-from-id appid)])
    (cond 
      [(boolean? app) (printf "Nothing found for appid: ~a" appid)]
      [(yes-no-prompt? cmd (cadr (assoc "name" app)))
        (begin
          (displayln "Executing...")
          (system cmd))]
      [else 
        (displayln "Aborted!")])))

;; Finally, Parse command-line and do the thing
;; Note: (command-line) does not handle multiple non-flag arguments, and
;; importing racket/match increases startup time dramatically, so we parse
;; flags here by hand
(let ([args (vector->list (current-command-line-arguments))])
  (cond
    [(null? args) (print-help-exit)]
    [(equal? (car args) "list") 
       (query)]
    [(equal? (car args) "dump") 
       (dump)]
    [(and (equal? (car args) "launch") 
          (>= (length args) 2)
          (string->number (cadr args))) 
       (launch (cadr args))]
    [else (print-help-exit)]))
