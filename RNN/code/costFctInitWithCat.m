function [cost,grad,catRightBot,catTotalBot,catRightTop,catTotalTop] = costFctInitWithCat(X,decodeInfo,goodPairsL,goodPairsR,badPairsL,badPairsR,onlyGoodL,onlyGoodR,onlyGoodLabels,allSegs,allSegLabels,params)
cost=0;
[Wbot,W,Wout,Wcat] = stack2param(X, decodeInfo);

numOnlyGood = length(onlyGoodLabels);
numAll = length(allSegLabels);
onlyGoodBotL= params.f(Wbot* onlyGoodL);
onlyGoodBotR= params.f(Wbot* onlyGoodR);
onlyGoodBotA= params.f(Wbot* allSegs);

onlyGoodHid = params.f(W * [onlyGoodBotL; onlyGoodBotR; ones(1,numOnlyGood)]);

catHid = Wcat * [onlyGoodHid ; ones(1,numOnlyGood)];
catOut = softmax(catHid);

target = zeros(params.numLabels,numOnlyGood);
target(sub2ind(size(target),onlyGoodLabels,1:numOnlyGood))=1;

targetA = zeros(params.numLabels,numAll);
targetA(sub2ind(size(targetA),allSegLabels,1:numAll))=1;

cost = cost  -sum(sum(target.*log(catOut)));
[~, classOut] = max(catOut);
catRightTop = sum(classOut==onlyGoodLabels);
catTotalTop = length(classOut);
deltaCatTop = (catOut-target);

