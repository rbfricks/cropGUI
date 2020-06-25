c2 = readtable('ImCrop.csv', 'Delimiter', ',');

chest = c2.Var1(:)==1;
front = c2.Var6(:)==1;
orign = c2.Var7(:)==1;

total = chest & front & orign;