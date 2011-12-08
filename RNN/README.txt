
Code and data for the paper:

Parsing Natural Scenes and Natural Language with Recursive Neural Networks, 
Richard Socher, Cliff Lin, Andrew Y. Ng, and Christopher D. Manning
The 28th International Conference on Machine Learning (ICML 2011)


This code is provided as is. It is free for academic, non-commercial purposes. 
For questions, please contact richard @ socher .org


Please cite the paper when you use this code:
@InProceedings{SocherEtAl2011:RNN,
author = {Richard Socher and Cliff C. Lin and Andrew Y. Ng and Christopher D. Manning},
title = {{Parsing Natural Scenes and Natural Language with Recursive Neural Networks}},
booktitle = {Proceedings of the 26th International Conference on Machine Learning (ICML)},
year = 2011
}



-------------------------------------------
Code
-------------------------------------------

For training and testing the full model run in matlab:

trainVRNN

For only testing with previously trained parameters (which doesn't require much RAM), run 

testVRNN

That should give an accuracy of 0.783473 on this fold.
Note that since this is a non-convex objective the final accuracy when you re-train the model may differ to that one.

The code is optimized for speed but uses a lot of RAM (especially the pre-training that looks at all possible pairs).
If you just want to run the code on a small machine for studying it, set tinyDatasetDebug = 1; in the top of trainVRNN




-------------------------------------------
Data 
-------------------------------------------

The data is pre-processed and in matlab format. 
For the original publication of the dataset, see http://users.cecs.anu.edu.au/~sgould/


Both training and test sets are struct arrays and have the following format:

evalSet.allData{1}:
          img: [240x320x3 uint8]
       labels: [240x320 double]
        segs2: [240x320 double]
        feat2: [115x119 double]
    segLabels: [115x1 double]
          adj: [115x115 logical]

