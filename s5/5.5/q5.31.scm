; env 環境
; argl 引数
; proc 手続き
;
; p.340 の (f 84 96) の例
;
; レジスタが変更される時に save と restore が必要になる
;
; (f 'x 'y)
; 'x も 'y も env, argl, proc を必要とせずレジスタの変更はないので save と restore の必要なし
;
; ((f) 'x 'y)
; 上と同じ理由で 'x も 'y も (f) の env, argl, proc を必要しないので save と restore の必要なし
;
; (f (g 'x) y)
; env は (g 'x) を解釈するときに変更され、 y を解釈する時に戻るので save と restore が必要
; argl は (g 'x) を解釈するときに (g 'x) y から 'x になるので save と restore が必要
; proc は (g 'x) を解釈するときに f から g になるので save と restore が必要
;
; (f (g 'x) 'y)
; env は (g 'x) を解釈するときに変更されるので save の必要があるが、 'y を解釈する時には（ quoted なので）環境を必要しないから restore は不必要
; argl は 3 番目と同じで save と restore が必要
; proc は 3 番めと同じで save と restore が必要
