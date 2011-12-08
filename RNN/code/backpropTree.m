function [df_Wout, df_W, df_Wbot, df_Wcat] = backpropTree(synCat,Wout,W,Wbot,Wcat,imgTree,thisNode,deltaUp,params)

%imgTree.plotTree()
df_Wbot = 0;
df_Wcat = 0;

thisNodeAct = imgTree.nodeFeatures(:,thisNode);

% Wout
df_Wout = thisNodeAct';

deltaDownAddSyn = Wout'.*params.df(thisNodeAct);
deltaDownFull = deltaUp+deltaDownAddSyn;

%%% Wcat
if imgTree.cost %&& synCat==2
    target = imgTree.nodeLabels(:,thisNode);
    if any(target)
        target  = target./sum(target );
        delta_cats = (imgTree.catOut(:,thisNode)-target);
        df_Wcat = delta_cats*[ thisNodeAct' 1];
        deltaDownAddCat = Wcat' * delta_cats .*params.df([thisNodeAct ;1]);
        deltaDownAddCat = deltaDownAddCat(1:params.numHid);
        deltaDownFull = deltaDownFull - deltaDownAddCat;
    end
end



kids = imgTree.getKids(thisNode);
kidsActLR{1} = imgTree.nodeFeatures(:,kids(1));
kidsActLR{2} = imgTree.nodeFeatures(:,kids(2));
kidsAct = [kidsActLR{1} ;kidsActLR{2} ; 1];
df_W =  deltaDownFull*kidsAct';

W_x_deltaUp = (W'*deltaDownFull);
Wd_bothKids = W_x_deltaUp(1:2*params.numHid);
Wd_bothKids= reshape(Wd_bothKids,params.numHid,2);

for c = 1:2
    
    deltaDown= Wd_bothKids(:,c) .* params.df(kidsActLR{c});
    
    if imgTree.isLeaf(kids(c))

        target = imgTree.nodeLabels(:,kids(c));
        if imgTree.cost && any(target)
            thisKidAct = imgTree.nodeFeatures(:,kids(c));
            target  = target./sum(target);
            delta_cats = (imgTree.catOut(:,kids(c))-target);
            
            df_Wcat = df_Wcat+ delta_cats*[ thisKidAct' 1];
            deltaDownAddCat = Wcat' * delta_cats .*params.df([thisKidAct;1]);
            
            deltaDownAddCat = deltaDownAddCat(1:params.numHid);
            deltaDown = deltaDown - deltaDownAddCat;
        end
        
        df_Wbot = df_Wbot + deltaDown * [imgTree.leafFeatures(kids(c),:) 1];        
    else
        [df_Wout_new, df_W_new, df_Wbot_new,df_Wcat_new] = backpropTree(synCat,Wout,W,Wbot,Wcat,imgTree,kids(c),deltaDown,params);
        df_Wout = df_Wout + df_Wout_new ;
        df_Wbot = df_Wbot + df_Wbot_new ;
        df_W = df_W + df_W_new;
        df_Wcat = df_Wcat + df_Wcat_new;
    end
    
    
end
