#!/bin/bash

# 出力ファイル名
output_file="E5-E4_cpg.csv"

# ヘッダーを書き込む
echo "min,avg,max,mdev" > "$output_file"

# 対象となる全てのファイルを処理
for file in E5*; do
  # min/avg/max/mdev の値を抽出
  values=$(grep 'min/avg/max/mdev =' "$file" | awk -F' = ' '{print $2}')
  if [ -n "$values" ]; then
    # カンマ区切りに変換して出力ファイルに追記
    echo "$values" | tr '/' ',' >> "$output_file"
  fi
done

