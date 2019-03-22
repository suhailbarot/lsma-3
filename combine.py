from __future__ import division
import sys
import os
import numpy as np
from random import shuffle
import os
from sklearn.svm.classes import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier,GradientBoostingClassifier
import cPickle


event = sys.argv[3]
files = sys.argv[4:]

if not os.path.exists(sys.argv[1]+"_"+sys.argv[2]+"_avg"):
	os.mkdir(sys.argv[1]+"_"+sys.argv[2]+"_avg")

# output_file = sys.argv[1]+"_"+sys.argv[2]+"_avg"+"/svm_"+sys.argv[1]+"_"+sys.argv[2]+"_avg_model"

# svm_classifier = RandomForestClassifier(n_estimators=300)


# # svm_classifier = GradientBoostingClassifier()
# train_files_list = open('list/train')
# train_files = train_files_list.readlines()
# val_files_list = open('list/val')
# merged_file_list = open('merged_train')
# # train_files = train_files_list.readlines() + val_files_list.readlines()
# # shuffle(merged_file_list)

# X_train = [[0,0] for line in open(files[0]).readlines()]
# for j,file_name in enumerate(files):
# 	file = open(file_name)
# 	lines = file.readlines()
# 	for i,line in enumerate(lines):
# 		line = line.strip().strip("[").strip("]")
# 		x,y = map(float,line.split())
# 		X_train[i][j]=y
 
# for line in train_files:
# 	_,tag = line.strip().split()
#     if tag==event:            
#         Y_train.append(1)
#     else:
#         Y_train.append(0)
# X_train =  np.array(X_train)
# print X_train.shape
# # X_resampled, Y_resampled = SMOTE().fit_resample(X_train, Y_train)
# svm_classifier.fit(X_train,Y_train)
# with open(output_file+'.pkl', 'wb') as fid:
#     cPickle.dump(svm_classifier, fid)


















avg_lines = [0 for line in open(files[0]).readlines()]
for file_name in files:
	file = open(file_name)
	lines = file.readlines()
	for i,line in enumerate(lines):
		line = line.strip()
		y = float(line)
		# avg_lines[i][0]+=x
		avg_lines[i]+=y
avg_lines = [line/len(files) for line in avg_lines]


outfile = open(sys.argv[1]+"_"+sys.argv[2]+"_avg/"+sys.argv[3]+"_"+sys.argv[1]+"_"+sys.argv[2]+"_test.csv","w+")
for line in avg_lines:
	outfile.write(str(line)+"\n")