# See tasks/utils.py for possible dataset and task names.
export DATASET_NAME=hyperpartisan
export TASK_NAME=hyperpartisan

# Use cuda device 0 only
export CUDA_VISIBLE_DEVICES=0

export MODEL_NAME=allenai/longformer-base-4096

# Weights and biases (wandb) related config. Set use_wandb=none if you don't want to use wandb.
use_wandb=none # Set to "none" to disable wandb tracking, or "wandb" to enable it.
export DISPLAY_NAME=longformer-base-propagation
export RUN_ID=1
export WANDB_MODE=online
export LINEAGE=longformer-propagation # This is just a tag on wandb to make tracking runs easier
export WANDB_PROJECT_NAME="<ORG>/<PROJECT_NAME>" # IMPORTANT: set this to your own wandb project

checkpoint_dir=checkpoints/$DATASET_NAME/$WANDB_NAME/  # change this to your own checkpoint dir

batch_size=1
eval_batch_size=8
dropout=0.1
training_epochs=20
gradient_accumulation_steps=32 # simulate a larger batch size with this
seed=10

psl=8

for lr in 7e-3 5e-2 1e-3 5e-3 1e-2 5e-4
do
    export WANDB_NAME=$DISPLAY_NAME-$RUN_ID-$lr

    # To enable prefix-propagation, make sure to use the flags: --prefix --propagation_prefix only
    python3 run.py \
    --model_name_or_path $MODEL_NAME \
    --task_name $TASK_NAME \
    --dataset_name $DATASET_NAME \
    --do_train \
    --do_predict \
    --do_eval \
    --max_seq_length $((4096-psl)) \
    --per_device_train_batch_size $batch_size \
    --per_device_eval_batch_size $eval_batch_size \
    --gradient_accumulation_steps $gradient_accumulation_steps \
    --learning_rate $lr \
    --num_train_epochs $training_epochs \
    --pre_seq_len $psl \
    --additional_non_frozen_embeds 2 \
    --output_dir checkpoints/$DATASET_NAME/$WANDB_NAME/ \
    --hidden_dropout_prob $dropout \
    --warmup_ratio 0.1 \
    --seed $seed \
    --save_strategy epoch \
    --evaluation_strategy epoch \
    --logging_strategy steps \
    --optim adamw_torch \
    --prefix \
    --propagate_prefix only \
    --logging_steps 8 \
    --save_total_limit 2 \
    --report_to $use_wandb
done
