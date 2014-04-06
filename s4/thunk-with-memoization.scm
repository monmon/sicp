(define (evaluated-thunk? obj)
  (tagged-list? obj 'evaluated-thunk))

(define (thunk-value evaluated-thunk) (cadr evaluated-thunk))

(define (force-it obj)
  (cond ((thunk? obj)
         (let ((result (actual-value
                         (thunk-exp obj)
                         (thunk-env obj))))
           (set-car! obj 'evaluated-thunk)
           (set-car! (cdr obj) result) ; expをその場で置き換える
           (set-cdr! (cdr obj) '())    ; 不要なenvを忘れる
           result))
        ((evaluated-thunk? obj)
         (thunk-value obj))
        (else obj)))
