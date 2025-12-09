import os
import re
import pandas as pd
import numpy as np

def parse_fio_log(file_path):
    """
    単一のfioログファイルからパフォーマンスメトリクスを抽出
    """
    with open(file_path, 'r') as f:
        content = f.read()
    
    # 主要なメトリクスを抽出するための正規表現パターン
    metrics = {
        'read_iops': r'read: IOPS=(\d+)',
        'read_bw': r'read: .*BW=(\d+)KiB/s',
        'write_iops': r'write: IOPS=(\d+)',
        'write_bw': r'write: .*BW=(\d+)KiB/s',
        'read_clat_min': r'read: clat \(usec\): min=(\d+)',
        'read_clat_max': r'read: clat \(usec\): .*max=(\d+)',
        'read_clat_avg': r'read: clat \(usec\): .*avg=(\d+\.\d+)',
        'read_clat_stdev': r'read: clat \(usec\): .*stdev=(\d+\.\d+)',
    }
    
    # パーセンタイルの抽出
    read_percentile_pattern = r'(\d+\.\d+)th=\[\s*(\d+)\]'
    read_percentiles = re.findall(read_percentile_pattern, content)
    
    parsed_metrics = {}
    
    # 基本的なメトリクスの抽出
    for key, pattern in metrics.items():
        match = re.search(pattern, content)
        if match:
            parsed_metrics[key] = float(match.group(1))
    
    # 読み取りパーセンタイルの処理
    for percentile, value in read_percentiles:
        parsed_metrics[f'read_percentile_{percentile}'] = float(value)
    
    # 書き込みレイテンシーの抽出を試みる
    write_clat_patterns = {
        'write_clat_min': r'write: clat \(usec\): min=(\d+)',
        'write_clat_max': r'write: clat \(usec\): .*max=(\d+)',
        'write_clat_avg': r'write: clat \(usec\): .*avg=(\d+\.\d+)',
        'write_clat_stdev': r'write: clat \(usec\): .*stdev=(\d+\.\d+)',
    }
    
    for key, pattern in write_clat_patterns.items():
        match = re.search(pattern, content)
        if match:
            parsed_metrics[key] = float(match.group(1))
    
    parsed_metrics['filename'] = os.path.basename(file_path)
    
    return parsed_metrics

def analyze_fio_results():
    """
    カレントディレクトリ内の"E5"で始まるfioログファイルを分析
    """
    results = []
    
    for filename in os.listdir('.'):
        if filename.startswith('E5') and os.path.isfile(filename):
            try:
                file_metrics = parse_fio_log(filename)
                results.append(file_metrics)
            except Exception as e:
                print(f"Error processing {filename}: {e}")
    
    return pd.DataFrame(results)

def generate_summary_report(df):
    """
    収集されたメトリクスの統計サマリーを生成
    """
    if df.empty:
        print("No data to generate summary.")
        return None
    
    # 読み取り関連の列を抽出
    read_cols = [col for col in df.columns if col.startswith('read_')]
    read_summary = df[read_cols].agg(['mean', 'median', 'std', 'min', 'max'])
    
    # 書き込み関連の列を抽出（存在する場合）
    write_cols = [col for col in df.columns if col.startswith('write_')]
    
    summary = {
        'read_metrics': read_summary
    }
    
    # 書き込み関連のメトリクスが存在する場合のみ追加
    if write_cols:
        write_summary = df[write_cols].agg(['mean', 'median', 'std', 'min', 'max'])
        summary['write_metrics'] = write_summary
    
    return summary

def main():
    # データフレームの作成
    df = analyze_fio_results()
    
    # ファイル数の確認
    print(f"Found {len(df)} files starting with 'E5'")
    
    # サマリーレポートの生成
    summary = generate_summary_report(df)
    
    # サマリーの詳細出力
    if summary:
        print("\nRead Metrics Summary:")
        print(summary['read_metrics'])
        
        if 'write_metrics' in summary:
            print("\nWrite Metrics Summary:")
            print(summary['write_metrics'])
    
    # オプション: CSVファイルへの出力
    if not df.empty:
        output_file = 'fio_results_summary.csv'
        df.to_csv(output_file, index=False)
        print(f"\nDetailed results saved to {output_file}")

if __name__ == "__main__":
    main()