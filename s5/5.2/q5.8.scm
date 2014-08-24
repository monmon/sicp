(load "./simulator.scm")

(define here-machine
  (make-machine
    '(a)
    '()
    '(start
       (goto (label here))
       here
       (assign a (const 3))
       (goto (label there))
       here
       (assign a (const 4))
       (goto (label there))
       there)))

(print "=== original ===")
(start here-machine)
(print (get-register-contents here-machine 'a)) ; => 3

; ===============================================================
; 同じラベル名が二つの異る場所を指すように使われたら, エラーとする
; ===============================================================
; 関係するのはlabelの時だけなので
; (symbol? next-inst)
; が真の時にlabelsに既にlabelがあるかをassocで確認すれば良い
(define (extract-labels text receive)
  (if (null? text)
    (receive '() '())
    (extract-labels (cdr text)
                    (lambda (insts labels)
                      (let ((next-inst (car text)))
                        (if (symbol? next-inst)
                          (if (assoc next-inst labels)
                            (error "already defined -- ASSEMBLE" next-inst)
                            (receive insts
                                     (cons (make-label-entry next-inst
                                                             insts)
                                           labels)))
                          (receive (cons (make-instruction next-inst)
                                         insts)
                                   labels)))))))

(define here-machine
  (make-machine
    '(a)
    '()
    '(start
       (goto (label here))
       here
       (assign a (const 3))
       (goto (label there))
       here
       (assign a (const 4))
       (goto (label there))
       there)))

(print "=== improved ===")
(start here-machine)
(print (get-register-contents here-machine 'a)) ; => "error": already defined -- ASSEMBLE here
