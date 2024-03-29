#!/usr/bin/env bash

set -x
set -e

DIR="$( cd "$( dirname "$0" )" && cd ../../ && pwd )"
echo "working directory: ${DIR}"

PRED_DIR=$OUTPUT_DIR
if [[ $# -ge 1 && ! "$1" == "--"* ]]; then
    PRED_DIR=$1
    shift
fi

SPLIT="nq_test"
if [[ $# -ge 1 && ! "$1" == "--"* ]]; then
    SPLIT=$1
    shift
fi

if [ -z "$DATA_DIR" ]; then
  DATA_DIR="${DIR}/data/dpr/"
fi

python misc/dpr/format_and_evaluate.py \
  --data-dir "${DATA_DIR}" \
  --topk 1 5 20 100 \
  --topics "${DATA_DIR}/${SPLIT}_queries.tsv" \
  --input "/home/shishijie/workspace/project/ColBERT/experiments/nq_bsz32_dim256_lr1e-5/retrieval/2023-12/28/10.20.14/nq_bsz32_dim256_lr1e-5_step70k.tsv" \
  --output "${PRED_DIR}/${SPLIT}.dpr.json" "$@"
