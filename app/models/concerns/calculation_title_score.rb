module CalculationTitleScore
  # 職業の近さからスコアを計算する
  # スコアが高ければその職業の類似度が高い
  TITLE_KIND = {
    'フロントエンドエンジニア'=> 0,
    'サーバーサイドエンジニア'=> 0,
    'PM'=> 15,
    '個人営業'=> 75,
    '法人営業'=> 85,
    'コンサルタント'=> 100,
    '商品企画'=> 30,
    '人事'=> 50,
    '広報'=> 40,
  }

  def calculation(title_a, title_b)
    100 - (TITLE_KIND[title_a] - TITLE_KIND[title_b]).abs
  end
end
