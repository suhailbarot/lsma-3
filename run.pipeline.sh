#!/bin/bash



# This script performs a complete Media Event Detection pipeline (MED) using video features:
# a) preprocessing of videos, b) feature representation,
# c) computation of MAP scores, d) computation of class labels for kaggle submission.

# You can pass arguments to this bash script defining which one of the steps you want to perform.
# This helps you to avoid rewriting the bash script whenever there are
# intermediate steps that you don't want to repeat.

# execute: bash run.pipeline.sh -p true -f true -m true -k true -y filepath

# Reading of all arguments:


while getopts p:f:m:k:y: option		# p:f:m:k:y: is the optstring here
	do
	case "${option}"
	in
	p) PREPROCESSING=${OPTARG};;       # boolean true or false
	f) FEATURE_REPRESENTATION=${OPTARG};;  # boolean
	m) MAP=${OPTARG};;                 # boolean
	k) KAGGLE=$OPTARG;;                # boolean
    y) YAML=$OPTARG;;                  # path to yaml file containing parameters for feature extraction
	esac
	done

export PATH=~/anaconda3/bin:$PATH






if [ "$MAP" = true ] ; then

    echo "#######################################"
    echo "# MED with SURF Features: MAP results #"
    echo "#######################################"

    # Paths to different tools;
    map_path=/home/ubuntu/tools/mAP
    export PATH=$map_path:$PATH
    mkdir -p cnn_surf_pred
    mkdir -p cnn_mfcc_pred
    mkdir -p surf_mfcc_pred
    mkdir -p cnn_asr_pred
    mkdir -p surf_asr_pred
    mkdir -p mfcc_asr_pred


    # iterate over the events
    feat_dim_surf=500
    feat_dim_cnn=500
    mode="cnn"
    cat "list/train" "list/val" >"./merged_train"
    for event in P001 P002 P003; do
        if [ "$mode" = "cnn" ] ; then

          echo "=========  Event $event  ========="
          # now train a svm model
          # python2 train_svm.py $event "kmeans_cnn/" $feat_dim_cnn cnn_asr_pred/svm.$event.$feat_dim_cnn_asr.cnn_asr.model "asrfeat/" || exit 1;
          # apply the svm model to *ALL* the testing videos;
          # output the score of each testing video to a file ${event}_pred 
          python2 test_svm.py cnn_asr_pred/svm.$event.$feat_dim_cnn_asr.cnn_asr.model "kmeans_cnn/" $feat_dim_cnn cnn_asr_pred/${event}_cnn_asr.lst $event "asrfeat/" || exit 1;
        #   # compute the average precision by calling the mAP package
        python2 evaluator.py list/${event}_val_label.txt cnn_asr_pred/${event}_cnn_asr.lst
          ap list/${event}_val_label.txt cnn_pred/${event}_cnn.lst
        fi
        if [ "$mode" = "surf" ] ; then

          echo "=========  Event $event  ========="
          # now train a svm model

          python2 train_svm.py $event "kmeans_cnn/" $feat_dim_surf surf_pred/svm.$event.$feat_dim_surf.model "asrfeat/" || exit 1;
          # apply the svm model to *ALL* the testing videos;
          # output the score of each testing video to a file ${event}_pred 
          python2 test_svm.py surf_pred/svm.$event.$feat_dim_surf.model "kmeans_cnn/" $feat_dim_surf surf_pred/${event}_surf.lst $event "asrfeat/" || exit 1;
        #   # compute the average precision by calling the mAP package
                python2 evaluator.py list/${event}_val_label.txt surf_pred/${event}_surf.lst

          ap list/${event}_val_label.txt surf_pred/${event}_surf.lst
        fi
    done

    echo "#######################################"
    echo "# MED with CNN Features: MAP results  #"
    echo "#######################################"


    # 1. TODO: Train SVM with OVR using only videos in training set.

    # 2. TODO: Test SVM with val set and calculate its MAP scores for own info.

	# 3. TODO: Train SVM with OVR using videos in training and validation set.

	# 4. TODO: Test SVM with test set saving scores for submission

fi


if [ "$KAGGLE" = true ] ; then

    echo "##########################################"
    echo "# MED with SURF Features: KAGGLE results #"
    echo "##########################################"
    map_path=/home/ubuntu/tools/mAP
    export PATH=$map_path:$PATH
    mkdir -p cnn_pred
    mkdir -p surf_pred
    mkdir -p mfcc_pred
    mkdir -p asr_pred
    # iterate over the events
    feat_dim_surf=500
    feat_dim_cnn=500
    mode="cnn"
    for event in P001 P002 P003; do
        python2 combine.py cnn mfcc $event cnn_pred/kaggle_test_${event}.csv mfcc_pred/kaggle_test_${event}.csv
        # python2 evaluator.py list/${event}_val_label.txt cnn_surf_mfcc_asr_avg/${event}_cnn_surf_mfcc_asr.lst
        # if [ "$mode" = "cnn" ] ; then

        # #   echo "=========  Event $event  =========
        #   # now train a svm model

        #   # python2 train_svm_2.py $event "kmeans_mfcc/" $feat_dim_cnn mfcc_pred/svm.$event.$feat_dim_mfcc.mfcc.model || exit 1;
        #   # apply the svm model to *ALL* the testing videos;
        #   # output the score of each testing video to a file ${event}_pre
        #   python2 test_svm_2.py mfcc_pred/svm.$event.$feat_dim_mfcc.mfcc.model "kmeans_mfcc/" $feat_dim_surf mfcc_pred/${event}_mfcc.lst $event || exit 1;
        # #   # compute the average precision by calling the mAP package
        #     python2 evaluator.py list/${event}_val_label.txt mfcc_pred/${event}_mfcc.lst
        #   ap list/${event}_val_label.txt cnn_pred/${event}_cnn.lst
        # fi
        # if [ "$mode" = "surf" ] ; then

        #   echo "=========  Event $event  ========="
        #   # now train a svm model

        #   python2 train_svm.py $event "kmeans_mfcc/" $feat_dim_surf surf_pred/svm.$event.$feat_dim_surf.model "asrfeat/" || exit 1;
        #   # apply the svm model to *ALL* the testing videos;
        #   # output the score of each testing video to a file ${event}_pred 
        #   python2 test_svm.py surf_pred/svm.$event.$feat_dim_surf.model "kmeans_mfcc/" $feat_dim_surf surf_pred/${event}_surf.lst $event "asrfeat/" || exit 1;
        # #   # compute the average precision by calling the mAP package
        #         python2 evaluator.py list/${event}_val_label.txt surf_pred/${event}_surf.lst

        #   ap list/${event}_val_label.txt surf_pred/${event}_surf.lst
        # fi
    done


    echo "##########################################"
    echo "# MED with CNN Features: KAGGLE results  #"
    echo "##########################################"

    # 1. TODO: Train SVM with OVR using only videos in training set.

    # 2. TODO: Test SVM with val set and calculate its MAP scores for own info.

	# 3. TODO: Train SVM with OVR using videos in training and validation set.

	# 4. TODO: Test SVM with test set saving scores for submission

fi