%%% df_Wcat
df_Wcat =  deltaCatTop * [ onlyGoodHid' ones(numOnlyGood,1)];

deltaDownCatTop = Wcat' * deltaCatTop .*params.df([ onlyGoodHid ;ones(1,numOnlyGood)]);
deltaDownCatTop= deltaDownCatTop(1:params.numHid,:);

%%% df_W
df_W = deltaDownCatTop*[onlyGoodBotL; onlyGoodBotR; ones(1,numOnlyGood)]';

deltaDownTop = (W'*deltaDownCatTop) .* params.df([onlyGoodBotL; onlyGoodBotR; ones(1,numOnlyGood)]);
deltaDownTopL = deltaDownTop(1:params.numHid,:);
deltaDownTopR = deltaDownTop(params.numHid+1:2*params.numHid,:);

% now the kids!
catHidL = Wcat * [onlyGoodBotL ; ones(1,numOnlyGood)];
catHidR = Wcat * [onlyGoodBotR ; ones(1,numOnlyGood)];
catHidA = Wcat * [onlyGoodBotA ; ones(1,numAll)];

catOutL = softmax(catHidL);
catOutR = softmax(catHidR);
catOutA = softmax(catHidA);

% target is the same as for the merged!
cost = cost -sum(sum(target.*log(catOutL)));
cost = cost -sum(sum(target.*log(catOutR)));
costA = -sum(sum(targetA.*log(catOutA)));
[~, classOutL] = max(catOutL);
[~, classOutR] = max(catOutR);
[~, classOutA] = max(catOutA);
catRightBot = 0           +sum(classOutL==onlyGoodLabels);
catRightBot = catRightBot +sum(classOutR==onlyGoodLabels);
catRightBot = catRightBot +sum(classOutA==allSegLabels);
catTotalBot = length(classOutL)+length(classOutR)+length(classOutA);

deltaCatBotL = (catOutL-target);
deltaCatBotR = (catOutR-target);
deltaCatBotA = (catOutA-targetA);

%%% df_Wcat
df_Wcat =  df_Wcat + deltaCatBotL * [ onlyGoodBotL' ones(numOnlyGood,1)];
df_Wcat =  df_Wcat + deltaCatBotR * [ onlyGoodBotR' ones(numOnlyGood,1)];
df_WcatA =  deltaCatBotA * [onlyGoodBotA' ones(numAll,1)];

deltaDownCatL = Wcat' * deltaCatBotL .*params.df([ onlyGoodBotL ;ones(1,numOnlyGood)]);
deltaDownCatR = Wcat' * deltaCatBotR .*params.df([ onlyGoodBotR ;ones(1,numOnlyGood)]);
deltaDownCatA = Wcat' * deltaCatBotA .*params.df([ onlyGoodBotA ;ones(1,numAll)]);

deltaDownCatL =deltaDownCatL(1:params.numHid,:);
deltaDownCatR =deltaDownCatR(1:params.numHid,:);
deltaDownCatA =deltaDownCatA(1:params.numHid,:);

deltaFullDownL = deltaDownCatL+deltaDownTopL;
deltaFullDownR = deltaDownCatR+deltaDownTopR;
% these are just single segs
deltaFullDownA = deltaDownCatA;

%%% df_Wbot
df_Wbot = deltaFullDownL * onlyGoodL';
df_Wbot = df_Wbot +  deltaFullDownR * onlyGoodR';
df_WbotA = deltaFullDownA * allSegs';

%%% final cost and derivatives of categories
cost = 1./(3* numOnlyGood)  * cost + 1./numAll * costA;
df_Wcat_CAT = 1./(3 * numOnlyGood)  * df_Wcat + 1./numAll * df_WcatA;
df_W_CAT = 1./(3 * numOnlyGood) * df_W;
df_Wbot_CAT = 1./(3 * numOnlyGood)  * df_Wbot + 1./numAll * df_WbotA;



% forward prop all segment features into the hidden/"semantic" space
goodBotL = params.f(Wbot* goodPairsL);
goodBotR = params.f(Wbot* goodPairsR);
badBotL = params.f(Wbot* badPairsL);
badBotR = params.f(Wbot* badPairsR);

numGoodAll = size(goodBotL,2);
numBadAll = size(badBotL,2);

% forward prop the pairs and compute scores
goodHid = params.f(W * [goodBotL ; goodBotR ; ones(1,numGoodAll)]);
badHid  = params.f(W * [badBotL ; badBotR ; ones(1,numBadAll)]);

scoresGood = Wout*goodHid;
scoresBad = Wout*badHid;

% compute cost
costAll = 1-scoresGood+scoresBad;
ignoreGBPairs = costAll<0;

costAll(ignoreGBPairs)  = [];
goodBotL(:,ignoreGBPairs) = [];
goodBotR(:,ignoreGBPairs) = [];
badBotL(:,ignoreGBPairs) = [];
badBotR(:,ignoreGBPairs) = [];
goodHid(:,ignoreGBPairs) = [];
badHid(:,ignoreGBPairs)  = [];
goodPairsL(:,ignoreGBPairs)  = [];
goodPairsR(:,ignoreGBPairs)  = [];
badPairsL(:,ignoreGBPairs)  = [];
badPairsR(:,ignoreGBPairs)  = [];

numAll = length(costAll);


cost = cost + 1./length(ignoreGBPairs) * sum(costAll(:)) + params.regPTC/2 * (sum(Wbot(:).^2) +sum(W(:).^2) +sum(Wout(:).^2) +sum(Wcat(:).^2));


df_Wout =-sum(goodHid,2)' +  sum(badHid,2)';

% subtract good neighbors:
delta4 = bsxfun(@times,Wout',params.df(goodHid));
df_W = -delta4 * [goodBotL ; goodBotR ; ones(1,numAll)]';

delta3 =(W'*delta4) .* params.df([goodBotL ; goodBotR ; ones(1,numAll)]);
delta3L = delta3(1:params.numHid,:);
delta3R = delta3(params.numHid+1:2*params.numHid,:);

df_Wbot = - delta3L * goodPairsL';
df_Wbot = df_Wbot - delta3R * goodPairsR';

% add bad neighbors
delta4 = bsxfun(@times,Wout',params.df(badHid));
df_W = df_W +  delta4 * [badBotL ; badBotR ; ones(1,numAll)]';

delta3 =(W'*delta4) .* params.df([badBotL ; badBotR ; ones(1,numAll)]);
delta3L = delta3(1:params.numHid,:);
delta3R = delta3(params.numHid+1:2*params.numHid,:);

df_Wbot = df_Wbot +  delta3L * badPairsL';
df_Wbot = df_Wbot +  delta3R * badPairsR';


% add category's derivatives and regularizer
df_Wcat = df_Wcat_CAT + params.regPTC * Wcat;

df_Wbot = df_Wbot_CAT  + 1./length(ignoreGBPairs) * df_Wbot + params.regPTC * Wbot;
df_W    = df_W_CAT  + 1./length(ignoreGBPairs) * df_W    + params.regPTC * W;
df_Wout = 1./length(ignoreGBPairs) * df_Wout + params.regPTC * Wout;


[grad,~] = param2stack(df_Wbot,df_W,df_Wout,df_Wcat);