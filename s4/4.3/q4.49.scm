; from https://github.com/jewel12/sicp/blob/master/s4/q4.49.scm
(define (require p)
  (if (not p) (amb)))

(define nouns '(noun student professor cat class))
(define verbs '(verb studies lectures eats sleeps))
(define prepositions '(prep for to in by with))
(define articles '(article the a))

(define (parse-sentence)
  (list 'sentence
         (parse-noun-phrase)
         (parse-word verbs)))

;; ;; original
;; (define (parse-word word-list)
;;   (require (not (null? *unparsed*)))
;;   (require (memq (car *unparsed*) (cdr word-list)))
;;   (let ((found-word (car *unparsed*)))
;;     (set! *unparsed* (cdr *unparsed*))
;;     (list (car word-list) found-word)))

;; parse-wordをword-listから適当に選んで返すようにする
;; 停止条件を満たすために*unparsed*はここで空にしておく

;; an-element-of を使ったバージョン
;; (define (an-element-of items)
;;   (require (not (null? items)))
;;   (amb (car items) (an-element-of (cdr items))))

;; (define (parse-word word-list)
;;   (set! *unparsed* '())
;;   (list (car word-list) (an-element-of (cdr word-list))))

(define (parse-word word-list)
  (set! *unparsed* '())
  (list (car word-list) (at (random-integer (length (cdr word-list)))
                                            (cdr word-list))))

(define (at i l)
  (define (search l j)
    (if (null? (cdr l))
        (car l)
        (if (= i j)
            (car l)
            (search (cdr l) (+ 1 j)))))
  (search l 1))

(define (length li)
  (define (len i l)
    (if (null? l)
        i
        (len (+ i 1) (cdr l))))
  (len 0 li))

(define *unparsed* '())

(define (parse input)
  (set! *unparsed* input)
  (let ((sent (parse-sentence)))
    (require (null? *unparsed*))
    sent))

(define (parse-prepositional-phrase)
  (list 'prep-phrase
        (parse-word prepositions)
        (parse-noun-phrase)))

(define (parse-verb-phrase)
  (define (maybe-extend verb-phrase)
    (amb verb-phrase
         (maybe-extend (list 'verb-phrase
                             verb-phrase
                             (parse-prepositional-phrase)))))
  (maybe-extend (parse-word verbs)))

(define (parse-simple-noun-phrase)
  (list 'simple-noun-phrase
        (parse-word articles)
        (parse-word nouns)))

(define (parse-noun-phrase)
  (define (maybe-extend noun-phrase)
    (amb noun-phrase
         (maybe-extend (list 'noun-phrase
                             noun-phrase
                             (parse-prepositional-phrase)))))
  (maybe-extend (parse-simple-noun-phrase)))

;; (parse '(the professor lectures to the student with the cat))
