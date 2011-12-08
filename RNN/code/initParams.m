

fanIn = params.numFeat;
range = 1/sqrt(fanIn);
Wbot = -range + (2*range).*rand(params.numHid,fanIn);
Wbot(:,end+1) = zeros(params.numHid,1);

fanIn = 2*params.numHid;
range = 1/sqrt(fanIn);
W = -range + (2*range).*rand(params.numHid,fanIn);
W(:,end+1) = zeros(params.numHid,1);

Wout = 0.08*randn(1,params.numHid);

% sparsify W a little
zeroOut = 35;
if zeroOut
    for i = 1:size(W,1)
        makeZero = randperm(size(W,2));
        W(i,makeZero(1:min(zeroOut,size(W,2)-3))) = 0;
    end
end


% Wcat
fanIn = params.numHid;
range = 1/sqrt(fanIn);
Wcat = -range + (2*range).*rand(params.numLabels,fanIn);
Wcat(:,end+1) = zeros(params.numLabels,1);
