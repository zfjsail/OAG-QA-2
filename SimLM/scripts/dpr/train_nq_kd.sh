#!/usr/bin/env bash

set -x
set -e

DIR="$( cd "$( dirname "$0" )" && cd ../../ && pwd )"
echo "working directory: ${DIR}"

if [ -z "$OUTPUT_DIR" ]; then
  OUTPUT_DIR="${DIR}/checkpoint/kd_$(date +%F-%H%M.%S)"
fi
if [ -z "$DATA_DIR" ]; then
  DATA_DIR="${DIR}/data/dpr"
fi

mkdir -p "${OUTPUT_DIR}"

PROC_PER_NODE=$(nvidia-smi --list-gpus | wc -l)
# python -u -m torch.distributed.launch --nproc_per_node ${PROC_PER_NODE} src/train_biencoder.py \
# deepspeed src/train_biencoder.py --deepspeed dpr_ds_config.json \
CUDA_VISIBLE_DEVICES=2 python src/train_biencoder.py \
    --model_name_or_path /home/shishijie/workspace/PTMs/simlm-base-wiki100w \
    --task_type qa \
    --per_device_train_batch_size 8 \
    --per_device_eval_batch_size 32 \
    --kd_mask_hn False \
    --kd_cont_loss_weight 1 \
    --seed 123 \
    --do_train \
    --do_kd_biencoder \
    --l2_normalize True \
    --t 0.02 \
    --t_warmup True \
    --fp16 \
    --train_file "${DATA_DIR}/kd_nq_train_distill.jsonl" \
    --validation_file "${DATA_DIR}/nq-dev.jsonl" \
    --q_max_len 32 \
    --p_max_len 192 \
    --train_n_passages 16 \
    --use_first_positive True \
    --dataloader_num_workers 1 \
    --num_train_epochs 15 \
    --learning_rate 3e-5 \
    --use_scaled_loss True \
    --loss_scale 1 \
    --warmup_steps 1000 \
    --share_encoder True \
    --logging_steps 50 \
    --output_dir "${OUTPUT_DIR}" \
    --data_dir "${DATA_DIR}" \
    --save_total_limit 10 \
    --save_strategy epoch \
    --evaluation_strategy epoch \
    --load_best_model_at_end \
    --metric_for_best_model mrr \
    --greater_is_better True \
    --remove_unused_columns False \
    --overwrite_output_dir \
    --disable_tqdm True \
    --report_to none "$@"
