import os
import re
import csv
import numpy as np
import pandas as pd

def extract_ping_times(filename):
    """Pingの応答時間を抽出する関数"""
    with open(filename, 'r') as f:
        content = f.read()
        times = [float(match) for match in re.findall(r'time=(\d+\.\d+)', content)]
    return times

def process_ping_files():
    """E5から始まるファイルを処理する関数"""
    e5_files = [f for f in os.listdir('.') if f.startswith('E5')]
    
    results = []
    all_ping_times = []  # すべてのping時間を集めるリスト
    
    for filename in e5_files:
        try:
            ping_times = extract_ping_times(filename)
            all_ping_times.extend(ping_times)  # すべてのping時間を追加
            results.append({
                'filename': filename, 
                'median_latency': np.median(ping_times),
                'min_latency': np.min(ping_times),
                'max_latency': np.max(ping_times),
                'mean_latency': np.mean(ping_times),
                'samples': len(ping_times)
            })
        except Exception as e:
            print(f"Error processing {filename}: {e}")
    
    # CSVに出力
    output_filename = 'ping_latency_summary.csv'
    df = pd.DataFrame(results)
    df.to_csv(output_filename, index=False)
    
    print("\n簡易統計サマリ:")
    print(df.to_string(index=False))
    
    print("\n総括:")
    print(f"- サンプル数: {len(results)}ファイル")
    print(f"- 全体の中央値: {np.median(all_ping_times):.3f} ms")
    print(f"- 中央値の範囲: {df['median_latency'].min():.3f} - {df['median_latency'].max():.3f} ms")
    print(f"- 中央値の平均: {df['median_latency'].mean():.3f} ms")
    print(f"- 全体の平均レイテンシ: {df['mean_latency'].mean():.3f} ms")
    print(f"- 平均レイテンシの範囲: {df['mean_latency'].min():.3f} - {df['mean_latency'].max():.3f} ms")
    


process_ping_files()