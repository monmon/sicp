## 5.2.1 計算機モデル

* make-machineがやること
    * 計算機モデルを作る
        1. 全てのレジスタ計算機に、共通な計算機モデルの部品を構成する
            * そのためにmake-new-machineを呼ぶ
        2. make-new-machineで構成される基本計算機モデルを特定の計算機のレジスタ、演算、制御器を含むように拡張する
            * 渡されたレジスタ名のそれぞれに新しい計算機のレジスタを割り当て、指示された演算を計算機に組み込む
            * アセンブラを使い、制御器のリストを新しい計算機の命令に変換し、これを計算機の命令列として食い込む
        3. 修正した計算機モデルをその値として返す

* 計算機モデル
    * 局所状態を持つ手続き

* make-new-machine
    * いくつかのレジスタとスタックの容器と、制御器の命令を一つずつ処理する実行機構

* レジスタ
    * 局所状態を持つ手続き
    * make-registerで作れる

* make-register
    * アクセスしたり、変更したりできる値を保持するレジスタを作り出す

* スタック
    * 局所状態を持つ手続き

* make-stack
    * スタックの項目のリストが局所状態になっているスタックを作り出す
    * 項目をスタックにpushする、最上の項目をスタックから外して返してpopする、またスタックを空にinitializeする、要求を受け入れる

* 基本計算機
    * make-new-machine手続きを呼び出すと作られる

* make-new-machine
    * スタック、（最初は空の）命令列、（最初はスタックを初期化する）命令を含む演算のリスト、（最初はflagとpcという2つのレジスタを含む）レジスタ表、を局所状態とする
    * 内部手続きallocate-register
        * レジスタ表に新しい項目を追加
    * 内部手続きlookup-register
        * 表中のレジスタを探す
    * flagレジスタ
        * シミュレートされる計算機で分岐を制御するのに使う
    * test命令
        * flagの内容をテストの結果(真または偽)に設定する
    * branch命令
        * flagの内容を調べ、分岐するしないを決定する
    * pcレジスタ
        * 計算機が走る時の命令の進行（内部手続きexecuteが実装したもの）を制御する

「シミュレーションモデルでは, 各機械命令は, 命令実行手続き(instruction execution procedure)という, その手続きの呼出しがその命令の実行をシミュレートすることになる, 引数のない手続きを含むデータ構造である.」

* 命令と命令実行手続き
    * 命令は命令実行手続きを持つ？

* pc
    * 実行すべき次の命令から始る命令列の場所を指す

* execute
    * pcが指した命令を取り、その命令実行手続きを呼び出してそれを実行
    * pcが命令列の終わりを指すまで繰り返す

## 5.2.2 アセンブラ

* アセンブラ
    * ある計算機の制御器の式の列を、（それぞれが実行手続きをもつ）対応する機械命令のリストに変換する
    * すべてのラベルが何を参照するか知っている
        1. ラベルを命令から分離するため、制御器の文書の走査から始める
        2. 文書を走査しながら、命令のリストと、各ラベルをリストの中へのポインタと対応づける表を構成する
        3. 各命令の実行手続きを挿入して、命令リストを拡張する

* assemble
    * 引数として制御器の文書と計算機のモデルをとり、モデルに格納すべき命令列を返す
    * extract-labelsを呼び出し、渡された制御器文書から、最初の命令リストとラベル表を構築する

* extract-labels
    * 引数としてリストtext(制御器の命令の式の列)とreceive手続きをとる
        * receiveは二つの値で呼び出される
            1. それぞれがtextの命令を含んでいる命令のデータ構造のリストinsts
            2. textの各ラベルを、リストinsts内のラベルが指示している位置と対応づけるlabelsという表
    * 第二引数は、assembleで構築された結果を処理するのに呼び出す手続き
        * この手続きはupdate-insts!を使って命令実行手続きを生成し、それらを命令リストに挿入して、修正したリストを返す
    * textの要素を順に走査しinstsとlabelsを蓄積する
        * 要素が記号(つまりラベル)の時は適切な入り口をlabels表に追加し、それ以外の要素はinstsリストに蓄積する