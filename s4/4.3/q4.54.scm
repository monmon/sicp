; 利用者が非決定性プログラムの一部として定義するrequireが, ambを使う通常の手続きとして実装出来ると気づかなかったら, これを特殊形式として実装したであろう. これには構文手続き
(define (require? exp) (tagged-list? exp 'require))

(define (require-predicate exp) (cadr exp))
; とanalyzeの振分けの新しい節
((require? exp) (analyze-require exp))
; とrequire式を扱う手続きanalyze-requireが必要である. analyze-requireの次の定義を完成せよ.

; pred-value の値が偽の場合には失敗継続にすれば良いので
(define (analyze-require exp)
  (let ((pproc (analyze (require-predicate exp))))
    (lambda (env succeed fail)
      (pproc env
             (lambda (pred-value fail2)
               (if (not (true? pred-value))
                 (fail2)
                 (succeed 'ok fail2)))
             fail))))

